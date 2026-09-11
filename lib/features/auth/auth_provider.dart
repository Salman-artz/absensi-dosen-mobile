import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';

enum AuthStatus { initial, unauthenticated, loading, authenticated }

class AuthState {
  final AuthStatus status;
  final String? role;
  final String? error;

  AuthState({this.status = AuthStatus.initial, this.role, this.error});

  AuthState copyWith({AuthStatus? status, String? role, String? error}) {
    return AuthState(
      status: status ?? this.status,
      role: role ?? this.role,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final storage = ref.read(storageProvider);
    final token = await storage.read(key: 'access_token');
    if (token != null && !JwtDecoder.isExpired(token)) {
      final decodedToken = JwtDecoder.decode(token);
      state = state.copyWith(status: AuthStatus.authenticated, role: decodedToken['role']);
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final accessToken = res.data['data']['accessToken'];
      final refreshToken = res.data['data']['refreshToken'];
      
      final storage = ref.read(storageProvider);
      await storage.write(key: 'access_token', value: accessToken);
      await storage.write(key: 'refresh_token', value: refreshToken);

      final decodedToken = JwtDecoder.decode(accessToken);
      state = state.copyWith(status: AuthStatus.authenticated, role: decodedToken['role']);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Terjadi kesalahan jaringan';
      state = state.copyWith(status: AuthStatus.unauthenticated, error: msg.toString());
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  Future<void> logout() async {
    final storage = ref.read(storageProvider);
    await storage.deleteAll();
    state = state.copyWith(status: AuthStatus.unauthenticated, role: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
