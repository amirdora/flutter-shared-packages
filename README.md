# Flutter Shared Packages

Private Flutter packages for reuse across multiple projects.

## 📦 Packages

### 1. `cognito_auth` - AWS Cognito Authentication

Plug-and-play authentication with email/password and Apple Sign In.

**Version:** 1.0.0

**Usage:**
```yaml
dependencies:
  cognito_auth:
    path: ../flutter-shared-packages/cognito_auth
```

---

## 🚀 Quick Start

### Step 1: Clone Repository

Clone this repo alongside your projects:
```
Documents/
├── flutter-shared-packages/  ← This repo
│   └── cognito_auth/
└── your-project/
    └── pubspec.yaml
```

### Step 2: Add Dependency

Add to your `pubspec.yaml`:
```yaml
dependencies:
  cognito_auth:
    path: ../flutter-shared-packages/cognito_auth
```

Run:
```bash
flutter pub get
```

### Step 3: Initialize in main.dart

```dart
import 'package:cognito_auth/cognito_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

### Step 4: Setup BlocProvider

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

**Done! Your app now has authentication. 🎉**

---

## 📖 Usage Examples

### Protect Actions with Auth Guard

```dart
ElevatedButton(
  onPressed: () async {
    final isAuth = await AuthGuard.requireAuth(context);
    if (isAuth) {
      // User authenticated, proceed with action
      generateVideo();
    }
  },
  child: Text('Generate Video'),
)
```

### Get User Information

```dart
final state = context.read<AuthBloc>().state as Authenticated;
print('Email: ${state.email}');
print('User ID: ${state.userId}');
print('Name: ${state.name}');
```

### Sign Out

```dart
ElevatedButton(
  onPressed: () {
    context.read<AuthBloc>().add(SignOut());
  },
  child: Text('Sign Out'),
)
```

### Custom Login UI

Build your own login form:
```dart
ElevatedButton(
  onPressed: () {
    context.read<AuthBloc>().add(
      SignInWithEmail(
        email: emailController.text,
        password: passwordController.text,
      ),
    );
  },
  child: Text('Sign In'),
)

// Sign Up
ElevatedButton(
  onPressed: () {
    context.read<AuthBloc>().add(
      SignUpWithEmail(
        email: emailController.text,
        password: passwordController.text,
        name: nameController.text,
      ),
    );
  },
  child: Text('Sign Up'),
)

// Apple Sign In
ElevatedButton(
  onPressed: () {
    context.read<AuthBloc>().add(SignInWithApple());
  },
  child: Text('Sign in with Apple'),
)
```

### Handle Auth States

```dart
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is Authenticated) {
      // Navigate to home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } else if (state is AuthError) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: YourWidget(),
)
```

---

## 🍎 iOS Setup (for Apple Sign In)

1. Open Xcode: `open ios/Runner.xcworkspace`
2. Select Runner → Signing & Capabilities → Add "Sign in with Apple"
3. Update `ios/Runner/Info.plist`:

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

## 📚 API Reference

### Available Events

- `CheckAuthStatus` - Check if user is authenticated
- `SignInWithEmail(email, password)` - Sign in with email/password
- `SignInWithApple()` - Sign in with Apple ID
- `SignUpWithEmail(email, password, name)` - Create new account
- `SignOut()` - Sign out current user

### Auth States

- `Authenticated(userId, email, name)` - User is logged in
- `Unauthenticated` - User is not logged in
- `AuthLoading` - Authentication in progress
- `AuthError(message)` - Authentication failed

### Features Included

✅ Email/Password authentication
✅ Sign in with Apple
✅ Automatic token management
✅ Secure credential storage
✅ Pre-built login UI
✅ Auth guards for protected actions
✅ BLoC state management

---

## 📁 Structure

```
flutter-shared-packages/
├── README.md
├── cognito_auth/
│   ├── lib/
│   ├── pubspec.yaml
│   └── README.md
└── (future packages...)
```

---

## 🔄 Updates

When updating a package:

1. Make changes
2. Update version in `pubspec.yaml`
3. Commit and tag:
```bash
git add .
git commit -m "Update cognito_auth to v1.1.0"
git tag cognito_auth-v1.1.0
git push origin main --tags
```

4. In your projects, run:
```bash
flutter pub upgrade
```

---

## 🔒 Private Repository

This is a **private** repository. Only accessible to authorized team members.

---

**Made for easy reuse across all Flutter projects.**
