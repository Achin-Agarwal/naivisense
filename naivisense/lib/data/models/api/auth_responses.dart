import '../user.dart';

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> j) {
    return AuthResponse(
      accessToken: j['accessToken'].toString(),
      refreshToken: j['refreshToken'].toString(),
      user: UserModel.fromJson(j['user']),
    );
  }
}
