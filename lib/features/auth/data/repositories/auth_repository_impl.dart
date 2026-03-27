import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await remoteDataSource.register(
        email: email,
        password: password,
        name: name,
      );
      await localDataSource.saveToken(response.token);
      await localDataSource.saveUser(response.user);
      return Right(response.user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final response = await remoteDataSource.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
      await localDataSource.saveToken(response.token);
      await localDataSource.saveUser(response.user);
      return Right(response.user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> loginWithGoogle({
    required String idToken,
    required String accessToken,
    required String state,
  }) async {
    try {
      final response = await remoteDataSource.loginWithGoogle(
        idToken: idToken,
        accessToken: accessToken,
        state: state,
      );
      await localDataSource.saveToken(response.token);
      await localDataSource.saveUser(response.user);
      return Right(response.user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final cachedUser = await localDataSource.getUser();
      if (cachedUser != null) {
        return Right(cachedUser);
      }
      final user = await remoteDataSource.getCurrentUser();
      await localDataSource.saveUser(user);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getGoogleOAuthUrl({bool rememberMe = false}) async {
    try {
      final response = await remoteDataSource.getGoogleOAuthUrl(rememberMe: rememberMe);
      return Right(response.authorizationUrl);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.deleteToken();
      await localDataSource.deleteUser();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final token = await localDataSource.getToken();
      return Right(token != null && token.isNotEmpty);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return const Right(false);
    }
  }
}
