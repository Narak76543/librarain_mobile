import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_texts.dart';
import '../../../core/theme/app_color.dart';
import '../../../data/repositories/auth_repository.dart';
import '../viewmodels/reset_password_view_model.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ResetPasswordViewModel(AuthRepository()),
      child: _ResetPasswordView(email: email),
    );
  }
}

class _ResetPasswordView extends StatefulWidget {
  const _ResetPasswordView({required this.email});

  final String email;

  @override
  State<_ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<_ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _passwordTouched = false;
  bool _confirmTouched = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _passwordTouched = true;
      _confirmTouched = true;
    });

    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<ResetPasswordViewModel>();
    final success = await viewModel.submit(
      widget.email,
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      context.go(AppRoutes.login);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF005B5B),
          content: Text(
            AppTexts.passwordResetSuccess,
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            viewModel.errorMessage ?? AppTexts.resetPasswordFailed,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ResetPasswordViewModel>();
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppGradients.background,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Back Button AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    if (canPop)
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E1E1E), size: 20),
                        onPressed: () => context.pop(),
                      ),
                  ],
                ),
              ),

              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // LOGO
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF005B5B).withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                              image: const DecorationImage(
                                image: AssetImage('assets/images/app_logo.png'),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // TITLE
                          const Text(
                            'Reset Password',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E1E1E),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // SUBTITLE
                          const Text(
                            "Create a new strong password",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF757575),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // INPUT CARD
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // NEW PASSWORD
                                _buildTextField(
                                  controller: _passwordController,
                                  hint: "New password",
                                  iconPath: 'assets/icons/lock-keyhole.svg',
                                  obscure: viewModel.obscurePassword,
                                  touched: _passwordTouched,
                                  onChanged: () => viewModel.updateStrength(_passwordController.text),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return AppTexts.passwordRequired;
                                    }
                                    if (value.length < 6) {
                                      return AppTexts.passwordMinLength;
                                    }
                                    return null;
                                  },
                                  suffix: IconButton(
                                    splashRadius: 24,
                                    onPressed: viewModel.togglePasswordVisibility,
                                    icon: Icon(
                                      viewModel.obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: const Color(0xFF9E9E9E),
                                      size: 22,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // STRENGTH INDICATOR
                                _PasswordStrengthBar(strength: viewModel.passwordStrength),
                                const SizedBox(height: 16),

                                // CONFIRM PASSWORD
                                _buildTextField(
                                  controller: _confirmController,
                                  hint: "Confirm password",
                                  iconPath: 'assets/icons/lock-keyhole.svg',
                                  obscure: viewModel.obscureConfirm,
                                  touched: _confirmTouched,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return AppTexts.confirmPasswordRequired;
                                    }
                                    if (value != _passwordController.text) {
                                      return AppTexts.passwordsDoNotMatch;
                                    }
                                    return null;
                                  },
                                  suffix: IconButton(
                                    splashRadius: 24,
                                    onPressed: viewModel.toggleConfirmVisibility,
                                    icon: Icon(
                                      viewModel.obscureConfirm
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: const Color(0xFF9E9E9E),
                                      size: 22,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // RESET PASSWORD BUTTON
                                SizedBox(
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: viewModel.isLoading ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF005B5B),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: viewModel.isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : const Text(
                                            "Reset Password",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required String iconPath,
    Widget? suffix,
    bool obscure = false,
    String? Function(String?)? validator,
    bool touched = false,
    VoidCallback? onChanged,
  }) {
    return FormField<String>(
      validator: validator,
      builder: (state) {
        bool hasError = touched && state.hasError;
        
        return TextField(
          onTap: () {
            setState(() {
              if (controller == _passwordController) {
                _passwordTouched = true;
              } else if (controller == _confirmController) {
                _confirmTouched = true;
              }
            });
          },
          controller: controller,
          obscureText: obscure,
          onChanged: (val) {
            state.didChange(val);
            onChanged?.call();
          },
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF1E1E1E),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(14.0),
              child: SvgPicture.asset(iconPath, width: 22, height: 22),
            ),
            suffixIcon: suffix,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF005B5B), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            errorText: hasError ? state.errorText : null,
          ),
        );
      },
    );
  }
}

class _PasswordStrengthBar extends StatelessWidget {
  const _PasswordStrengthBar({required this.strength});

  final PasswordStrength strength;

  @override
  Widget build(BuildContext context) {
    final value = switch (strength) {
      PasswordStrength.weak => 0.34,
      PasswordStrength.medium => 0.67,
      PasswordStrength.strong => 1.0,
    };
    final color = switch (strength) {
      PasswordStrength.weak => Colors.redAccent,
      PasswordStrength.medium => Colors.orangeAccent,
      PasswordStrength.strong => const Color(0xFF005B5B),
    };
    final label = switch (strength) {
      PasswordStrength.weak => AppTexts.weakPassword,
      PasswordStrength.medium => AppTexts.mediumPassword,
      PasswordStrength.strong => AppTexts.strongPassword,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              AppTexts.passwordStrength,
              style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13, fontWeight: FontWeight.w500),
            ),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            minHeight: 6,
            value: value,
            backgroundColor: const Color(0xFFF5F5F7),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
