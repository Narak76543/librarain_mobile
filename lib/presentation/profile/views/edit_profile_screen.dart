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
      backgroundColor: AppColors.divider,
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _AvatarCard(viewModel: viewModel),
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
                  const _SectionLabel('CONTACT INFO'),
                  _FieldCard(
                    children: [
                      _ProfileField(
                        label: 'Phone',
                        controller: viewModel.phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      _ProfileField(
                        label: 'Telegram',
                        controller: viewModel.telegramController,
                        prefixText: '@',
                      ),
                    ],
                  ),
                  const _SectionLabel('ADDRESS'),
                  _FieldCard(
                    children: [
                      _ProfileField(
                        label: 'Address',
                        controller: viewModel.addressController,
                        minLines: 3,
                        maxLines: 5,
                      ),
                    ],
                  ),
                  if (viewModel.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      viewModel.errorMessage!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
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
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Edit Profile',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
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

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 26),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
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
                  width: 88,
                  height: 88,
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: pendingAvatarFile != null
                        ? Image.file(pendingAvatarFile, fit: BoxFit.cover)
                        : avatarUrl == null || avatarUrl.isEmpty
                        ? const ColoredBox(
                            color: AppColors.divider,
                            child: Icon(
                              Icons.person_rounded,
                              color: AppColors.textDisabled,
                              size: 54,
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: avatarUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.accent,
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.person_rounded,
                              color: AppColors.textDisabled,
                              size: 54,
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
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.white,
                      size: 17,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            pendingAvatarFile == null
                ? 'Tap to change photo'
                : 'Photo selected. Save changes to upload.',
            style: TextStyle(
              color: AppColors.textDisabled,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
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
      padding: const EdgeInsets.fromLTRB(4, 22, 0, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textDisabled,
          fontSize: 13,
          fontWeight: FontWeight.w500,
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
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                  : const Border(
                      bottom: BorderSide(color: AppColors.divider, width: 0.5),
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
    this.prefixText,
    this.minLines,
    this.maxLines = 1,
  });

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
        ? AppColors.accent
        : AppColors.textDisabled;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              color: labelColor,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            cursorColor: AppColors.accent,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              prefixText: widget.prefixText,
              prefixStyle: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.only(top: 5),
            ),
          ),
        ],
      ),
    );
  }
}
