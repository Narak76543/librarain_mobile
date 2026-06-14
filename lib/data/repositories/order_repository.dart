import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/api_config.dart';
import '../models/order_model.dart';

class OrderException implements Exception {
  const OrderException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;
}

class OrderRepository {
  OrderRepository({Dio? dio})
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
          debugPrint('================ ORDER API REQUEST ================');
          debugPrint('URL: ${options.baseUrl}${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('================ ORDER API RESPONSE ===============');
          debugPrint('STATUS: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('================ ORDER API ERROR ==================');
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
    return 'Order operation failed';
  }

  Future<String?> placeOrder({
    required String deliveryWay,
    String? deliveryPartner,
    String? deliveryAddress,
    required String paymentMethod,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiConfig.orders,
        data: {
          'delivery_way': deliveryWay,
          'delivery_partner': deliveryPartner,
          'delivery_address': deliveryAddress,
          'payment_method': paymentMethod,
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['data'] != null) {
          final orderData = data['data'];
          if (orderData['id'] != null) {
            return orderData['id'].toString();
          }
        }
        // Fallback if ID is not directly returned but creation succeeded
        return 'NEW_ORDER';
      }
      return null;
    } on DioException catch (e) {
      throw OrderException(
        _getErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<OrderModel>> getOrders() async {
    try {
      final response = await _dio.get<dynamic>(ApiConfig.orders);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null &&
            data['data'] != null &&
            data['data']['orders'] != null) {
          final ordersList = data['data']['orders'] as List;
          return ordersList
              .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw OrderException(
        _getErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<OrderSummaryModel> getOrderSummary(String orderId) async {
    try {
      final response = await _dio.get<dynamic>(ApiConfig.orderSummary(orderId));
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['data'] != null) {
          return OrderSummaryModel.fromJson(data['data']);
        }
      }
      throw const OrderException('Failed to load order summary');
    } on DioException catch (e) {
      throw OrderException(
        _getErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      // Assuming a PATCH request to cancel the order
      final response = await _dio.patch<dynamic>(ApiConfig.cancelOrder(orderId));
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw const OrderException('Failed to cancel order');
      }
    } on DioException catch (e) {
      throw OrderException(
        _getErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }
}
