import 'config/cognito_config.dart';
import 'services/cognito_auth_service.dart';
import 'bloc/auth_bloc.dart';

/// Main entry point for Cognito Auth package
/// 
/// Usage:
/// ```dart
/// void main() {
///   CognitoAuth.initialize(
///     config: CognitoConfig(
///       userPoolId: 'us-east-1_YOUR_POOL_ID',
///       clientId: 'YOUR_CLIENT_ID',
///       region: 'us-east-1',
///     ),
///   );
///   runApp(MyApp());
/// }
/// ```
class CognitoAuth {
  static CognitoAuthService? _instance;
  static CognitoConfig? _config;
  
  /// Initialize with your Cognito configuration
  static void initialize({required CognitoConfig config}) {
    _config = config;
    _instance = CognitoAuthService(config: config);
  }
  
  /// Get the singleton instance
  static CognitoAuthService get instance {
    if (_instance == null) {
      throw Exception(
        'CognitoAuth not initialized! '
        'Call CognitoAuth.initialize() in main() first.',
      );
    }
    return _instance!;
  }
  
  /// Get the configuration
  static CognitoConfig get config {
    if (_config == null) {
      throw Exception('CognitoAuth not initialized!');
    }
    return _config!;
  }
  
  /// Create an AuthBloc instance
  static AuthBloc createAuthBloc() {
    return AuthBloc(authService: instance);
  }
}
