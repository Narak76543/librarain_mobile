import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_texts.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/widgets/app_text.dart';
import '../viewmodels/auth_view_model.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = context.read<AuthViewModel>();

    final success = await authViewModel.register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      context.go(AppRoutes.login);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText.bodyMedium(
            authViewModel.errorMessage ?? AppTexts.registrationFailed,
            color: AppColors.white,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AuthHeader(title: AppTexts.createAccount),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    AuthTextField(
                      controller: _nameController,
                      hintText: AppTexts.fullName,
                      icon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppTexts.fullNameRequired;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    AuthTextField(
                      controller: _emailController,
                      hintText: AppTexts.email,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppTexts.emailRequired;
                        }

                        if (!value.contains('@')) {
                          return AppTexts.invalidEmail;
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    AuthTextField(
                      controller: _phoneController,
                      hintText: AppTexts.phone,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppTexts.phoneRequired;
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    AuthTextField(
                      controller: _passwordController,
                      hintText: AppTexts.password,
                      icon: Icons.lock_outline,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
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

                    const SizedBox(height: 24),

                    PrimaryButton(
                      title: AppTexts.signUp,
                      isLoading: authViewModel.isLoading,
                      onPressed: _submit,
                    ),

                    const SizedBox(height: 16),
                    const AppText.caption(
                      AppTexts.dividerOr,
                      color: AppColors.textDisabled,
                    ),

                    const SizedBox(height: 16),

                    PrimaryButton(
                      title: AppTexts.login,
                      isOutlined: true,
                      onPressed: () => context.push(AppRoutes.login),
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
