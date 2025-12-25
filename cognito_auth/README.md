# 🔐 Cognito Auth - Plug & Play

Dead-simple AWS Cognito authentication for Flutter.

## 🚀 3-Step Integration

### 1. Add to `pubspec.yaml`

```yaml
dependencies:
  cognito_auth:
    path: packages/cognito_auth
```

Run: `flutter pub get`

### 2. Initialize in `main.dart`

```dart
import 'package:cognito_auth/cognito_auth.dart';

void main() {
  CognitoAuth.initialize(
    config: CognitoConfig(
      userPoolId: 'us-east-1_YOUR_POOL_ID',
      clientId: 'YOUR_CLIENT_ID',
      region: 'us-east-1',
    ),
  );
  
  runApp(MyApp());
}
```

### 3. Use AuthBloc

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CognitoAuth.createAuthBloc()
        ..add(CheckAuthStatus()),
      child: MaterialApp(
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) return HomePage();
            return LoginPage(); // Built-in UI
          },
        ),
      ),
    );
  }
}
```

**Done! 🎉**

---

## 📖 Usage

### Protect Actions

```dart
ElevatedButton(
  onPressed: () async {
    final isAuth = await AuthGuard.requireAuth(context);
    if (isAuth) {
      // User authenticated, proceed
      generateVideo();
    }
  },
  child: Text('Generate'),
)
```

### Get User Info

```dart
final state = context.read<AuthBloc>().state as Authenticated;
print('Email: ${state.email}');
print('User ID: ${state.userId}');
```

### Sign Out

```dart
context.read<AuthBloc>().add(SignOut());
```

---

## 🎨 Custom UI

```dart
// Use your own login UI
ElevatedButton(
  onPressed: () {
    context.read<AuthBloc>().add(
      SignInWithEmail(
        email: email,
        password: password,
      ),
    );
  },
  child: Text('Sign In'),
)
```

---

## 📱 iOS Setup (Apple Sign In)

1. Xcode: Runner → Capabilities → Add "Sign in with Apple"
2. Update `Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>your-app-scheme</string>
    </array>
  </dict>
</array>
```

---

## 🔧 API

### Events
- `CheckAuthStatus`
- `SignInWithEmail(email, password)`
- `SignInWithApple()`
- `SignUpWithEmail(email, password, name)`
- `SignOut()`

### States
- `Authenticated(userId, email, name)`
- `Unauthenticated`
- `AuthLoading`
- `AuthError(message)`

---

## 📦 What's Included

✅ Email/Password auth  
✅ Sign in with Apple  
✅ Auto token management  
✅ Secure storage  
✅ Pre-built UI  
✅ Auth guards  

---

**That's it! Copy this package to any Flutter project and you're ready to go.**
