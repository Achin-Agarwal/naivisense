import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import 'storage_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(_AuthInterceptor());
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? params,
  }) async {
    try {
      // print("GET REQUEST: $path");

      final res = await _dio.get<T>(path, queryParameters: params);

      // print("STATUS: ${res.statusCode}");
      // print("TYPE: ${res.data.runtimeType}");
      // print("BODY:");
      // print(res.data);

      return res;
    } on DioException catch (e) {
      print("DIO ERROR");
      print("STATUS: ${e.response?.statusCode}");
      print("BODY:");
      print(e.response?.data);

      rethrow;
    }
  }

  Future<Response<T>> post<T>(String path, {dynamic data}) async {
    try {
      final res = await _dio.post<T>(path, data: data);
      return res;
    } catch (e) {
      print("❌ API ERROR: $e");
      rethrow;
    }
  }

  Future<Response<T>> put<T>(String path, {dynamic data}) =>
      _dio.put<T>(path, data: data);

  Future<Response<T>> patch<T>(String path, {dynamic data}) =>
      _dio.patch<T>(path, data: data);

  Future<Response<T>> delete<T>(String path) => _dio.delete<T>(path);

  Future<Response<T>> postForm<T>(String path, FormData data) async {
    try {
      final res = await _dio.post<T>(path, data: data);
      return res;
    } on DioException catch (e) {
      print("❌ FORM ERROR STATUS: ${e.response?.statusCode}");
      print("❌ FORM ERROR BODY: ${e.response?.data}");
      print("❌ FORM ERROR HEADERS: ${e.response?.headers}");

      rethrow;
    }
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await StorageService.instance.getAccessToken();
    print("TOKEN = $token");
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        final token = await StorageService.instance.getAccessToken();
        err.requestOptions.headers['Authorization'] = 'Bearer $token';
        final retry = await Dio().fetch(err.requestOptions);
        return handler.resolve(retry);
      }
    }
    handler.next(err);
  }

  Future<bool> _tryRefresh() async {
    try {
      final refresh = await StorageService.instance.getRefreshToken();
      if (refresh == null) return false;
      final res = await Dio().post(
        '${AppConstants.baseUrl}/auth/refresh',
        data: {'refresh_token': refresh},
      );
      final data = res.data as Map<String, dynamic>;
      await StorageService.instance.saveTokens(
        access: (data['access_token'] ?? data['accessToken']) as String,
        refresh: (data['refresh_token'] ?? data['refreshToken']) as String,
      );
      return true;
    } catch (_) {
      await StorageService.instance.clearAll();
      return false;
    }
  }
}
