import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/widgets/app_text.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../viewmodels/change_password_viewmodel.dart';
import '../viewmodels/profile_viewmodel.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChangePasswordViewModel(ProfileRepository()),
      child: const _ChangePasswordView(),
    );
  }
}

class _ChangePasswordView extends StatelessWidget {
  const _ChangePasswordView();

  Future<void> _submit(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final viewModel = context.read<ChangePasswordViewModel>();
    final isSuccess = await viewModel.changePassword();
    if (!context.mounted) return;

    if (isSuccess) {
      AppSnackbar.showSuccess(context, 'Password changed successfully');
      context.pop();
    } else {
      AppSnackbar.showError(
        context,
        viewModel.errorMessage ?? 'Failed to change password',
      );
    }
  }

  void _forgotPassword(BuildContext context) {
    final profile = context.read<ProfileViewModel>().profile;
    final email = profile?.email;
    final telegram = profile?.telegram;

    if (email == null || email.isEmpty) {
      AppSnackbar.showError(context, 'No email address linked to this profile.');
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (dialogContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText.titleMedium(
                  'Select OTP Channel',
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(height: 8),
                const AppText.bodyMedium(
                  'Choose where you want to receive the password reset OTP code:',
                  color: AppColors.textDisabled,
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.email_outlined, color: AppColors.buttonColor),
                  title: const AppText.bodyMedium(
                    'Email Address',
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  subtitle: AppText.bodySmall(
                    email,
                    color: AppColors.textDisabled,
                  ),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    _sendOtp(context, email, 'email');
                  },
                ),
                const Divider(color: AppColors.divider),
                ListTile(
                  leading: Icon(
                    Icons.telegram_rounded,
                    color: telegram != null && telegram.isNotEmpty
                        ? AppColors.primary
                        : AppColors.textDisabled,
                  ),
                  title: AppText.bodyMedium(
                    'Telegram Alerts',
                    color: telegram != null && telegram.isNotEmpty
                        ? AppColors.textPrimary
                        : AppColors.textDisabled,
                    fontWeight: FontWeight.w600,
                  ),
                  subtitle: AppText.bodySmall(
                    telegram != null && telegram.isNotEmpty
                        ? 'Send code to @$telegram'
                        : 'Telegram account not linked',
                    color: AppColors.textDisabled,
                  ),
                  enabled: telegram != null && telegram.isNotEmpty,
                  onTap: () {
                    Navigator.pop(dialogContext);
                    _sendOtp(context, email, 'telegram');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _sendOtp(BuildContext context, String email, String channel) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.buttonColor),
      ),
    );

    try {
      final success = await AuthRepository().forgotPassword(email: email, channel: channel);
      if (!context.mounted) return;
      Navigator.pop(context); // pop loading dialog

      if (success) {
        AppSnackbar.showSuccess(context, 'OTP code sent via $channel');
        context.push(AppRoutes.verifyOtp, extra: email);
      } else {
        AppSnackbar.showError(context, 'Failed to send OTP code');
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // pop loading dialog
      AppSnackbar.showError(context, e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ChangePasswordViewModel>();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                children: [
                  const _SectionLabel('UPDATE PASSWORD'),
                  _FieldCard(
                    children: [
                      _PasswordField(
                        label: 'Current Password',
                        controller: viewModel.currentPasswordController,
                        obscureText: viewModel.obscureCurrent,
                        onToggleVisibility: viewModel.toggleCurrentVisibility,
                      ),
                      _PasswordField(
                        label: 'New Password',
                        controller: viewModel.newPasswordController,
                        obscureText: viewModel.obscureNew,
                        onToggleVisibility: viewModel.toggleNewVisibility,
                      ),
                      _PasswordField(
                        label: 'Confirm New Password',
                        controller: viewModel.confirmPasswordController,
                        obscureText: viewModel.obscureConfirm,
                        onToggleVisibility: viewModel.toggleConfirmVisibility,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _forgotPassword(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const AppText.bodyMedium(
                        'Forgot Password?',
                        color: AppColors.buttonColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (viewModel.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppText.bodyMedium(
                              viewModel.errorMessage!,
                              color: AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    offset: const Offset(0, -4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: AppButton(
                label: 'Change Password',
                isLoading: viewModel.isLoading,
                onPressed: viewModel.isLoading ? null : () => _submit(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary,
                size: 18,
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: AppText.titleLarge(
                'Change Password',
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 56),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 10),
      child: AppText.bodySmall(
        title,
        color: AppColors.textPrimary.withValues(alpha: 0.8),
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(children.length, (index) {
          return DecoratedBox(
            decoration: BoxDecoration(
              border: index == children.length - 1
                  ? null
                  : Border(
                      bottom: BorderSide(
                        color: AppColors.border.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
            ),
            child: children[index],
          );
        }),
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscureText,
    required this.onToggleVisibility,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggleVisibility;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final labelColor = _focusNode.hasFocus
        ? AppColors.buttonColor
        : AppColors.textDisabled;

    return Container(
      color: _focusNode.hasFocus
          ? AppColors.buttonColor.withValues(alpha: 0.02)
          : Colors.transparent,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.bodySmall(
            widget.label,
            color: labelColor,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: widget.obscureText,
                  cursorColor: AppColors.buttonColor,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.onToggleVisibility,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  widget.obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textDisabled,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
