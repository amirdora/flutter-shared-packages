import 'package:equatable/equatable.dart';

/// Authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check authentication status
class CheckAuthStatus extends AuthEvent {}

/// Sign up with email
class SignUpWithEmail extends AuthEvent {
  final String email;
  final String password;
  final String? name;

  const SignUpWithEmail({
    required this.email,
    required this.password,
    this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

/// Confirm email
class ConfirmEmail extends AuthEvent {
  final String email;
  final String code;

  const ConfirmEmail({required this.email, required this.code});

  @override
  List<Object?> get props => [email, code];
}

/// Resend confirmation code
class ResendConfirmationCode extends AuthEvent {
  final String email;

  const ResendConfirmationCode(this.email);

  @override
  List<Object?> get props => [email];
}

/// Sign in with email
class SignInWithEmail extends AuthEvent {
  final String email;
  final String password;

  const SignInWithEmail({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Sign in with Apple
class SignInWithApple extends AuthEvent {}

/// Forgot password
class ForgotPassword extends AuthEvent {
  final String email;

  const ForgotPassword(this.email);

  @override
  List<Object?> get props => [email];
}

/// Confirm forgot password
class ConfirmForgotPassword extends AuthEvent {
  final String email;
  final String code;
  final String newPassword;

  const ConfirmForgotPassword({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [email, code, newPassword];
}

/// Sign out
class SignOut extends AuthEvent {}
