import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_config.dart';
import '../models/wishlist_model.dart';

class WishlistRepository {
  WishlistRepository({Dio? dio})
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

  Future<List<WishlistItem>> getWishlist() async {
    try {
      final response = await _dio.get<dynamic>(ApiConfig.wishlist);
      final data = response.data['data']['items'] as List;
      return data
          .map((json) => WishlistItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      throw Exception(_getErrorMessage(error));
    }
  }

  Future<Map<String, dynamic>> toggleWishlist(String bookId) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiConfig.wishlistToggle,
        data: {'book_id': bookId},
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (error) {
      throw Exception(_getErrorMessage(error));
    }
  }

  Future<void> removeFromWishlist(String bookId) async {
    try {
      await _dio.delete<dynamic>('${ApiConfig.wishlist}/$bookId');
    } on DioException catch (error) {
      throw Exception(_getErrorMessage(error));
    }
  }

  String _getErrorMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['detail'] ?? data['error'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }
    return 'Wishlist operation failed';
  }
}
