import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_texts.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/widgets/app_text.dart';
import '../viewmodels/auth_view_model.dart';
import '../../../providers/wishlist_provider.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_button.dart';

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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_texts.dart';
import '../../../core/theme/app_color.dart';
import '../viewmodels/auth_view_model.dart';

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
      context.read<WishlistProvider>().loadWishlist();
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 30),

                // TOP LOGO
                Image.asset(
                  'assets/images/app_logo.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),

                // TITLE
                const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1E1E),
                  ),
                ),

                SizedBox(height: 10),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "To sign in to an account in the application,\nenter your email and password",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Color(0xFF9A9A9A),
                    ),
                  ),
                ),

                const SizedBox(height: 34),

                // EMAIL
                _buildTextField(
                  controller: _emailController,
                  hint: "E-mail",
                  icon: Icons.email_outlined,
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
                  icon: Icons.lock_outline,
                  obscure: obscurePassword,
                  suffix: IconButton(
                    splashRadius: 20,
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF9A9A9A),
                      size: 20,
                    ),
                  ),
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

                const SizedBox(height: 8),

                // FORGOT PASSWORD
                Center(
                  child: GestureDetector(
                    onTap: () => context.go(AppRoutes.forgotPassword),
                    child: const Text(
                      "Forgot password?",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // CONTINUE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: authViewModel.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005B5B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
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
                            "Continue",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // DIVIDER
                Row(
                  children: [
                    const Expanded(child: Divider(color: Color(0xFFEEEEEE), thickness: 1)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Don't have an account yet?",
                        style: TextStyle(fontSize: 13, color: Color(0xFF9A9A9A)),
                      ),
                    ),
                    const Expanded(child: Divider(color: Color(0xFFEEEEEE), thickness: 1)),
                  ],
                ),

                const SizedBox(height: 18),

                // CREATE ACCOUNT BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => context.push(AppRoutes.register),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5F5F7),
                      foregroundColor: const Color(0xFF1E1E1E),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      "Create an account",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Telegram BUTTON
                _socialButton(
                  onTap: () {},
                  image: 'assets/images/telegram.png',
                  text: "Sign in with Telegram",
                ),

                const SizedBox(height: 16),

                // GOOGLE BUTTON
                _socialButton(
                  onTap: () {},
                  image: "assets/icons/google.png",
                  text: "Sign in with Google",
                ),

                const SizedBox(height: 24),

                // TERMS
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(fontSize: 11, color: Color(0xFF9A9A9A)),
                    children: [
                      TextSpan(
                        text:
                            "By clicking “Continue”, I have read and agree\nwith the ",
                      ),
                      TextSpan(
                        text: "Term Sheet",
                        style: TextStyle(
                          color: Color(0xFF005B5B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: ", "),
                      TextSpan(
                        text: "Privacy Policy",
                        style: TextStyle(
                          color: Color(0xFF005B5B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    Widget? suffix,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        style: const TextStyle(fontSize: 14, color: Color(0xFF1E1E1E)),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 13),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFF005B5B),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
          ),
          suffixIcon: suffix,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _socialButton({
    IconData? icon,
    String? image,
    required String text,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, size: 22, color: const Color(0xFF1E1E1E)),
            if (image != null) Image.asset(image, width: 22, height: 22),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
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


