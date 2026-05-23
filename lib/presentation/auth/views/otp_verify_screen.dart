import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_texts.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_text_style.dart';
import '../../../core/widgets/app_text.dart';
import '../../../data/repositories/auth_repository.dart';
import '../viewmodels/otp_view_model.dart';
import '../widgets/auth_header.dart';
import '../widgets/primary_button.dart';

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

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AuthHeader(
              title: AppTexts.verifyOtpTitle,
              fallbackRoute: AppRoutes.forgotPassword,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _shakeController,
                    builder: (context, child) {
                      final offset =
                          math.sin(_shakeController.value * math.pi * 6) * 8;
                      return Transform.translate(
                        offset: Offset(offset, 0),
                        child: child,
                      );
                    },
                    child: Row(
                      children: List.generate(
                        _controllers.length,
                        (index) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: index == _controllers.length - 1 ? 0 : 8,
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
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: viewModel.canResend ? _resend : null,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      disabledForegroundColor: AppColors.textDisabled,
                    ),
                    child: AppText.caption(
                      viewModel.canResend
                          ? AppTexts.resend
                          : '${viewModel.timerSeconds}${AppTexts.secondsSuffix}',
                      color: viewModel.canResend
                          ? AppColors.primary
                          : AppColors.textDisabled,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    title: AppTexts.verify,
                    isLoading: viewModel.isLoading,
                    onPressed: _verify,
                  ),
                ],
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
      style: AppTextStyle.titleSmall.copyWith(color: AppColors.textPrimary),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        counterText: AppTexts.empty,
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.primary100),
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
