import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> deleteUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _secureStorage;

  AuthLocalDataSourceImpl({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  @override
  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: AppConstants.tokenKey, value: token);
    } catch (e) {
      throw CacheException(message: 'Failed to save token: $e');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: AppConstants.tokenKey);
    } catch (e) {
      throw CacheException(message: 'Failed to get token: $e');
    }
  }

  @override
  Future<void> deleteToken() async {
    try {
      await _secureStorage.delete(key: AppConstants.tokenKey);
    } catch (e) {
      throw CacheException(message: 'Failed to delete token: $e');
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      await _secureStorage.write(
        key: AppConstants.userKey,
        value: user.toJsonString(),
      );
    } catch (e) {
      throw CacheException(message: 'Failed to save user: $e');
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      final jsonString = await _secureStorage.read(key: AppConstants.userKey);
      if (jsonString == null) return null;
      return UserModel.fromJsonString(jsonString);
    } catch (e) {
      throw CacheException(message: 'Failed to get user: $e');
    }
  }

  @override
  Future<void> deleteUser() async {
    try {
      await _secureStorage.delete(key: AppConstants.userKey);
    } catch (e) {
      throw CacheException(message: 'Failed to delete user: $e');
    }
  }
}
