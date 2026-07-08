import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/error_handler_service.dart';
import '../models/api/auth_requests.dart';
import '../models/api/auth_responses.dart';
import '../models/user.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.read(apiServiceProvider)),
);

class AuthRepository {
  final ApiService _api;
  AuthRepository(this._api);

  Future<AuthResponse> login(LoginRequest req) async {
    try {
      final res = await _api.post('/auth/login', data: req.toJson());
      final auth = AuthResponse.fromJson(res.data as Map<String, dynamic>);
      final access = auth.accessToken;
      final refresh = auth.refreshToken;
      await StorageService.instance.saveTokens(
        access: access,
        refresh: refresh,
      );
      final test = await StorageService.instance.getAccessToken();
      await StorageService.instance.saveRole(auth.user.role);
      await StorageService.instance.saveUserId(auth.user.id);
      return auth;
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<AuthResponse> register(RegisterRequest req) async {
    try {
      final res = await _api.post('/auth/register', data: req.toJson());
      final auth = AuthResponse.fromJson(res.data as Map<String, dynamic>);
      await StorageService.instance.saveTokens(
        access: auth.accessToken,
        refresh: auth.refreshToken,
      );
      await StorageService.instance.saveRole(auth.user.role);
      await StorageService.instance.saveUserId(auth.user.id);
      return auth;
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<UserModel> getMe() async {
    try {
      final res = await _api.get('/auth/me');
      return UserModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {}
    await StorageService.instance.clearAll();
  }
}
