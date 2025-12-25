/// Configuration for AWS Cognito
class CognitoConfig {
  final String userPoolId;
  final String clientId;
  final String region;
  final String? cognitoDomain;
  
  const CognitoConfig({
    required this.userPoolId,
    required this.clientId,
    required this.region,
    this.cognitoDomain,
  });
  
  String get authority => 'https://cognito-idp.$region.amazonaws.com/$userPoolId';
}
