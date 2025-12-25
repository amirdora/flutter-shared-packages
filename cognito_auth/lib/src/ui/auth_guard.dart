import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import 'login_page.dart';

/// Helper to check authentication before performing actions
class AuthGuard {
  /// Check if user is authenticated, show login if not
  /// Returns true if authenticated, false if login was shown
  static Future<bool> requireAuth(
    BuildContext context, {
    String? savedPrompt,
    VoidCallback? onLoginSuccess,
  }) async {
    final authState = context.read<AuthBloc>().state;

    if (authState is Authenticated) {
      return true; // Already authenticated
    }

    // Show login page
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder:
            (context) => LoginPage(
              savedPrompt: savedPrompt,
              onLoginSuccess: onLoginSuccess,
            ),
        fullscreenDialog: true,
      ),
    );

    return result == true;
  }

  /// Show login bottom sheet (alternative to full page)
  static Future<bool> requireAuthBottomSheet(
    BuildContext context, {
    String? savedPrompt,
  }) async {
    final authState = context.read<AuthBloc>().state;

    if (authState is Authenticated) {
      return true;
    }

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: LoginPage(savedPrompt: savedPrompt),
          ),
    );

    return result == true;
  }
}
