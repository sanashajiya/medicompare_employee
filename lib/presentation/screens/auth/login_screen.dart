import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../data/datasources/local/auth_local_storage.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/dashboard/dashboard_bloc.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../dashboard/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  bool _isFormValid = false;
  bool _showErrors = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateForm({bool showErrors = false}) {
    final emailError = Validators.validateEmail(_emailController.text);
    final passwordError = Validators.validatePassword(_passwordController.text);

    setState(() {
      if (showErrors) _showErrors = true;
      _emailError = _showErrors ? emailError : null;
      _passwordError = _showErrors ? passwordError : null;
      _isFormValid = emailError == null && passwordError == null;
    });
  }

  void _onLogin() {
    _validateForm(showErrors: true);
    if (_isFormValid) {
      print('📧 Attempting login with email: ${_emailController.text}');

      // Dispatch event to the AuthBloc provided in main.dart
      context.read<AuthBloc>().add(
        LoginSubmitted(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    } else {
      print('❌ Form validation failed');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid email and password'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final systemBottomPadding = MediaQuery.of(context).viewPadding.bottom;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocListener<AuthBloc, AuthState>(
        // 🎯 BlocListener for side effects (navigation, snackbars)
        listener: (context, state) {
          print('🎯 [BlocListener] Auth state changed: ${state.runtimeType}');

          if (state is AuthLoading) {
            print('⏳ [BlocListener] Login in progress...');
          } else if (state is AuthSuccess) {
            print('✅ [BlocListener] Login successful!');
            print('✅ [BlocListener] User: ${state.user.name}');
            print('✅ [BlocListener] Email: ${state.user.email}');
            print(
              '✅ [BlocListener] Token: ${state.user.token.substring(0, 20)}...',
            );

            // Save login status and user data to SharedPreferences
            final authStorage = sl<AuthLocalStorage>();
            authStorage
                .saveLoginStatus(state.user)
                .then((_) {
                  print(
                    '💾 [BlocListener] Login status saved to SharedPreferences',
                  );
                })
                .catchError((error) {
                  print('❌ [BlocListener] Failed to save login status: $error');
                });

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Welcome ${state.user.name}!'),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 2),
              ),
            );

            // Navigate immediately (no delay needed since we're in the listener)
            print('🚀 [BlocListener] Navigating to dashboard screen...');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => BlocProvider<DashboardBloc>(
                  create: (_) => sl<DashboardBloc>(),
                  child: DashboardScreen(user: state.user),
                ),
              ),
            );
          } else if (state is AuthFailure) {
            print('❌ [BlocListener] Login failed: ${state.error}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        // 🎨 BlocBuilder for UI rendering based on state
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            print(
              '🎨 [BlocBuilder] Building UI with state: ${state.runtimeType}',
            );
            final isLoading = state is AuthLoading;

            return SafeArea(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  24 + systemBottomPadding + (bottomInset > 0 ? 16 : 0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),

                    // Logo/Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(16),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Sign in to continue',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // Email field
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'Enter your email',
                      errorText: _emailError,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isLoading,
                      onChanged: (_) => _validateForm(),
                    ),

                    const SizedBox(height: 24),

                    // Password field
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Enter your password',
                      errorText: _passwordError,
                      isPassword: true,
                      obscureText: true,
                      enabled: !isLoading,
                      onChanged: (_) => _validateForm(),
                    ),

                    const SizedBox(height: 32),

                    // Login button
                    CustomButton(
                      text: 'Login',
                      onPressed: _isFormValid && !isLoading ? _onLogin : null,
                      isLoading: isLoading,
                      width: double.infinity,
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
