import 'dart:convert';
import 'dart:math';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<bool> loginWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId:
            '632874416504-30ue2elf9c0prf8g5fjd1k0lsqe28u6m.apps.googleusercontent.com',
      );

      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) {
        return false;
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null) {
        throw const AuthException('Failed to retrieve Google ID token.');
      }

      final response = await _dio.post<dynamic>(
        ApiConfig.googleLogin,
        data: {'id_token': idToken},
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
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Google Sign-In failed: $e');
    }
  }

  Future<bool> loginWithTelegram() async {
    try {
      final String loginToken =
          '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(100000)}';

      debugPrint('[Telegram Login] Generated token: $loginToken');
      debugPrint(
        '[Telegram Login] Opening bot: https://t.me/${ApiConfig.telegramBotUsername}?start=login_$loginToken',
      );

      final url = Uri.parse(
        'https://t.me/${ApiConfig.telegramBotUsername}?start=login_$loginToken',
      );
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw const AuthException('Could not open Telegram app');
      }

      // Start polling for the login status
      for (int i = 0; i < 30; i++) {
        // Poll for up to 60 seconds
        await Future.delayed(const Duration(seconds: 2));

        debugPrint('[Telegram Login] Polling attempt ${i + 1}/30...');

        try {
          final response = await _dio.get<dynamic>(
            ApiConfig.telegramLoginStatus,
            queryParameters: {'token': loginToken},
          );

          debugPrint('[Telegram Login] Poll response: ${response.statusCode}');

          if (response.statusCode == 200) {
            debugPrint('[Telegram Login] Login successful!');
            await _saveAuthToken(response.data);
            return true;
          }
        } on DioException catch (e) {
          debugPrint(
            '[Telegram Login] Poll error: ${e.message} (${e.response?.statusCode})',
          );

          if (e.response?.statusCode == 400) {
            // Pending
            continue;
          }
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.connectionError) {
            // Network might be paused while app is in background, ignore and continue
            continue;
          }
          rethrow;
        }
      }

      debugPrint('[Telegram Login] Login timed out after 60 seconds');
      throw const AuthException('Login timed out. Please try again.');
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Telegram login failed: $e');
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

  Future<bool> forgotPassword({required String email, String? channel}) async {
    try {
      final Map<String, dynamic> requestData = {'email': email};
      if (channel != null) {
        requestData['channel'] = channel;
      }

      final response = await _dio.post<dynamic>(
        ApiConfig.forgotPassword,
        data: requestData,
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
