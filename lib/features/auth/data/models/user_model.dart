import 'dart:convert';
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.profilePictureUrl,
    super.isOAuthUser,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      profilePictureUrl: json['profilePictureUrl'] ?? json['profile_picture_url'],
      isOAuthUser: json['oauthUser'] ?? json['oauth_user'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profilePictureUrl': profilePictureUrl,
      'oauthUser': isOAuthUser,
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      profilePictureUrl: user.profilePictureUrl,
      isOAuthUser: user.isOAuthUser,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory UserModel.fromJsonString(String jsonString) {
    return UserModel.fromJson(jsonDecode(jsonString));
  }
}

class AuthResponseModel {
  final String token;
  final String tokenType;
  final int expiresIn;
  final UserModel user;

  AuthResponseModel({
    required this.token,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] ?? '',
      tokenType: json['tokenType'] ?? 'Bearer',
      expiresIn: json['expiresIn'] ?? 3600,
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }
}

class GoogleOAuthResponseModel {
  final String authorizationUrl;
  final String state;

  GoogleOAuthResponseModel({
    required this.authorizationUrl,
    required this.state,
  });

  factory GoogleOAuthResponseModel.fromJson(Map<String, dynamic> json) {
    return GoogleOAuthResponseModel(
      authorizationUrl: json['authorizationUrl'] ?? json['authorization_url'] ?? '',
      state: json['state'] ?? '',
    );
  }
}
