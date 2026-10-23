import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../data/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(storageProvider);
  return AuthRepositoryImpl(dio, storage);
});

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
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final token = await _repo.getAccessToken();
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
      final data = await _repo.login(email, password);
      final accessToken = data['accessToken'];
      final refreshToken = data['refreshToken'];

      await _repo.saveTokens(accessToken, refreshToken);

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
    await _repo.logout();
    state = state.copyWith(status: AuthStatus.unauthenticated, role: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});
