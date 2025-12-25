import 'package:equatable/equatable.dart';

/// Authentication state
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AuthInitial extends AuthState {}

/// Loading state
class AuthLoading extends AuthState {}

/// Authenticated state
class Authenticated extends AuthState {
  final String userId;
  final String email;
  final String? name;

  const Authenticated({required this.userId, required this.email, this.name});

  @override
  List<Object?> get props => [userId, email, name];
}

/// Unauthenticated state
class Unauthenticated extends AuthState {}

/// Email confirmation required
class EmailConfirmationRequired extends AuthState {
  final String email;

  const EmailConfirmationRequired(this.email);

  @override
  List<Object?> get props => [email];
}

/// Authentication error
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
