import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

/// Helper to check authentication before performing actions
class AuthGuard {
  /// Check if user is authenticated, show login if not
  /// returns true if authenticated
  static Future<bool> requireAuth(
    BuildContext context, {
    required WidgetBuilder loginPageBuilder,
  }) async {
    final authState = context.read<AuthBloc>().state;

    if (authState is Authenticated) {
      return true; // Already authenticated
    }

    // Show login page provided by builder
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: loginPageBuilder, fullscreenDialog: true),
    );

    return result == true;
  }
}
