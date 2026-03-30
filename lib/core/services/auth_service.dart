import 'dart:async';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final StreamController<void> _tokenExpiredController =
      StreamController<void>.broadcast();

  Stream<void> get onTokenExpired => _tokenExpiredController.stream;

  void notifyTokenExpired() {
    _tokenExpiredController.add(null);
  }

  void dispose() {
    _tokenExpiredController.close();
  }
}

final authService = AuthService();
