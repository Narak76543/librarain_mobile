import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/network/api_config.dart';
import '../models/cart_item_model.dart';
// To get the auth interceptor logic or use SharedPreferences if needed
// Actually, it's better to just reuse a Dio instance with auth interceptors, but we'll instantiate one with headers if needed.
import 'package:shared_preferences/shared_preferences.dart';

class CartException implements Exception {
  const CartException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;
}

class CartRepository {
  CartRepository({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: const {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
            ),
          ) {
    _addAuthInterceptor();
    if (kDebugMode) {
      _addDebugInterceptor();
    }
  }

  final Dio _dio;

  void _addAuthInterceptor() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  void _addDebugInterceptor() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('================ CART API REQUEST ================');
          debugPrint('URL: ${options.baseUrl}${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('================ CART API RESPONSE ===============');
          debugPrint('STATUS: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('================ CART API ERROR ==================');
          debugPrint('STATUS: ${error.response?.statusCode}');
          debugPrint('MESSAGE: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  String _getErrorMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['detail'] ?? data['error'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }
    return 'Cart operation failed';
  }

  Future<List<CartItemModel>> getCart() async {
    try {
      final response = await _dio.get<dynamic>(ApiConfig.cart);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null &&
            data['data'] != null &&
            data['data']['items'] != null) {
          final itemsList = data['data']['items'] as List;
          return itemsList
              .map(
                (item) => CartItemModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw CartException(
        _getErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<CartItemModel> addToCart(String bookId, int quantity) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiConfig.cartItems,
        data: {'book_id': bookId, 'quantity': quantity},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data != null && data['data'] != null) {
          return CartItemModel.fromJson(data['data'] as Map<String, dynamic>);
        }
      }
      throw const CartException('Failed to add to cart');
    } on DioException catch (e) {
      throw CartException(
        _getErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<CartItemModel> updateCartItem(String itemId, int quantity) async {
    try {
      final response = await _dio.put<dynamic>(
        '${ApiConfig.cartItems}/$itemId',
        data: {'quantity': quantity},
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['data'] != null) {
          return CartItemModel.fromJson(data['data'] as Map<String, dynamic>);
        }
      }
      throw const CartException('Failed to update cart item');
    } on DioException catch (e) {
      throw CartException(
        _getErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<bool> removeFromCart(String itemId) async {
    try {
      final response = await _dio.delete<dynamic>(
        '${ApiConfig.cartItems}/$itemId',
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw CartException(
        _getErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<bool> clearCart() async {
    try {
      final response = await _dio.delete<dynamic>(ApiConfig.cart);
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw CartException(
        _getErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }
}
