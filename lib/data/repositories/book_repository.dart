import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/network/api_config.dart';
import '../models/book_model.dart';

class BookRepository {
  BookRepository({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: const {'Accept': 'application/json'},
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
          debugPrint('================ BOOK API REQUEST ================');
          debugPrint('METHOD: \${options.method}');
          debugPrint('URL: \${options.baseUrl}\${options.path}');
          debugPrint('QUERY: \${options.queryParameters}');
          debugPrint('HEADERS: \${options.headers}');
          debugPrint('=============================================');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('================ BOOK API RESPONSE ===============');
          debugPrint('STATUS: \${response.statusCode}');
          debugPrint('DATA: \${response.data}');
          debugPrint('=============================================');
          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('================ BOOK API ERROR ==================');
          debugPrint('STATUS: \${error.response?.statusCode}');
          debugPrint('URL: \${error.requestOptions.uri}');
          debugPrint('ERROR RESPONSE: \${error.response?.data}');
          debugPrint('=============================================');
          return handler.next(error);
        },
      ),
    );
  }

  Future<List<BookModel>> getBooks({String? category, bool? featured, String? search, String? sort}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null && category.isNotEmpty && category != 'All') {
        // Convert category name to slug (e.g. "Science Fiction" -> "science-fiction")
        queryParams['category'] = category.toLowerCase().replaceAll(' ', '-');
      }
      if (featured != null) {
        queryParams['featured'] = featured;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (sort != null && sort.isNotEmpty) {
        queryParams['sort'] = sort;
      }

      final response = await _dio.get<dynamic>(
        ApiConfig.books,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final responseData = data['data'];
        if (responseData is Map<String, dynamic>) {
          final booksData = responseData['books'];
          if (booksData is List) {
            return booksData
                .whereType<Map<String, dynamic>>()
                .map(BookModel.fromJson)
                .toList();
          }
        }
        if (responseData is List) {
          return responseData
              .whereType<Map<String, dynamic>>()
              .map(BookModel.fromJson)
              .toList();
        }
      } else if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(BookModel.fromJson)
            .toList();
      }

      return const [];
    } on DioException catch (e) {
      final errorData = e.response?.data;
      throw Exception('DioError: ${e.message}. Data: $errorData');
    }
  }
}
