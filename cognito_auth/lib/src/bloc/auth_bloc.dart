import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/cognito_auth_service.dart';
import '../services/cognito_hosted_ui_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC for managing authentication state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CognitoAuthService _authService;
  final _storage = FlutterSecureStorage();

  AuthBloc({required CognitoAuthService authService})
    : _authService = authService,
      super(Unauthenticated()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SignUpWithEmail>(_onSignUpWithEmail);
    on<ConfirmEmail>(_onConfirmEmail);
    on<SignInWithEmail>(_onSignInWithEmail);
    on<SignInWithApple>(_onSignInWithApple);
    on<SignOut>(_onSignOut);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final userId = await _authService.getCognitoUserId();
      final email = await _authService.getUserEmail();
      final name = await _authService.getUserName();

      if (userId != null && email != null) {
        emit(Authenticated(userId: userId, email: email, name: name));
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
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(EmailConfirmationRequired(event.email));
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
      final hostedUIService = CognitoHostedUIService(
        config: _authService.config,
      );

      // Launch Cognito Hosted UI and get authorization code
      final tokens = await hostedUIService.signInWithApple();

      // Get user information from Cognito
      final userInfo = await hostedUIService.getUserInfo(
        tokens['access_token'],
      );

      // Save tokens to secure storage
      await _storage.write(key: 'access_token', value: tokens['access_token']);
      await _storage.write(key: 'id_token', value: tokens['id_token']);
      await _storage.write(
        key: 'refresh_token',
        value: tokens['refresh_token'],
      );

      // Extract user details
      final userId = userInfo['sub'] as String;
      final email = userInfo['email'] as String?;
      final name = userInfo['name'] as String?;

      if (userId.isNotEmpty) {
        emit(Authenticated(userId: userId, email: email ?? '', name: name));
      } else {
        emit(const AuthError('Failed to get user information from Apple'));
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError('Apple Sign In failed: ${e.toString()}'));
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignOut(SignOut event, Emitter<AuthState> emit) async {
    await _authService.signOut();
    emit(Unauthenticated());
  }
}
