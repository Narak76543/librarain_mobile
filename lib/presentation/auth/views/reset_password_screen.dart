import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_texts.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/widgets/app_text.dart';
import '../../../data/repositories/auth_repository.dart';
import '../viewmodels/reset_password_view_model.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_button.dart';

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

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
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
          content: AppText.bodyMedium(
            AppTexts.passwordResetSuccess,
            color: AppColors.white,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText.bodyMedium(
            viewModel.errorMessage ?? AppTexts.resetPasswordFailed,
            color: AppColors.white,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ResetPasswordViewModel>();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AuthHeader(title: AppTexts.resetPasswordTitle),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    AuthTextField(
                      controller: _passwordController,
                      hintText: AppTexts.newPassword,
                      icon: Icons.lock_outline,
                      obscureText: true,
                      obscureValue: viewModel.obscurePassword,
                      onObscureToggle: viewModel.togglePasswordVisibility,
                      textInputAction: TextInputAction.next,
                      onChanged: viewModel.updateStrength,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppTexts.passwordRequired;
                        }

                        if (value.length < 6) {
                          return AppTexts.passwordMinLength;
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _PasswordStrengthBar(strength: viewModel.passwordStrength),
                    const SizedBox(height: 14),
                    AuthTextField(
                      controller: _confirmController,
                      hintText: AppTexts.confirmPassword,
                      icon: Icons.lock_outline,
                      obscureText: true,
                      obscureValue: viewModel.obscureConfirm,
                      onObscureToggle: viewModel.toggleConfirmVisibility,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppTexts.confirmPasswordRequired;
                        }

                        if (value != _passwordController.text) {
                          return AppTexts.passwordsDoNotMatch;
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      title: AppTexts.resetPassword,
                      isLoading: viewModel.isLoading,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
      PasswordStrength.weak => AppColors.error,
      PasswordStrength.medium => AppColors.warning,
      PasswordStrength.strong => AppColors.success,
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
            const AppText.caption(
              AppTexts.passwordStrength,
              color: AppColors.textDisabled,
            ),
            AppText.caption(
              label,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            minHeight: 6,
            value: value,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
