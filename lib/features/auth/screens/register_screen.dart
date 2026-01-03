// lib/features/auth/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../../../core/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    // Validate inputs
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter your name');
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      _showError('Please enter your email');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final result = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _nameController.text.trim(),
    );

    if (!mounted) return;

    switch (result) {
      case AuthSuccess():
        Navigator.of(context).pop();
        break;

      case AuthFailure(message: var msg):
        debugPrint('Registration Error: $msg');
        break;

      case AuthCanceled():
        debugPrint('Registration Canceled');
        break;

      case ActionSuccess():
        debugPrint('Unexpected ActionSuccess during registration.');
        break;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundDark,
              AppColors.secondaryGlass.withAlpha(51),
              AppColors.tertiaryGlass.withAlpha(51),
              AppColors.backgroundDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              if (authProvider.errorMessage != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _showError(authProvider.errorMessage!);
                  authProvider.clearError();
                });
              }

              return Stack(
                children: [
                  // RESPONSIVE: Different layouts
                  isLandscape
                      ? _buildLandscapeLayout()
                      : _buildPortraitLayout(),

                  // Loading overlay
                  if (authProvider.isLoading)
                    Container(
                      color: Colors.black.withAlpha(128),
                      child: Center(
                        child: GlassContainer(
                          padding: const EdgeInsets.all(32),
                          child: const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.secondaryGlass,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // PORTRAIT: Vertical layout
  Widget _buildPortraitLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Create Account',
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 600.ms),
          const SizedBox(height: 40),
          _buildRegisterForm(),
        ],
      ),
    );
  }

  // LANDSCAPE: Two-column layout with scrollable form
  Widget _buildLandscapeLayout() {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxScrollHeight = screenHeight * 0.7;

    return Row(
      children: [
        // LEFT: Header
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.pop(context),
                  alignment: Alignment.centerLeft,
                ),
                const SizedBox(height: 20),
                Center(
                  child: Image.asset(
                    'assets/images/aura_logo.png',
                    height: 100,
                  ).animate().fadeIn(duration: 600.ms).scale(),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 600.ms),
                ),
              ],
            ),
          ),
        ),
        // RIGHT: Form (scrollable)
        Expanded(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: maxScrollHeight,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: _buildRegisterForm(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_rounded, color: AppColors.primaryGlass),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_rounded, color: AppColors.primaryGlass),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.primaryGlass),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _handleRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryGlass,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Sign Up'),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2, end: 0);
  }
}