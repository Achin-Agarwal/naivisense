import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user.dart';
import '../../../data/models/api/auth_requests.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/storage_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;
  final bool loading;
  final String? token;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
    this.loading = false,
    this.token,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? error,
    bool? loading,
  }) => AuthState(
    status: status ?? this.status,
    user: user ?? this.user,
    error: error,
    loading: loading ?? this.loading,
  );
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> login(String phone, String password) async {
    state = const AsyncValue.loading();
    try {
      final auth = await ref
          .read(authRepositoryProvider)
          .login(LoginRequest(phone: phone, password: password));

      state = AsyncValue.data(
        AuthState(
          status: AuthStatus.authenticated,
          user: auth.user,
          token: auth.accessToken,
        ),
      );

    } catch (e) {
      state = AsyncValue.data(
        AuthState(status: AuthStatus.unauthenticated, error: e.toString()),
      );
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncValue.data(
      AuthState(status: AuthStatus.unauthenticated),
    );
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
