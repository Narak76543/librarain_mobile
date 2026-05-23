import 'package:dio/dio.dart';

import '../../core/network/api_config.dart';
import '../models/category_model.dart';

class CategoryRepository {
  CategoryRepository({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: const {'Accept': 'application/json'},
            ),
          );

  final Dio _dio;

  Future<List<CategoryModel>> getCategories() async {
    final response = await _dio.get<dynamic>(ApiConfig.categories);
    final data = response.data;

    if (data is Map<String, dynamic>) {
      final responseData = data['data'];
      if (responseData is List) {
        return responseData
            .whereType<Map<String, dynamic>>()
            .map(CategoryModel.fromJson)
            .where((category) => category.name.isNotEmpty)
            .toList();
      }
    }

    return const [];
  }
}
