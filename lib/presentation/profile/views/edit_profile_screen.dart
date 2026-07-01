import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_color.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../viewmodels/edit_profile_viewmodel.dart';
import '../viewmodels/profile_viewmodel.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditProfileViewModel(ProfileRepository())..loadProfile(),
      child: const _EditProfileView(),
    );
  }
}

class _EditProfileView extends StatelessWidget {
  const _EditProfileView();

  Future<void> _save(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final viewModel = context.read<EditProfileViewModel>();
    final isSuccess = await viewModel.saveProfile();
    if (!context.mounted) return;

    if (isSuccess) {
      context.read<ProfileViewModel>().setProfile(viewModel.profile);
      AppSnackbar.showSuccess(context, 'Profile updated successfully');
      context.pop();
    } else {
      AppSnackbar.showError(
        context,
        viewModel.errorMessage ?? 'Failed to update',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EditProfileViewModel>();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  _AvatarCard(viewModel: viewModel),
                  const SizedBox(height: 32),
                  const _SectionLabel('PERSONAL INFO'),
                  _FieldCard(
                    children: [
                      _ProfileField(
                        label: 'First Name (English)',
                        controller: viewModel.firstNameController,
                      ),
                      _ProfileField(
                        label: 'Last Name (English)',
                        controller: viewModel.lastNameController,
                      ),
                      _ProfileField(
                        label: 'First Name (ខ្មែរ)',
                        controller: viewModel.firstNameLocalController,
                      ),
                      _ProfileField(
                        label: 'Last Name (ខ្មែរ)',
                        controller: viewModel.lastNameLocalController,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const _SectionLabel('CONTACT INFO'),
                  _FieldCard(
                    children: [
                      _ProfileField(
                        label: 'Phone Number',
                        controller: viewModel.phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      // _ProfileField(
                      //   label: 'Telegram Username',
                      //   controller: viewModel.telegramController,
                      //   prefixText: '@',
                      // ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // const _SectionLabel('ADDRESS'),
                  // _FieldCard(
                  //   children: [
                  //     _ProfileField(
                  //       label: 'Home Address',
                  //       controller: viewModel.addressController,
                  //       minLines: 3,
                  //       maxLines: 5,
                  //     ),
                  //   ],
                  // ),
                  if (viewModel.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              viewModel.errorMessage!,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
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
                label: 'Save Changes',
                isLoading: viewModel.isLoading,
                onPressed: viewModel.isLoading ? null : () => _save(context),
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
              child: Text(
                'Edit Profile',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 56),
        ],
      ),
    );
  }
}

class _AvatarCard extends StatelessWidget {
  const _AvatarCard({required this.viewModel});

  final EditProfileViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = viewModel.profile?.avatarUrl;
    final pendingAvatarFile = viewModel.pendingAvatarFile;

    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            await viewModel.pickAvatar();
            if (!context.mounted) return;

            final message = viewModel.errorMessage;
            if (message != null) {
              AppSnackbar.showError(context, message);
            }
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 110,
                height: 110,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.buttonColor.withValues(alpha: 0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: pendingAvatarFile != null
                      ? Image.file(pendingAvatarFile, fit: BoxFit.cover)
                      : avatarUrl == null || avatarUrl.isEmpty
                      ? const ColoredBox(
                          color: AppColors.surface,
                          child: Icon(
                            Icons.person_rounded,
                            color: AppColors.textDisabled,
                            size: 60,
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: avatarUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.buttonColor,
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.person_rounded,
                            color: AppColors.textDisabled,
                            size: 60,
                          ),
                        ),
                ),
              ),
              if (viewModel.isLoading)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.40),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.buttonColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.buttonColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          pendingAvatarFile == null
              ? 'Tap to change photo'
              : 'Photo selected. Save changes to upload.',
          style: const TextStyle(
            color: AppColors.buttonColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.textPrimary.withValues(alpha: 0.8),
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
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

class _ProfileField extends StatefulWidget {
  const _ProfileField({
    required this.label,
    required this.controller,
    this.keyboardType,
  }) : prefixText = null,
       minLines = null,
       maxLines = 1;

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? prefixText;
  final int? minLines;
  final int maxLines;

  @override
  State<_ProfileField> createState() => _ProfileFieldState();
}

class _ProfileFieldState extends State<_ProfileField> {
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
          Text(
            widget.label,
            style: TextStyle(
              color: labelColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            cursorColor: AppColors.buttonColor,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefixText: widget.prefixText,
              prefixStyle: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
