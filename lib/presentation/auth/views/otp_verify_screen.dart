import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_texts.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/widgets/app_text.dart';
import '../../../data/repositories/auth_repository.dart';
import '../viewmodels/otp_view_model.dart';

class OtpVerifyScreen extends StatelessWidget {
  const OtpVerifyScreen({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OtpViewModel(AuthRepository()),
      child: _OtpVerifyView(email: email),
    );
  }
}

class _OtpVerifyView extends StatefulWidget {
  const _OtpVerifyView({required this.email});

  final String email;

  @override
  State<_OtpVerifyView> createState() => _OtpVerifyViewState();
}

class _OtpVerifyViewState extends State<_OtpVerifyView>
    with SingleTickerProviderStateMixin {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  late final AnimationController _shakeController;

  String get _otpCode =>
      _controllers.map((controller) => controller.text).join();

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_otpCode.length != 6) {
      await _shakeController.forward(from: 0);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: AppText.bodyMedium(
            AppTexts.otpLengthInvalid,
            color: AppColors.white,
          ),
        ),
      );
      return;
    }

    final viewModel = context.read<OtpViewModel>();
    final success = await viewModel.verifyOtp(widget.email, _otpCode);

    if (!mounted) return;

    if (success) {
      context.go(AppRoutes.resetPassword, extra: widget.email);
    } else {
      await _shakeController.forward(from: 0);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText.bodyMedium(
            viewModel.errorMessage ?? AppTexts.otpVerificationFailed,
            color: AppColors.white,
          ),
        ),
      );
    }
  }

  Future<void> _resend() async {
    final viewModel = context.read<OtpViewModel>();
    final success = await viewModel.resend(widget.email);

    if (!mounted || success) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppText.bodyMedium(
          viewModel.errorMessage ?? AppTexts.resendOtpFailed,
          color: AppColors.white,
        ),
      ),
    );
  }

  void _handleOtpChanged(int index, String value) {
    if (value.length > 1) {
      _fillPastedOtp(index, value);
      return;
    }

    if (value.isEmpty) {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
      return;
    }

    if (index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else {
      _focusNodes[index].unfocus();
    }
  }

  void _fillPastedOtp(int startIndex, String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    for (var offset = 0; offset < digits.length; offset++) {
      final targetIndex = startIndex + offset;
      if (targetIndex >= _controllers.length) break;

      _controllers[targetIndex].text = digits[offset];
    }

    final nextIndex = math.min(startIndex + digits.length, _focusNodes.length);
    if (nextIndex < _focusNodes.length) {
      _focusNodes[nextIndex].requestFocus();
    } else {
      _focusNodes.last.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OtpViewModel>();
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
                            'Verify OTP',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E1E1E),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // SUBTITLE
                          Text(
                            "Enter the 6-digit code sent to\n${widget.email}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF757575),
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // CARD
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
                                AnimatedBuilder(
                                  animation: _shakeController,
                                  builder: (context, child) {
                                    final offset =
                                        math.sin(_shakeController.value * math.pi * 6) *
                                        8;
                                    return Transform.translate(
                                      offset: Offset(offset, 0),
                                      child: child,
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: List.generate(
                                      _controllers.length,
                                      (index) => Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            right: index == _controllers.length - 1
                                                ? 0
                                                : 8,
                                          ),
                                          child: _OtpDigitBox(
                                            controller: _controllers[index],
                                            focusNode: _focusNodes[index],
                                            onChanged: (value) =>
                                                _handleOtpChanged(index, value),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Didn't receive code? ",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF757575),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: viewModel.canResend ? _resend : null,
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color(0xFF005B5B),
                                        disabledForegroundColor: const Color(0xFF9E9E9E),
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        viewModel.canResend
                                            ? AppTexts.resend
                                            : '${viewModel.timerSeconds}s',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                                // Verify Button
                                SizedBox(
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: viewModel.isLoading ? null : _verify,
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
                                            "Verify",
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
                      ],
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
}

class _OtpDigitBox extends StatelessWidget {
  const _OtpDigitBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.phone, // Forces pure dial pad on Android/iOS
      textInputAction: TextInputAction.next,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFF1E1E1E),
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        counterText: '',
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF005B5B), width: 1.5),
        ),
      ),
      onChanged: (value) {
        if (value.length > 1) {
          onChanged(value);
          return;
        }

        onChanged(value);
      },
    );
  }
}
