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
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                children: [
                  if (canPop) ...[
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.textPrimary.withValues(
                                alpha: 0.04,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                  const Expanded(
                    child: AppText.titleLarge(
                      AppTexts.verifyOtpTitle,
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textPrimary.withValues(alpha: 0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const AppText.bodySmall(
                          'Enter the 6-digit code sent to your email',
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        const SizedBox(height: 24),
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
                        TextButton(
                          onPressed: viewModel.canResend ? _resend : null,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.buttonColor,
                            disabledForegroundColor: AppColors.textDisabled,
                          ),
                          child: AppText.caption(
                            viewModel.canResend
                                ? AppTexts.resend
                                : '${viewModel.timerSeconds}${AppTexts.secondsSuffix}',
                            color: viewModel.canResend
                                ? AppColors.buttonColor
                                : AppColors.textDisabled,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Verify Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              child: GestureDetector(
                onTap: viewModel.isLoading ? null : _verify,
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: viewModel.isLoading
                          ? AppColors.textDisabled
                          : AppColors.buttonColor,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: viewModel.isLoading
                          ? []
                          : [
                              BoxShadow(
                                color: AppColors.buttonColor.withValues(
                                  alpha: 0.35,
                                ),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (viewModel.isLoading) ...[
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const AppText.button(
                              'Verifying...',
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ] else ...[
                            const AppText.button(
                              AppTexts.verify,
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
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
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        counterText: AppTexts.empty,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.border.withValues(alpha: 0.8),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.border.withValues(alpha: 0.8),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.buttonColor),
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
