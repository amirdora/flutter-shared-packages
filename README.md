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

1. Clone this repo alongside your projects:
```
Documents/
├── flutter-shared-packages/  ← This repo
│   └── cognito_auth/
└── your-project/
    └── pubspec.yaml
```

2. Add to your project:
```yaml
dependencies:
  cognito_auth:
    path: ../flutter-shared-packages/cognito_auth
```

3. Initialize:
```dart
CognitoAuth.initialize(
  config: CognitoConfig(
    userPoolId: 'YOUR_POOL_ID',
    clientId: 'YOUR_CLIENT_ID',
    region: 'us-east-1',
  ),
);
```

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
