abstract class AuthRepository {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<void> saveTokens(String accessToken, String refreshToken);
  Future<String?> getAccessToken();
  Future<void> logout();
}
