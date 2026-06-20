import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_texts.dart';
import '../../../core/theme/app_color.dart';
import '../viewmodels/auth_view_model.dart';
import '../../profile/viewmodels/wishlist_viewmodel.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     final authViewModel = context.read<AuthViewModel>();
//
//     final success = await authViewModel.login(
//       email: _emailController.text.trim(),
//       password: _passwordController.text.trim(),
//     );
//
//     if (!mounted) return;
//
//     if (success) {
//       context.go(AppRoutes.main);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: AppText.bodyMedium(
//             authViewModel.errorMessage ?? AppTexts.loginFailed,
//             color: AppColors.white,
//           ),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final authViewModel = context.watch<AuthViewModel>();
//
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             const AuthHeader(
//               title: AppTexts.welcomeBack,
//               fallbackRoute: AppRoutes.onboarding,
//             ),
//
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 28),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     AuthTextField(
//                       controller: _emailController,
//                       hintText: AppTexts.email,
//                       icon: Icons.email_outlined,
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) {
//                           return AppTexts.emailRequired;
//                         }
//                         return null;
//                       },
//                     ),
//
//                     const SizedBox(height: 14),
//
//                     AuthTextField(
//                       controller: _passwordController,
//                       hintText: AppTexts.password,
//                       icon: Icons.lock_outline,
//                       obscureText: true,
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) {
//                           return AppTexts.passwordRequired;
//                         }
//
//                         if (value.length < 6) {
//                           return AppTexts.passwordMinLength;
//                         }
//
//                         return null;
//                       },
//                     ),
//
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: TextButton(
//                         onPressed: () => context.go(AppRoutes.forgotPassword),
//                         style: TextButton.styleFrom(
//                           foregroundColor: AppColors.primary,
//                         ),
//                         child: const AppText.caption(
//                           AppTexts.forgotPassword,
//                           color: AppColors.primary,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//
//                     PrimaryButton(
//                       title: AppTexts.login,
//                       isLoading: authViewModel.isLoading,
//                       onPressed: _submit,
//                     ),
//
//                     const SizedBox(height: 16),
//
//                     const AppText.caption(
//                       AppTexts.dividerOr,
//                       color: AppColors.textDisabled,
//                     ),
//
//                     const SizedBox(height: 16),
//
//                     PrimaryButton(
//                       title: AppTexts.signUp,
//                       isOutlined: true,
//                       onPressed: () => context.push(AppRoutes.register),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//============== Visut-- Version ================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool obscurePassword = true;
  bool _emailTouched = false;
  bool _passwordTouched = false;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
  }

  void _validateEmail() {
    setState(() {
      if (_emailTouched) {
        if (_emailController.text.isEmpty) {
          _emailError = AppTexts.emailRequired;
        } else if (!_isValidEmail(_emailController.text)) {
          _emailError = "Please enter a valid email";
        } else {
          _emailError = null;
        }
      }
    });
  }

  void _validatePassword() {
    setState(() {
      if (_passwordTouched) {
        if (_passwordController.text.isEmpty) {
          _passwordError = AppTexts.passwordRequired;
        } else if (_passwordController.text.length < 6) {
          _passwordError = "Minimum 6 characters required";
        } else {
          _passwordError = null;
        }
      }
    });
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = context.read<AuthViewModel>();

    final success = await authViewModel.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      context.read<WishlistViewModel>().loadWishlist();
      context.go(AppRoutes.main);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF005B5B),
          content: Text(
            authViewModel.errorMessage ?? AppTexts.loginFailed,
            style: const TextStyle(color: Colors.white),
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
                      'Welcome Back',
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
                      "Sign in to your account to continue",
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
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return AppTexts.emailRequired;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // PASSWORD
                          _buildTextField(
                            controller: _passwordController,
                            hint: "Password",
                            iconPath: 'assets/icons/lock-keyhole.svg',
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
                            touched: _passwordTouched,
                            errorText: _passwordError,
                            onChanged: _validatePassword,
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

                          // FORGOT PASSWORD
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => context.go(AppRoutes.forgotPassword),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF005B5B),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                "Forgot password?",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // CONTINUE BUTTON
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
                                      "Sign In",
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

                    // CREATE ACCOUNT
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF757575),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push(AppRoutes.register),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF005B5B),
                          ),
                          child: const Text(
                            "Sign Up",
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
