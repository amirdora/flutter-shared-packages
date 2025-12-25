import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart' as apple;
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';

/// Simple login page with Apple Sign In
class LoginPage extends StatelessWidget {
  final String? savedPrompt;
  final VoidCallback? onLoginSuccess;

  const LoginPage({Key? key, this.savedPrompt, this.onLoginSuccess})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            // Login successful
            if (onLoginSuccess != null) {
              onLoginSuccess!();
            } else {
              Navigator.pop(context, true);
            }
          } else if (state is AuthError) {
            // Show error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App icon/logo
                  Icon(
                    Icons.video_library_rounded,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),

                  // App name
                  Text(
                    'VideoGen AI',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Create amazing AI videos',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Saved prompt (if any)
                  if (savedPrompt != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your prompt:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            savedPrompt!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Benefits
                  _buildBenefit(Icons.stars, 'Get 10 free credits'),
                  const SizedBox(height: 12),
                  _buildBenefit(Icons.cloud_done, 'Save all your videos'),
                  const SizedBox(height: 12),
                  _buildBenefit(Icons.devices, 'Access from any device'),
                  const SizedBox(height: 32),

                  // Sign in with Apple button
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    apple.SignInWithAppleButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(SignInWithApple());
                      },
                      height: 50,
                      borderRadius: BorderRadius.circular(12),
                    ),

                  const SizedBox(height: 16),

                  // Email sign in option
                  TextButton(
                    onPressed:
                        isLoading
                            ? null
                            : () {
                              Navigator.pushNamed(context, '/email-login');
                            },
                    child: const Text('Sign in with Email'),
                  ),

                  const SizedBox(height: 24),

                  // Terms
                  Text(
                    'By continuing, you agree to our Terms of Service and Privacy Policy',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBenefit(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.green),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
