import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../data/models/book_model.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../data/repositories/order_repository.dart';

class CartViewModel extends ChangeNotifier {
  CartViewModel({CartRepository? cartRepository})
      : _cartRepository = cartRepository ?? CartRepository();

  final CartRepository _cartRepository;

  List<CartItemModel> _items = [];
  bool _isLoading = false;
  String? _error;
  String _deliveryWay = 'Pick Up';
  String? _deliveryPartner;
  String? _deliveryAddress;
  String _paymentMethod = 'KHQR';

  List<CartItemModel> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get deliveryWay => _deliveryWay;
  String? get deliveryPartner => _deliveryPartner;
  String? get deliveryAddress => _deliveryAddress;
  String get paymentMethod => _paymentMethod;

  void setDeliveryWay(String way) {
    _deliveryWay = way;
    if (way == 'Pick Up') {
      _deliveryPartner = null;
      _deliveryAddress = null;
    }
    notifyListeners();
  }

  void setDeliveryPartner(String? partner) {
    _deliveryPartner = partner;
    notifyListeners();
  }

  void setDeliveryAddress(String address) {
    _deliveryAddress = address;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  double get subtotal {
    double total = 0.0;
    for (final item in _items) {
      final priceStr = item.book.price.replaceAll('\$', '').trim();
      final price = double.tryParse(priceStr) ?? 0.0;
      total += price * item.quantity;
    }
    return total;
  }

  Future<void> fetchCart() async {
    _setLoading(true);
    try {
      _items = await _cartRepository.getCart();
      _error = null;
    } on CartException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addToCart(BookModel book) async {
    _setLoading(true);
    try {
      await _cartRepository.addToCart(book.id, 1);
      await fetchCart(); // Refresh cart to get the new state and item IDs
    } on CartException catch (e) {
      _error = e.message;
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> removeFromCart(String itemId) async {
    _setLoading(true);
    try {
      await _cartRepository.removeFromCart(itemId);
      await fetchCart();
    } on CartException catch (e) {
      _error = e.message;
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> increaseQuantity(String itemId) async {
    final item = _items.firstWhere((i) => i.id == itemId);
    _setLoading(true);
    try {
      await _cartRepository.updateCartItem(itemId, item.quantity + 1);
      await fetchCart();
    } on CartException catch (e) {
      _error = e.message;
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> decreaseQuantity(String itemId) async {
    final item = _items.firstWhere((i) => i.id == itemId);
    if (item.quantity > 1) {
      _setLoading(true);
      try {
        await _cartRepository.updateCartItem(itemId, item.quantity - 1);
        await fetchCart();
      } on CartException catch (e) {
        _error = e.message;
        _setLoading(false);
        rethrow;
      }
    } else {
      await removeFromCart(itemId);
    }
  }

  Future<void> clearCart() async {
    _setLoading(true);
    try {
      await _cartRepository.clearCart();
      _items.clear();
      _error = null;
    } on CartException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> autoDetectLocation() async {
    _setLoading(true);
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));
      
      double? lat;
      double? lng;
      String? formattedAddress;

      // 1. Query Google Geolocation API using the provided API Key
      try {
        final geoResponse = await dio.post<dynamic>(
          'https://www.googleapis.com/geolocation/v1/geolocate?key=AIzaSyBMomse-7qenHBhXCe6iaq8UUCgY6LQ2jc',
          data: {},
        );
        if (geoResponse.statusCode == 200 && geoResponse.data != null) {
          final location = geoResponse.data['location'];
          if (location != null) {
            lat = double.tryParse(location['lat'].toString());
            lng = double.tryParse(location['lng'].toString());
          }
        }
      } catch (e) {
        debugPrint('Google Geolocation failed: $e');
      }

      // 2. Query Google Geocoding API if we successfully retrieved coordinates
      if (lat != null && lng != null) {
        try {
          final geocodeResponse = await dio.get<dynamic>(
            'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=AIzaSyBMomse-7qenHBhXCe6iaq8UUCgY6LQ2jc',
          );
          if (geocodeResponse.statusCode == 200 && geocodeResponse.data != null) {
            final results = geocodeResponse.data['results'] as List?;
            if (results != null && results.isNotEmpty) {
              formattedAddress = results[0]['formatted_address'] as String?;
            }
          }
        } catch (e) {
          debugPrint('Google Geocoding failed: $e');
        }
      }

      // 3. Fallback to free IP-based API if Google APIs failed to resolve a readable address
      if (formattedAddress == null || formattedAddress.isEmpty) {
        try {
          final fallbackResponse = await dio.get<dynamic>('http://ip-api.com/json');
          if (fallbackResponse.statusCode == 200 && fallbackResponse.data != null) {
            final data = fallbackResponse.data;
            final city = data['city'] as String?;
            final region = data['regionName'] as String?;
            final country = data['country'] as String?;
            final latVal = data['lat'];
            final lonVal = data['lon'];
            
            if (city != null && country != null) {
              formattedAddress = '$city, $region, $country ($latVal, $lonVal) (IP-based)';
            }
          }
        } catch (e) {
          debugPrint('Fallback IP Geolocation failed: $e');
        }
      }

      if (formattedAddress != null && formattedAddress.isNotEmpty) {
        _deliveryAddress = formattedAddress;
        _error = null;
      } else {
        _error = 'Could not automatically detect location. Please type manually.';
      }
    } catch (e) {
      _error = 'Location detection failed: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> placeOrder() async {
    _setLoading(true);
    try {
      final orderRepo = OrderRepository();
      final orderId = await orderRepo.placeOrder(
        deliveryWay: _deliveryWay,
        deliveryPartner: _deliveryPartner,
        deliveryAddress: _deliveryWay == 'Delivery' ? _deliveryAddress : null,
        paymentMethod: _paymentMethod,
      );
      if (orderId != null) {
        // Capture details for confirmed screen
        final details = {
          'orderId': orderId,
          'orderTotal': subtotal,
          'orderItems': _items.map((i) => i.book).toList(),
          'deliveryWay': _deliveryWay,
          'deliveryPartner': _deliveryPartner,
          'deliveryAddress': _deliveryWay == 'Delivery' ? _deliveryAddress : null,
          'paymentMethod': _paymentMethod,
        };
        _items.clear();
        _error = null;
        _deliveryAddress = null; // Clear address on success
        return details;
      }
      return null;
    } on OrderException catch (e) {
      _error = e.message;
      return null;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
