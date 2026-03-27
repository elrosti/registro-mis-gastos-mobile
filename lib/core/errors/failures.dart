import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    required super.message,
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, fieldErrors];
}

class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'An unknown error occurred'});
}
