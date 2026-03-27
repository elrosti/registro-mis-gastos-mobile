import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? profilePictureUrl;
  final bool isOAuthUser;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.profilePictureUrl,
    this.isOAuthUser = false,
  });

  String get displayName => name ?? email.split('@').first;

  @override
  List<Object?> get props => [id, email, name, profilePictureUrl, isOAuthUser];
}
