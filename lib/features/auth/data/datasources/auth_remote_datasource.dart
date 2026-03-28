import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    String? name,
  });

  Future<AuthResponseModel> login({
    required String email,
    required String password,
    bool rememberMe = false,
  });

  Future<AuthResponseModel> loginWithGoogle({
    required String idToken,
    required String accessToken,
    required String state,
  });

  Future<UserModel> getCurrentUser();

  Future<GoogleOAuthResponseModel> getGoogleOAuthUrl({bool rememberMe = false});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.authRegister,
        data: {
          'email': email,
          'password': password,
          if (name != null) 'name': name,
        },
      );
      return AuthResponseModel.fromJson(response.data);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Registration failed: $e');
    }
  }

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.authLogin,
        data: {
          'email': email,
          'password': password,
          'rememberMe': rememberMe,
        },
      );
      return AuthResponseModel.fromJson(response.data);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Login failed: $e');
    }
  }

  @override
  Future<AuthResponseModel> loginWithGoogle({
    required String idToken,
    required String accessToken,
    required String state,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/oauth/mobile/login/google',
        data: {
          'idToken': idToken,
          'accessToken': accessToken,
        },
      );
      return AuthResponseModel.fromJson(response.data);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Google login failed: $e');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiConstants.authMe);
      return UserModel.fromJson(response.data);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to get user: $e');
    }
  }

  @override
  Future<GoogleOAuthResponseModel> getGoogleOAuthUrl(
      {bool rememberMe = false}) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.authOAuthUrl}/google',
        queryParameters: {'rememberMe': rememberMe},
      );
      return GoogleOAuthResponseModel.fromJson(response.data);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to get Google OAuth URL: $e');
    }
  }
}
