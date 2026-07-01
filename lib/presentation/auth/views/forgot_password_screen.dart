import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_texts.dart';
import '../../../core/theme/app_color.dart';
import '../../../data/repositories/auth_repository.dart';
import '../viewmodels/forgot_password_view_model.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForgotPasswordViewModel(AuthRepository()),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView();

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailTouched = false;
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    setState(() {
      if (_emailTouched) {
        if (_emailController.text.isEmpty) {
          _emailError = AppTexts.emailRequired;
        } else if (!_emailController.text.contains('@')) {
          _emailError = "Please enter a valid email";
        } else {
          _emailError = null;
        }
      }
    });
  }

  Future<void> _submit(String channel) async {
    setState(() {
      _emailTouched = true;
    });
    _validateEmail();

    if (_emailError != null || _emailController.text.isEmpty) return;

    final email = _emailController.text.trim();
    final viewModel = context.read<ForgotPasswordViewModel>();
    final success = await viewModel.submit(email, channel: channel);

    if (!mounted) return;

    if (success) {
      context.go(AppRoutes.verifyOtp, extra: email);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF005B5B),
          content: Text(
            viewModel.errorMessage ?? AppTexts.forgotPasswordFailed,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ForgotPasswordViewModel>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Back Button AppBar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF1E1E1E),
                        size: 20,
                      ),
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
                                  color: const Color(
                                    0xFF005B5B,
                                  ).withValues(alpha: 0.1),
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
                            'Forgot Password',
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
                            "Enter your email to receive an OTP code",
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
                                // EMAIL
                                _buildTextField(
                                  controller: _emailController,
                                  hint: "E-mail address",
                                  iconPath: 'assets/icons/mail.svg',
                                  touched: _emailTouched,
                                  errorText: _emailError,
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: _validateEmail,
                                ),
                                const SizedBox(height: 32),

                                // SEND OTP VIA EMAIL BUTTON
                                SizedBox(
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: viewModel.isLoading
                                        ? null
                                        : () => _submit('email'),
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
                                            "Send OTP via Email",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // SEND OTP VIA TELEGRAM BUTTON
                                SizedBox(
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: viewModel.isLoading
                                        ? null
                                        : () => _submit('telegram'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF5F5F7),
                                      foregroundColor: const Color(0xFF1E1E1E),
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
                                              color: Color(0xFF005B5B),
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                'assets/images/telegram.png',
                                                width: 22,
                                                height: 22,
                                              ),
                                              const SizedBox(width: 10),
                                              const Text(
                                                "Send OTP via Telegram",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
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
    String? errorText,
    bool touched = false,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onChanged,
  }) {
    bool hasError = touched && errorText != null && errorText.isNotEmpty;

    return TextFormField(
      onTap: () {
        setState(() {
          _emailTouched = true;
        });
      },
      controller: controller,
      keyboardType: keyboardType,
      onChanged: (_) => onChanged?.call(),
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
        errorText: hasError ? errorText : null,
      ),
    );
  }
}
