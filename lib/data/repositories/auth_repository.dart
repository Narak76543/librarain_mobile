// import 'dart:convert';

// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';

// import '../../core/network/api_config.dart';

// class AuthException implements Exception {
//   const AuthException(this.message);

//   final String message;
// }

// class AuthRepository {
//   AuthRepository({Dio? dio})
//     : _dio =
//           dio ??
//           Dio(
//             BaseOptions(
//               baseUrl: ApiConfig.baseUrl,
//               connectTimeout: const Duration(seconds: 15),
//               receiveTimeout: const Duration(seconds: 15),
//               headers: const {
//                 'Accept': 'application/json',
//                 'Content-Type': 'application/json',
//               },
//             ),
//           );

//   final Dio _dio;

//   void _addDebugInterceptor() {
//     if (!kDebugMode) return;

//     _dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) {
//           debugPrint('================ API REQUEST ================');
//           debugPrint('METHOD: ${options.method}');
//           debugPrint('URL: ${options.baseUrl}${options.path}');
//           debugPrint('HEADERS: ${jsonEncode(options.headers)}');
//           debugPrint('BODY: ${jsonEncode(options.data)}');
//           debugPrint('=============================================');

//           return handler.next(options);
//         },
//         onResponse: (response, handler) {
//           debugPrint('================ API RESPONSE ===============');
//           debugPrint('STATUS: ${response.statusCode}');
//           debugPrint('URL: ${response.requestOptions.uri}');
//           debugPrint('DATA: ${jsonEncode(response.data)}');
//           debugPrint('=============================================');

//           return handler.next(response);
//         },
//         onError: (error, handler) {
//           debugPrint('================ API ERROR ==================');
//           debugPrint('STATUS: ${error.response?.statusCode}');
//           debugPrint('URL: ${error.requestOptions.uri}');
//           debugPrint('REQUEST BODY: ${jsonEncode(error.requestOptions.data)}');
//           debugPrint('ERROR RESPONSE: ${jsonEncode(error.response?.data)}');
//           debugPrint('MESSAGE: ${error.message}');
//           debugPrint('=============================================');

//           return handler.next(error);
//         },
//       ),
//     );
//   }

//   Future<bool> login({required String email, required String password}) async {
//     await Future.delayed(const Duration(milliseconds: 700));

//     // ========== Temporary validation only ===============
//     return email.isNotEmpty && password.length >= 6;
//   }

//   Future<bool> register({
//     required String fullName,
//     required String email,
//     required String phone,
//     required String password,
//   }) async {
//     try {
//       final response = await _dio.post<dynamic>(
//         ApiConfig.register,
//         data: {
//           'full_name': fullName,
//           'email': email,
//           'phone': phone,
//           'password': password,
//         },
//       );

//       final statusCode = response.statusCode ?? 0;
//       return statusCode >= 200 && statusCode < 300;
//     } on DioException catch (error) {
//       throw AuthException(_getErrorMessage(error));
//     }
//   }

//   String _getErrorMessage(DioException error) {
//     final data = error.response?.data;

//     if (data is Map<String, dynamic>) {
//       final message = data['message'] ?? data['detail'] ?? data['error'];
//       if (message is String && message.trim().isNotEmpty) {
//         return message;
//       }
//     }

//     if (error.type == DioExceptionType.connectionTimeout ||
//         error.type == DioExceptionType.receiveTimeout) {
//       return 'Connection timeout. Please try again.';
//     }

//     if (error.type == DioExceptionType.connectionError) {
//       return 'Cannot connect to server.';
//     }

//     return 'Registration failed';
//   }
// }
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_texts.dart';
import '../../core/network/api_config.dart';

class AuthException implements Exception {
  const AuthException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;
}

class AuthRepository {
  AuthRepository({Dio? dio})
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
    _addDebugInterceptor();
  }

  final Dio _dio;

  void _addDebugInterceptor() {
    if (!kDebugMode) return;

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('================ API REQUEST ================');
          debugPrint('METHOD: ${options.method}');
          debugPrint('URL: ${options.baseUrl}${options.path}');
          debugPrint('HEADERS: ${jsonEncode(options.headers)}');
          debugPrint('BODY: ${jsonEncode(options.data)}');
          debugPrint('=============================================');

          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('================ API RESPONSE ===============');
          debugPrint('STATUS: ${response.statusCode}');
          debugPrint('URL: ${response.requestOptions.uri}');
          debugPrint('DATA: ${jsonEncode(response.data)}');
          debugPrint('=============================================');

          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('================ API ERROR ==================');
          debugPrint('STATUS: ${error.response?.statusCode}');
          debugPrint('URL: ${error.requestOptions.uri}');
          debugPrint('REQUEST BODY: ${jsonEncode(error.requestOptions.data)}');
          debugPrint('ERROR RESPONSE: ${jsonEncode(error.response?.data)}');
          debugPrint('MESSAGE: ${error.message}');
          debugPrint('=============================================');

          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiConfig.login,
        data: {'email': email, 'password': password},
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 200 && statusCode < 300) {
        await _saveAuthToken(response.data);
      }
      return statusCode >= 200 && statusCode < 300;
    } on DioException catch (error) {
      throw AuthException(
        _getErrorMessage(error),
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiConfig.register,
        data: {
          'full_name': fullName,
          'email': email,
          'phone': phone,
          'password': password,
        },
      );

      final statusCode = response.statusCode ?? 0;
      return statusCode >= 200 && statusCode < 300;
    } on DioException catch (error) {
      throw AuthException(
        _getErrorMessage(error),
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<bool> forgotPassword({required String email}) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiConfig.forgotPassword,
        data: {'email': email},
      );

      final statusCode = response.statusCode ?? 0;
      return statusCode >= 200 && statusCode < 300;
    } on DioException catch (error) {
      throw AuthException(
        _getErrorMessage(error),
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<bool> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiConfig.verifyOtp,
        data: {'email': email, 'otp_code': otpCode},
      );

      final statusCode = response.statusCode ?? 0;
      return statusCode >= 200 && statusCode < 300;
    } on DioException catch (error) {
      throw AuthException(
        _getErrorMessage(error),
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiConfig.resetPassword,
        data: {'email': email, 'new_password': newPassword},
      );

      final statusCode = response.statusCode ?? 0;
      return statusCode >= 200 && statusCode < 300;
    } on DioException catch (error) {
      throw AuthException(
        _getErrorMessage(error),
        statusCode: error.response?.statusCode,
      );
    }
  }

  String _getErrorMessage(DioException error) {
    switch (error.response?.statusCode) {
      case 401:
        return AppTexts.invalidEmailOrPassword;
      case 423:
        return AppTexts.accountLocked;
    }

    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['detail'] ?? data['error'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please try again.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Cannot connect to server.';
    }

    return 'Authentication failed';
  }

  Future<void> _saveAuthToken(dynamic data) async {
    final accessToken = _extractToken(data);
    final refreshToken = _extractRefreshToken(data);

    final preferences = await SharedPreferences.getInstance();
    if (accessToken != null && accessToken.trim().isNotEmpty) {
      await preferences.setString('access_token', accessToken);
    }
    if (refreshToken != null && refreshToken.trim().isNotEmpty) {
      await preferences.setString('refresh_token', refreshToken);
    }
  }

  String? _extractToken(dynamic data) {
    if (data is! Map) return null;

    final directToken =
        data['access_token'] ?? data['token'] ?? data['accessToken'];
    if (directToken is String) return directToken;

    final nestedData = data['data'];
    if (nestedData is Map) {
      final nestedToken =
          nestedData['access_token'] ??
          nestedData['token'] ??
          nestedData['accessToken'] ??
          nestedData['access'];
      if (nestedToken is String) return nestedToken;

      final nestedTokens = nestedData['tokens'];
      if (nestedTokens is Map) {
        final token =
            nestedTokens['access_token'] ??
            nestedTokens['token'] ??
            nestedTokens['accessToken'] ??
            nestedTokens['access'];
        if (token is String) return token;
      }
    }

    return null;
  }

  String? _extractRefreshToken(dynamic data) {
    if (data is! Map) return null;

    final directToken =
        data['refresh_token'] ?? data['refreshToken'] ?? data['refresh'];
    if (directToken is String) return directToken;

    final nestedData = data['data'];
    if (nestedData is Map) {
      final nestedToken =
          nestedData['refresh_token'] ??
          nestedData['refreshToken'] ??
          nestedData['refresh'];
      if (nestedToken is String) return nestedToken;

      final nestedTokens = nestedData['tokens'];
      if (nestedTokens is Map) {
        final token =
            nestedTokens['refresh_token'] ??
            nestedTokens['refreshToken'] ??
            nestedTokens['refresh'];
        if (token is String) return token;
      }
    }

    return null;
  }
}
