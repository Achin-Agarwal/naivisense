import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();
  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  Future<void> _write(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> _read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> _deleteAll() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();

    if (!kIsWeb) {
      await _secure.deleteAll();
    }
  }

  Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(AppConstants.keyAccessToken, access);

      await prefs.setString(AppConstants.keyRefreshToken, refresh);
    } else {
      await _secure.write(key: AppConstants.keyAccessToken, value: access);

      await _secure.write(key: AppConstants.keyRefreshToken, value: refresh);
    }
  }

  Future<String?> getAccessToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();

      return prefs.getString(AppConstants.keyAccessToken);
    }

    return _secure.read(key: AppConstants.keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();

      return prefs.getString(AppConstants.keyRefreshToken);
    }

    return _secure.read(key: AppConstants.keyRefreshToken);
  }

  Future<void> saveRole(String role) => _write(AppConstants.keyUserRole, role);
  Future<String?> getRole() => _read(AppConstants.keyUserRole);

  Future<void> saveUserId(String id) => _write(AppConstants.keyUserId, id);
  Future<String?> getUserId() => _read(AppConstants.keyUserId);

  Future<void> clearAll() => _deleteAll();
}
