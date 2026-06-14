import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile_s2_flutter/core/network/api_config.dart';
import 'package:mobile_s2_flutter/core/theme/app_color.dart';
import 'package:mobile_s2_flutter/core/utils/location_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class ShopLocationScreen extends StatefulWidget {
  const ShopLocationScreen({super.key});

  @override
  State<ShopLocationScreen> createState() => _ShopLocationScreenState();
}

class _ShopLocationScreenState extends State<ShopLocationScreen> {
  final Completer<GoogleMapController> _mapController = Completer();

  Position? _userPosition;
  double? _distanceKm;
  bool _isLoading = true;
  String _errorMessage = '';
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  static const LatLng _shopLocation = LatLng(
    ApiConfig.shopLat,
    ApiConfig.shopLng,
  );

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final shippingLat = prefs.getDouble('shipping_lat');
      final shippingLng = prefs.getDouble('shipping_lng');

      Position position;
      if (shippingLat != null && shippingLng != null) {
        position = Position(
          latitude: shippingLat,
          longitude: shippingLng,
          timestamp: DateTime.now(),
          accuracy: 0.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
      } else {
        // Request permission
        LocationPermission perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) {
          perm = await Geolocator.requestPermission();
        }
        if (perm == LocationPermission.deniedForever) {
          setState(() {
            _errorMessage = 'Location permission denied. Enable in settings.';
            _isLoading = false;
          });
          return;
        }

        // Get position
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      }

      // Calculate distance
      final distance = LocationUtils.calculateDistance(
        position.latitude,
        position.longitude,
        ApiConfig.shopLat,
        ApiConfig.shopLng,
      );

      // Set markers
      final userLatLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _userPosition = position;
        _distanceKm = distance;
        _markers = {
          Marker(
            markerId: const MarkerId('shop'),
            position: _shopLocation,
            infoWindow: InfoWindow(
              title: ApiConfig.shopName,
              snippet: ApiConfig.shopAddress,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
          ),
          Marker(
            markerId: const MarkerId('user'),
            position: userLatLng,
            infoWindow: const InfoWindow(title: 'Your Location'),
          ),
        };
        _isLoading = false;
      });

      // Draw route line
      await _drawRoute(userLatLng, _shopLocation);

      // Zoom to fit both markers
      _fitBounds(userLatLng, _shopLocation);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get location: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _drawRoute(LatLng from, LatLng to) async {
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      final url =
          'http://router.project-osrm.org/route/v1/driving/${from.longitude},${from.latitude};${to.longitude},${to.latitude}?overview=full&geometries=polyline';
      final response = await dio.get<dynamic>(url);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final geometry = data['routes'][0]['geometry'] as String;
          final points = _decodePolyline(geometry);

          if (points.isNotEmpty) {
            setState(() {
              _polylines = {
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: points
                      .map((p) => LatLng(p.latitude, p.longitude))
                      .toList(),
                  color: AppColors.buttonColor,
                  width: 4,
                ),
              };
            });
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('OSRM routing failed: $e');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble()));
    }
    return polyline;
  }

  void _fitBounds(LatLng user, LatLng shop) async {
    final controller = await _mapController.future;
    final bounds = LatLngBounds(
      southwest: LatLng(
        min(user.latitude, shop.latitude),
        min(user.longitude, shop.longitude),
      ),
      northeast: LatLng(
        max(user.latitude, shop.latitude),
        max(user.longitude, shop.longitude),
      ),
    );
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  void _openGoogleMaps() async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${ApiConfig.shopLat},${ApiConfig.shopLng}'
      '&travelmode=driving',
    );
    if (await canLaunchUrl(url)) launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Shop Location'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? _buildError()
          : Column(
              children: [
                _buildDistanceCard(),
                Expanded(child: _buildMap()),
                _buildBottomCard(),
              ],
            ),
    );
  }

  Widget _buildDistanceCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.location_on, color: Color(0xFF059669)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocationUtils.formatDistance(_distanceKm!),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF059669),
                  ),
                ),
                Text(
                  'from our shop',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          // Estimated time (rough: 30km/h average)
          Column(
            children: [
              const Icon(
                Icons.directions_car,
                color: Color(0xFF6B7280),
                size: 16,
              ),
              Text(
                '~${((_distanceKm! / 30) * 60).toInt()} min',
                style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      onMapCreated: _mapController.complete,
      initialCameraPosition: CameraPosition(target: _shopLocation, zoom: 13),
      markers: _markers,
      polylines: _polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
    );
  }

  Widget _buildBottomCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ApiConfig.shopName,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            ApiConfig.shopAddress,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _openGoogleMaps,
              icon: const Icon(Icons.directions),
              label: const Text('Get Directions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(_errorMessage, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadUserLocation,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
