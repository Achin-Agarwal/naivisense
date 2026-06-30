class AppConstants {
  AppConstants._();

  // API — swap to prod URL before release
  // static const String baseUrl = 'http://10.0.2.2:8000/api/v1'; // Android emulator
  // static const String baseUrl = 'http://localhost:8000/api/v1'; // iOS simulator / macOS
  // static const String baseUrl = 'https://api.naivisense.in/api/v1'; // production
  static const String baseUrl = 'http://192.168.1.4:8000/api/v1';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Secure storage keys
  static const String keyAccessToken  = 'ns_access_token';
  static const String keyRefreshToken = 'ns_refresh_token';
  static const String keyUserRole     = 'ns_user_role';
  static const String keyUserId       = 'ns_user_id';

  // Hive boxes
  static const String boxPendingProofs = 'pending_proofs';

  // Rating scale
  static const int ratingMin = 1;
  static const int ratingMax = 10;
  static const int pageSize  = 20;
}
