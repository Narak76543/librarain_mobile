import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_texts.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/widgets/app_text.dart';
import '../viewmodels/auth_view_model.dart';
import '../../profile/viewmodels/wishlist_viewmodel.dart';

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
  bool obscurePassword = true;
  bool _emailTouched = false;
  bool _passwordTouched = false;
  String? _emailError;
  String? _passwordError;

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
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppGradients.background,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                      'Create Account',
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
                      "Join us to start exploring our library",
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
                          // NAME
                          _buildTextField(
                            iconPath: 'assets/icons/user-round.svg',
                            controller: _nameController,
                            hint: "Full Name",
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return AppTexts.fullNameRequired;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // EMAIL
                          _buildTextField(
                            iconPath: 'assets/icons/mail.svg',
                            controller: _emailController,
                            hint: "E-mail address",
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return AppTexts.emailRequired;
                              }
                              if (!value.contains('@')) return AppTexts.invalidEmail;
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // PHONE
                          _buildTextField(
                            iconPath: 'assets/icons/phone.svg',
                            controller: _phoneController,
                            hint: "Phone Number",
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return AppTexts.phoneRequired;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // PASSWORD
                          _buildTextField(
                            iconPath: 'assets/icons/lock-keyhole.svg',
                            controller: _passwordController,
                            hint: "Password",
                            obscure: obscurePassword,
                            suffix: IconButton(
                              splashRadius: 24,
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFF9E9E9E),
                                size: 22,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return AppTexts.passwordRequired;
                              }
                              if (value.length < 6) return AppTexts.passwordMinLength;
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // SIGN UP BUTTON
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: authViewModel.isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF005B5B),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: authViewModel.isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      "Sign Up",
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

                    const SizedBox(height: 32),

                    // DIVIDER
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "Or continue with",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // SOCIAL BUTTONS ROW
                    Row(
                      children: [
                        Expanded(
                          child: _socialButton(
                            onTap: () async {
                              final authViewModel = context.read<AuthViewModel>();
                              final success = await authViewModel.loginWithGoogle();
                              if (!mounted) return;
                              if (success) {
                                context.read<WishlistViewModel>().loadWishlist();
                                context.go(AppRoutes.main);
                              } else if (authViewModel.errorMessage != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: const Color(0xFF005B5B),
                                    content: Text(
                                      authViewModel.errorMessage!,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              }
                            },
                            image: "assets/icons/google.png",
                            text: "Google",
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _socialButton(
                            onTap: () async {
                              final authViewModel = context.read<AuthViewModel>();
                              final success = await authViewModel.loginWithTelegram();

                              if (success && mounted) {
                                context.go(AppRoutes.main);
                              } else if (mounted && authViewModel.errorMessage != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(authViewModel.errorMessage!),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            },
                            image: 'assets/images/telegram.png',
                            text: "Telegram",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // LOGIN REDIRECT
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account?",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF757575),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push(AppRoutes.login),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF005B5B),
                          ),
                          child: const Text(
                            "Sign In",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // TERMS
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E), height: 1.5),
                        children: [
                          TextSpan(text: "By continuing, you agree to our\n"),
                          TextSpan(
                            text: "Terms of Service",
                            style: TextStyle(color: Color(0xFF005B5B), fontWeight: FontWeight.w600),
                          ),
                          TextSpan(text: "  •  "),
                          TextSpan(
                            text: "Privacy Policy",
                            style: TextStyle(color: Color(0xFF005B5B), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
    String? errorText,
    bool touched = false,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onChanged,
  }) {
    bool hasError = touched && errorText != null && errorText.isNotEmpty;
    return TextFormField(
      onTap: () {
        setState(() {
          if (controller == _emailController) {
            _emailTouched = true;
          } else if (controller == _passwordController) {
            _passwordTouched = true;
          }
        });
      },
      controller: controller,
      obscureText: obscure,
      validator: validator,
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
        errorText: hasError ? errorText : null,
      ),
    );
  }

  Widget _socialButton({
    IconData? icon,
    String? image,
    required String text,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, size: 24, color: const Color(0xFF1E1E1E)),
            if (image != null) Image.asset(image, width: 24, height: 24),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E1E1E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
