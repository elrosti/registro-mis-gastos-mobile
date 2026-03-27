import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    String? name,
  });

  Future<Either<Failure, User>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  });

  Future<Either<Failure, User>> loginWithGoogle({
    required String idToken,
    required String accessToken,
    required String state,
  });

  Future<Either<Failure, User>> getCurrentUser();

  Future<Either<Failure, String>> getGoogleOAuthUrl({bool rememberMe = false});

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, bool>> isLoggedIn();
}
