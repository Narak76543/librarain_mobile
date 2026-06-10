import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile_s2_flutter/core/network/api_config.dart';
import 'package:mobile_s2_flutter/core/theme/app_color.dart';
import 'package:mobile_s2_flutter/core/utils/location_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

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
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
    final points = PolylinePoints(apiKey: apiKey);
    final result = await points.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(from.latitude, from.longitude),
        destination: PointLatLng(to.latitude, to.longitude),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: result.points
                .map((p) => LatLng(p.latitude, p.longitude))
                .toList(),
            color: const Color(0xFF059669),
            width: 4,
          ),
        };
      });
    }
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
