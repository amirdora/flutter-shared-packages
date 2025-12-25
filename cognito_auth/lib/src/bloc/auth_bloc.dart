import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/cognito_auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Authentication BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CognitoAuthService _authService;

  AuthBloc({required CognitoAuthService authService})
    : _authService = authService,
      super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SignUpWithEmail>(_onSignUpWithEmail);
    on<ConfirmEmail>(_onConfirmEmail);
    on<ResendConfirmationCode>(_onResendConfirmationCode);
    on<SignInWithEmail>(_onSignInWithEmail);
    on<SignInWithApple>(_onSignInWithApple);
    on<ForgotPassword>(_onForgotPassword);
    on<ConfirmForgotPassword>(_onConfirmForgotPassword);
    on<SignOut>(_onSignOut);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final isAuth = await _authService.isAuthenticated();

      if (isAuth) {
        final userId = await _authService.getCognitoUserId();
        final email = await _authService.getUserEmail();
        final name = await _authService.getUserName();

        if (userId != null && email != null) {
          emit(Authenticated(userId: userId, email: email, name: name));
        } else {
          emit(Unauthenticated());
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignUpWithEmail(
    SignUpWithEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await _authService.signUpWithEmail(
        email: event.email,
        password: event.password,
        name: event.name,
      );

      emit(EmailConfirmationRequired(event.email));
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  Future<void> _onConfirmEmail(
    ConfirmEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await _authService.confirmEmail(event.email, event.code);

      // After confirmation, user needs to sign in
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(EmailConfirmationRequired(event.email));
    }
  }

  Future<void> _onResendConfirmationCode(
    ResendConfirmationCode event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authService.resendConfirmationCode(event.email);
      // Stay in current state
    } catch (e) {
      emit(AuthError('Failed to resend code'));
    }
  }

  Future<void> _onSignInWithEmail(
    SignInWithEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await _authService.signInWithEmail(
        email: event.email,
        password: event.password,
      );

      final userId = await _authService.getCognitoUserId();
      final email = await _authService.getUserEmail();
      final name = await _authService.getUserName();

      if (userId != null && email != null) {
        emit(Authenticated(userId: userId, email: email, name: name));
      } else {
        emit(const AuthError('Failed to get user information'));
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignInWithApple(
    SignInWithApple event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // TODO: Implement Sign in with Apple via Cognito Hosted UI
      emit(const AuthError('Sign in with Apple coming soon'));
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  Future<void> _onForgotPassword(
    ForgotPassword event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await _authService.forgotPassword(event.email);
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  Future<void> _onConfirmForgotPassword(
    ConfirmForgotPassword event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await _authService.confirmForgotPassword(
        email: event.email,
        code: event.code,
        newPassword: event.newPassword,
      );

      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignOut(SignOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      await _authService.signOut();
      emit(Unauthenticated());
    } catch (e) {
      emit(Unauthenticated());
    }
  }
}
