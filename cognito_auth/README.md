# Cognito Auth Package

A shared Flutter package for handling AWS Cognito authentication with Hosted UI support (Apple Sign In & Email).

## Features
- AWS Cognito User Pool authentication via Hosted UI
- Apple Sign In support
- Use of secure `flutter_web_auth` meant for mobile apps
- Token management (Access, ID, Refresh)
- Auto-refresh of tokens

## Setup Instructions

### 1. AWS Cognito Configuration
Ensure your User Pool App Client is configured as **Public Client** (No Secret).
- **Callback URL:** `quickvidai://auth/callback`
- **Sign Out URL:** `quickvidai://auth/signout`
- **Identity Providers:** Enable `Cognito User Pool` and `Sign in with Apple`
- **Scopes:** `openid`, `email`, `profile`

### 2. Apple Developer Portal
- **Service ID:** Create a Service ID (e.g., `com.example.service`).
- **Domain Verification:** Add your Cognito Domain (e.g., `us-east-1xxx.auth...`) to "Domains and Subdomains".
- **Return URLs:** Add the Cognito callback: `https://[your-domain].auth.us-east-1.amazoncognito.com/oauth2/idpresponse`

### 3. Usage inside Flutter App

Initialize in `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Auth
  CognitoAuth.initialize(
    config: CognitoConfig(
      userPoolId: 'us-east-1_xxxxx',
      clientId: 'xxxxxxxxxxxx',
      region: 'us-east-1',
      cognitoDomain: 'us-east-15j3wzxbio.auth.us-east-1.amazoncognito.com', // No https:// prefix
    ),
  );

  runApp(MyApp());
}
```

### 4. Info.plist (iOS)
Add the URL scheme for callbacks:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>quickvidai</string>
        </array>
    </dict>
</array>
```
