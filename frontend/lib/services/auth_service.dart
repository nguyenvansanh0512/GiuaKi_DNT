import 'api_service.dart';

class AuthService {
  final ApiService api;
  AuthService(this.api);
  Future<void> login(String email, String password) async {
    final data = await api.request(
      'POST',
      '/api/auth/login',
      body: {'email': email.trim(), 'matkhau': password},
    );
    api.token = data['token'] as String;
  }

  void logout() => api.token = null;
}
