import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/api_config.dart';
import '../models/user_profile_model.dart';

class ProfileException implements Exception {
  const ProfileException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;
}

class ProfileRepository {
  ProfileRepository({Dio? dio})
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

  Future<UserProfileModel> getProfile() async {
    try {
      final response = await _sendWithAuthRetry(
        () async => _dio.get<dynamic>(
          ApiConfig.getProfile,
          options: await _authOptions(),
        ),
      );

      return _profileFromResponse(response.data);
    } on DioException catch (error) {
      throw ProfileException(
        _getErrorMessage(error),
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<UserProfileModel> updateProfile(
    UserProfileUpdateRequest request,
  ) async {
    try {
      final response = await _sendWithAuthRetry(
        () async => _dio.put<dynamic>(
          ApiConfig.updateProfile,
          data: request.toJson(),
          options: await _authOptions(),
        ),
      );

      return _profileFromResponse(response.data);
    } on DioException catch (error) {
      throw ProfileException(
        _getErrorMessage(error),
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<UserProfileModel> uploadAvatar(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          contentType: DioMediaType('image', _imageSubtype(imageFile.path)),
        ),
      });

      final response = await _sendWithAuthRetry(
        () async => _dio.post<dynamic>(
          ApiConfig.uploadAvatar,
          data: formData,
          options: await _authOptions(
            contentType: Headers.multipartFormDataContentType,
          ),
        ),
      );

      return _profileFromResponse(response.data);
    } on DioException catch (error) {
      throw ProfileException(
        _getErrorMessage(error),
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<Options> _authOptions({String? contentType}) async {
    final token = await _getAuthToken();
    if (token == null || token.isEmpty) {
      throw const ProfileException('Please login again.', statusCode: 401);
    }

    return Options(
      contentType: contentType,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<Response<dynamic>> _sendWithAuthRetry(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (error) {
      if (error.response?.statusCode != 401) rethrow;

      final didRefresh = await _refreshAccessToken();
      if (!didRefresh) {
        await _clearAuthSession();
        rethrow;
      }

      return request();
    }
  }

  UserProfileModel _profileFromResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      final responseData = data['data'];
      if (responseData is Map<String, dynamic>) {
        final profile = responseData['profile'];
        if (profile is Map<String, dynamic>) {
          return UserProfileModel.fromJson(_mergeUserAndProfile(responseData));
        }

        final user = responseData['user'];
        if (user is Map<String, dynamic>) {
          final userProfile = user['profile'];
          if (userProfile is Map<String, dynamic>) {
            return UserProfileModel.fromJson(_mergeUserAndProfile(user));
          }
        }

        return UserProfileModel.fromJson(responseData);
      }

      final profile = data['profile'];
      if (profile is Map<String, dynamic>) {
        return UserProfileModel.fromJson(_mergeUserAndProfile(data));
      }

      return UserProfileModel.fromJson(data);
    }

    throw const ProfileException('Invalid profile response');
  }

  Map<String, dynamic> _mergeUserAndProfile(Map<String, dynamic> userData) {
    final profile = userData['profile'];
    if (profile is! Map<String, dynamic>) return userData;

    final user = userData['user'];
    final userMap = user is Map<String, dynamic> ? user : userData;

    return {
      ...userMap,
      ...profile,
      'phone': profile['phone'] ?? userMap['phone'] ?? userData['phone'],
      'user_id':
          profile['user_id'] ??
          userMap['id'] ??
          userMap['user_id'] ??
          userData['id'] ??
          userData['user_id'],
    };
  }

  Future<String?> _getAuthToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString('access_token') ??
        preferences.getString('token') ??
        preferences.getString('accessToken');
  }

  Future<bool> _refreshAccessToken() async {
    final preferences = await SharedPreferences.getInstance();
    final refreshToken =
        preferences.getString('refresh_token') ??
        preferences.getString('refreshToken');
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final response = await _dio.post<dynamic>(
        ApiConfig.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) return false;

      final responseData = data['data'];
      if (responseData is! Map<String, dynamic>) return false;

      final newAccessToken =
          responseData['accessToken'] ?? responseData['access_token'];
      final newRefreshToken =
          responseData['refreshToken'] ?? responseData['refresh_token'];

      if (newAccessToken is! String || newAccessToken.isEmpty) return false;

      await preferences.setString('access_token', newAccessToken);
      if (newRefreshToken is String && newRefreshToken.isNotEmpty) {
        await preferences.setString('refresh_token', newRefreshToken);
      }

      return true;
    } on DioException {
      return false;
    }
  }

  Future<void> _clearAuthSession() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('access_token');
    await preferences.remove('token');
    await preferences.remove('accessToken');
    await preferences.remove('refresh_token');
    await preferences.remove('refreshToken');
    await preferences.setBool('is_logged_in', false);
  }

  String _imageSubtype(String path) {
    final lowerPath = path.toLowerCase();
    if (lowerPath.endsWith('.png')) return 'png';
    if (lowerPath.endsWith('.webp')) return 'webp';
    return 'jpeg';
  }

  String _getErrorMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['detail'] ?? data['message'] ?? data['error'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    if (error.response?.statusCode == 401) {
      return 'Please login again.';
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please try again.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Cannot connect to server.';
    }

    return 'Profile request failed';
  }

  void _addDebugInterceptor() {
    if (!kDebugMode) return;

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('================ API REQUEST ================');
          debugPrint('METHOD: ${options.method}');
          debugPrint('URL: ${options.baseUrl}${options.path}');
          debugPrint('HEADERS: ${jsonEncode(options.headers)}');
          debugPrint('BODY: ${_debugBody(options.data)}');
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
          debugPrint('REQUEST BODY: ${_debugBody(error.requestOptions.data)}');
          debugPrint('ERROR RESPONSE: ${jsonEncode(error.response?.data)}');
          debugPrint('MESSAGE: ${error.message}');
          debugPrint('=============================================');

          return handler.next(error);
        },
      ),
    );
  }

  String _debugBody(dynamic data) {
    if (data == null) return 'null';

    if (data is FormData) {
      final fields = data.fields.map((field) => field.key).join(', ');
      final files = data.files
          .map((file) {
            return '${file.key}:${file.value.filename ?? 'file'}';
          })
          .join(', ');

      return 'FormData(fields: [$fields], files: [$files])';
    }

    try {
      return jsonEncode(data);
    } catch (_) {
      return data.toString();
    }
  }
}
