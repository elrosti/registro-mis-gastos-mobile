import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class Register {
  final AuthRepository repository;

  Register(this.repository);

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
    String? name,
  }) {
    return repository.register(
      email: email,
      password: password,
      name: name,
    );
  }
}

class Login {
  final AuthRepository repository;

  Login(this.repository);

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
    bool rememberMe = false,
  }) {
    return repository.login(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );
  }
}

class LoginWithGoogle {
  final AuthRepository repository;

  LoginWithGoogle(this.repository);

  Future<Either<Failure, User>> call({
    required String idToken,
    required String accessToken,
    required String state,
  }) {
    return repository.loginWithGoogle(
      idToken: idToken,
      accessToken: accessToken,
      state: state,
    );
  }
}

class Logout {
  final AuthRepository repository;

  Logout(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.logout();
  }
}

class GetCurrentUser {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  Future<Either<Failure, User>> call() {
    return repository.getCurrentUser();
  }
}

class CheckAuthStatus {
  final AuthRepository repository;

  CheckAuthStatus(this.repository);

  Future<Either<Failure, bool>> call() {
    return repository.isLoggedIn();
  }
}

class GetGoogleOAuthUrl {
  final AuthRepository repository;

  GetGoogleOAuthUrl(this.repository);

  Future<Either<Failure, String>> call({bool rememberMe = false}) {
    return repository.getGoogleOAuthUrl(rememberMe: rememberMe);
  }
}
