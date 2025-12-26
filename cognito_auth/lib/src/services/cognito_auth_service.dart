import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/cognito_config.dart';

/// AWS Cognito authentication service
/// Handles email/password and Sign in with Apple authentication
class CognitoAuthService {
  final CognitoConfig config;
  late final CognitoUserPool _userPool;
  final _storage = const FlutterSecureStorage();

  CognitoAuthService({required this.config}) {
    _userPool = CognitoUserPool(config.userPoolId, config.clientId);
  }

  // ==================== EMAIL/PASSWORD AUTH ====================

  /// Sign up with email and password
  Future<CognitoUser?> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    final userAttributes = [
      AttributeArg(name: 'email', value: email),
      if (name != null) AttributeArg(name: 'name', value: name),
    ];

    try {
      final result = await _userPool.signUp(
        email,
        password,
        userAttributes: userAttributes,
      );
      return result.user;
    } catch (e) {
      throw _handleCognitoError(e);
    }
  }

  /// Confirm email with verification code
  Future<bool> confirmEmail(String email, String code) async {
    final cognitoUser = CognitoUser(email, _userPool);

    try {
      await cognitoUser.confirmRegistration(code);
      return true;
    } catch (e) {
      throw _handleCognitoError(e);
    }
  }

  /// Resend confirmation code
  Future<void> resendConfirmationCode(String email) async {
    final cognitoUser = CognitoUser(email, _userPool);
    await cognitoUser.resendConfirmationCode();
  }

  /// Sign in with email and password
  Future<CognitoUserSession> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cognitoUser = CognitoUser(email, _userPool);
    final authDetails = AuthenticationDetails(
      username: email,
      password: password,
    );

    try {
      final session = await cognitoUser.authenticateUser(authDetails);

      if (session != null) {
        await _saveTokens(session);
        return session;
      } else {
        throw Exception('Authentication failed');
      }
    } catch (e) {
      throw _handleCognitoError(e);
    }
  }

  /// Forgot password - send reset code
  Future<void> forgotPassword(String email) async {
    final cognitoUser = CognitoUser(email, _userPool);
    try {
      await cognitoUser.forgotPassword();
    } catch (e) {
      throw _handleCognitoError(e);
    }
  }

  /// Confirm forgot password with code and new password
  Future<bool> confirmForgotPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final cognitoUser = CognitoUser(email, _userPool);

    try {
      await cognitoUser.confirmPassword(code, newPassword);
      return true;
    } catch (e) {
      throw _handleCognitoError(e);
    }
  }

  // ==================== TOKEN MANAGEMENT ====================

  /// Get current session
  Future<CognitoUserSession?> getCurrentSession() async {
    try {
      final cognitoUser = await _userPool.getCurrentUser();
      if (cognitoUser == null) return null;

      return await cognitoUser.getSession();
    } catch (e) {
      return null;
    }
  }

  /// Get ID token for API calls
  Future<String?> getIdToken() async {
    try {
      final session = await getCurrentSession();
      return session?.getIdToken().getJwtToken();
    } catch (e) {
      return null;
    }
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    try {
      final session = await getCurrentSession();
      return session?.getAccessToken().getJwtToken();
    } catch (e) {
      return null;
    }
  }

  /// Refresh tokens
  Future<CognitoUserSession?> refreshSession() async {
    try {
      final cognitoUser = await _userPool.getCurrentUser();
      if (cognitoUser == null) return null;

      final session = await cognitoUser.getSession();
      if (session != null) {
        await _saveTokens(session);
      }
      return session;
    } catch (e) {
      return null;
    }
  }

  /// Get user attributes
  Future<Map<String, String>?> getUserAttributes() async {
    try {
      final cognitoUser = await _userPool.getCurrentUser();
      if (cognitoUser == null) return null;

      final attributes = await cognitoUser.getUserAttributes();
      if (attributes == null) return null;

      return Map.fromEntries(
        attributes.map((attr) => MapEntry(attr.name!, attr.value!)),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get user email
  Future<String?> getUserEmail() async {
    final attributes = await getUserAttributes();
    return attributes?['email'];
  }

  /// Get user name
  Future<String?> getUserName() async {
    final attributes = await getUserAttributes();
    return attributes?['name'];
  }

  /// Get Cognito user ID (sub claim)
  Future<String?> getCognitoUserId() async {
    try {
      final session = await getCurrentSession();
      return session?.getIdToken().payload['sub'];
    } catch (e) {
      return null;
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final session = await getCurrentSession();
    return session != null && session.isValid();
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      final cognitoUser = await _userPool.getCurrentUser();
      await cognitoUser?.signOut();
      await _clearTokens();
    } catch (e) {
      // Ignore errors during sign out
      await _clearTokens();
    }
  }

  // ==================== PRIVATE HELPERS ====================

  Future<void> _saveTokens(CognitoUserSession session) async {
    try {
      await _storage.write(
        key: 'cognito_id_token',
        value: session.getIdToken().getJwtToken(),
      );
      await _storage.write(
        key: 'cognito_access_token',
        value: session.getAccessToken().getJwtToken(),
      );
      final refreshToken = session.getRefreshToken()?.getToken();
      if (refreshToken != null) {
        await _storage.write(key: 'cognito_refresh_token', value: refreshToken);
      }
    } catch (e) {
      // Ignore storage errors
    }
  }

  Future<void> _clearTokens() async {
    try {
      await _storage.delete(key: 'cognito_id_token');
      await _storage.delete(key: 'cognito_access_token');
      await _storage.delete(key: 'cognito_refresh_token');
    } catch (e) {
      // Ignore storage errors
    }
  }

  String _handleCognitoError(dynamic error) {
    final errorString = error.toString();

    if (errorString.contains('UserNotFoundException')) {
      return 'User not found. Please check your email.';
    } else if (errorString.contains('NotAuthorizedException')) {
      return 'Incorrect email or password.';
    } else if (errorString.contains('UserNotConfirmedException')) {
      return 'Please verify your email first.';
    } else if (errorString.contains('CodeMismatchException')) {
      return 'Invalid verification code.';
    } else if (errorString.contains('ExpiredCodeException')) {
      return 'Verification code has expired.';
    } else if (errorString.contains('InvalidPasswordException')) {
      return 'Password must be at least 8 characters with uppercase, lowercase, number, and symbol.';
    } else if (errorString.contains('UsernameExistsException')) {
      return 'An account with this email already exists.';
    } else if (errorString.contains('LimitExceededException')) {
      return 'Too many attempts. Please try again later.';
    } else {
      return 'An error occurred. Please try again.';
    }
  }
}
