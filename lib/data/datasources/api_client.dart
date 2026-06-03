import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final Dio dio = Dio(BaseOptions(
    baseUrl: 'https://TON-BACKEND.com/api', // ← CHANGE ICI
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  final _storage = const FlutterSecureStorage();

  Future<void> init() async {
    // Intercepteur JWT
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwt_token');
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expiré → logout ou refresh
          await _storage.delete(key: 'jwt_token');
          // Rediriger vers login (à implémenter)
        }
        return handler.next(error);
      },
    ));
  }

  Future<void> setToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }
}