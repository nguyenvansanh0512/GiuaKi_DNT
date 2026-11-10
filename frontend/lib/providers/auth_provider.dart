import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService service;
  bool loading = false;
  String? error;
  Timer? _expiry;
  bool get authenticated => service.api.token != null;
  AuthProvider(this.service) {
    service.api.onUnauthorized = logout;
  }
  Future<void> login(String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await service.login(email, password);
      _expiry?.cancel();
      _expiry = Timer(const Duration(hours: 2), logout);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void logout() {
    _expiry?.cancel();
    service.logout();
    error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _expiry?.cancel();
    service.api.onUnauthorized = null;
    super.dispose();
  }
}
