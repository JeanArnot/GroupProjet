import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static String get baseUrl => kIsWeb ? 'https://groupprojet-production.up.railway.app/api' : 'https://groupprojet-production.up.railway.app/api';

  late final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Dio get client => _dio;

  // Add interceptors for tokens if needed
  void setupInterceptors(String token) {
    _dio.interceptors.clear();
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Authorization'] = 'Bearer $token';
        return handler.next(options);
      },
    ));
  }
}
