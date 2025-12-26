import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/cognito_config.dart';

/// Service for handling Cognito Hosted UI OAuth flow
class CognitoHostedUIService {
  final CognitoConfig config;

  CognitoHostedUIService({required this.config});

  String get cognitoDomain =>
      'us-east-15j3wzxbio.auth.us-east-1.amazoncognito.com';

  String get redirectUri => 'quickvidai://auth/callback';

  /// Launch Cognito Hosted UI for Apple Sign In
  Future<Map<String, dynamic>> signInWithApple() async {
    // Build authorization URL
    final authUrl = Uri.https(cognitoDomain, '/oauth2/authorize', {
      'client_id': config.clientId,
      'response_type': 'code',
      'scope': 'openid email profile',
      'redirect_uri': redirectUri,
      // 'identity_provider': 'SignInWithApple', // Commented out to allow Email/Password login
    });

    print('🔐 Opening Cognito Hosted UI: $authUrl');

    // Launch Cognito Hosted UI in browser
    final result = await FlutterWebAuth.authenticate(
      url: authUrl.toString(),
      callbackUrlScheme: 'quickvidai',
    );

    print('✅ Received callback URL: $result');

    // Extract authorization code from callback
    final uri = Uri.parse(result);
    print('📋 Parsed URI: $uri');
    print('📋 Query parameters: ${uri.queryParameters}');

    final code = uri.queryParameters['code'];
    if (code == null) {
      print('❌ No authorization code found in callback URL');
      print('❌ Full URL: $result');
      throw Exception(
        'No authorization code received from Cognito. Callback URL: $result',
      );
    }

    print('✅ Authorization code received: ${code.substring(0, 10)}...');

    // Exchange authorization code for tokens
    final tokens = await _exchangeCodeForTokens(code);
    return tokens;
  }

  /// Exchange authorization code for access/ID/refresh tokens
  Future<Map<String, dynamic>> _exchangeCodeForTokens(String code) async {
    final tokenUrl = Uri.https(cognitoDomain, '/oauth2/token');

    final response = await http.post(
      tokenUrl,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'client_id': config.clientId,
        'code': code,
        'redirect_uri': redirectUri,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Token exchange failed: ${response.statusCode} - ${response.body}',
      );
    }
  }

  /// Get user information from Cognito using access token
  Future<Map<String, dynamic>> getUserInfo(String accessToken) async {
    final userInfoUrl = Uri.https(cognitoDomain, '/oauth2/userInfo');

    final response = await http.get(
      userInfoUrl,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to get user info: ${response.statusCode}');
    }
  }
}
