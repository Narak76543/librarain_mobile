import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_texts.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/widgets/app_text.dart';
import '../viewmodels/auth_view_model.dart';

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
        decoration: const BoxDecoration(
          gradient: AppGradients.background,
        ),
        child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 50),

                // TOP LOGO
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/app_logo.png'),
                    ),
                    borderRadius: BorderRadius.circular(24),
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

                const Text(
                  "Join us to start exploring our library",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Color(0xFF808080)),
                ),

                const SizedBox(height: 40),

                // NAME
                _buildTextField(
                    iconPath: 'assets/icons/user-round.svg',
                  controller: _nameController,
                  hint: "Full Name",
                //  icon: Icons.person_outline,
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
                  hint: "E-mail",
                 // icon: Icons.email_outlined,
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
                  //icon: Icons.phone_outlined,
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
                 // icon: Icons.lock_outline,
                  obscure: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppTexts.passwordRequired;
                    }
                    if (value.length < 6) return AppTexts.passwordMinLength;
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // SIGN UP BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: authViewModel.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005B5B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      shadowColor: const Color(0xFF005B5B).withOpacity(0.5),
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
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // DIVIDER
                Row(
                  children: [
                    const Expanded(
                      child: Divider(color: Color(0xFFEEEEEE), thickness: 1),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Already have an account?",
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9A9A9A),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(color: Color(0xFFEEEEEE), thickness: 1),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => context.push(AppRoutes.login),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5F5F7),
                      foregroundColor: const Color(0xFF1E1E1E),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
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
    VoidCallback? onChanged,
  }) {
    bool hasError = touched && errorText != null && errorText.isNotEmpty;
    return TextFormField(
      onTap: (){
        setState(() {
          if(controller == _emailController) {
            _emailTouched = true;
          } else if(controller == _passwordController) {
            _passwordTouched = true;
          }
        });
      },
      controller: controller,
      obscureText: obscure,
      validator: validator,
      onChanged: (_) => onChanged?.call(),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(iconPath, width: 20, height: 20),
        ),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF5F5F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        errorText: hasError ? errorText : null,
      ),
    );
  }
}
