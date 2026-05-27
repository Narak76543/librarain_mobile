import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mobile_s2_flutter/core/network/api_config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import the existing dio client. If it doesn't exist, we will use a new Dio or the one from OrderRepository.
// Since OrderRepository creates its own Dio with interceptors, I'll use a new Dio and apply auth.

class InvoiceRepository {
  final Dio _dio;

  InvoiceRepository()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      ) {
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

  Future<String> downloadInvoice(String orderId) async {
    // Request storage permission
    if (Platform.isAndroid) {
      await Permission.storage.request();
      // On Android 13+, photos/videos/audio permissions replaced storage, but for downloads,
      // apps can often write to MediaStore or public Download dir without permission,
      // but we still request standard storage just in case.
    }
    
    Directory? dir;
    if (Platform.isAndroid) {
      dir = Directory('/storage/emulated/0/Download');
      if (!await dir.exists()) {
        dir = await getExternalStorageDirectory();
      }
    } else {
      dir = await getApplicationDocumentsDirectory();
    }
    
    final filename = "invoice_${orderId.substring(0, 8).toUpperCase()}.pdf";
    final filepath = "${dir!.path}/$filename";

    // Download PDF
    await _dio.download(
      ApiConfig.orderInvoice(orderId),
      filepath,
      options: Options(
        responseType: ResponseType.bytes,
        headers: {'Accept': 'application/pdf'},
      ),
    );

    return filepath;
  }

  Future<void> openInvoice(String filepath) async {
    await OpenFilex.open(filepath);
  }
}
