import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_routes.dart';
import '../../core/network/api_config.dart';
import '../../core/theme/app_color.dart';
import '../../core/widgets/app_text.dart';
import '../../data/models/user_profile_model.dart';
import '../auth/viewmodels/auth_view_model.dart';
import 'viewmodels/profile_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProfileViewModel>().loadProfile();
    });
  }

  Future<void> _logout() async {
    await context.read<AuthViewModel>().logout();
    if (!mounted) return;

    context.read<ProfileViewModel>().clearProfile();
    context.go(AppRoutes.login);
  }

  Future<void> _linkTelegram() async {
    final profile = context.read<ProfileViewModel>().profile;
    if (profile == null) return;

    final url = Uri.parse(
      'https://t.me/${ApiConfig.telegramBotUsername}?start=${profile.userId}',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Telegram')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.textPrimary,
          backgroundColor: AppColors.white,
          onRefresh: context.read<ProfileViewModel>().refreshProfile,
          child: ListView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            children: [
              const SizedBox(height: 20),
              const _TopBar(),
              const SizedBox(height: 22),
              const _UserCard(),
              const SizedBox(height: 20),
              _MenuCard(
                children: [
                  _MenuRow(
                    svgPath: "assets/icons/shopping-cart.svg",
                    title: 'My Orders',
                    onTap: () => context.push(AppRoutes.orders),
                  ),
                  _MenuRow(
                    svgPath: "assets/icons/bell-dot.svg",
                    title: 'Link Telegram Alerts',
                    onTap: _linkTelegram,
                  ),
                  _MenuRow(
                    svgPath: "assets/icons/bookmark.svg",
                    title: 'My Wishlist',
                    onTap: () => context.push(AppRoutes.wishlist),
                  ),
                  _MenuRow(
                    svgPath: "assets/icons/map-pinned.svg",
                    title: 'Shipping Address',
                    onTap: () => context.push(AppRoutes.shippingAddress),
                  ),
                  const _MenuRow(
                    svgPath: "assets/icons/bell-dot.svg",
                    title: 'Notifications',
                  ),
                  _MenuRow(
                    svgPath: "assets/icons/user-round-key.svg",
                    title: 'Change Password',
                    onTap: () => context.push(AppRoutes.changePassword),
                  ),
                  const _MenuRow(
                    svgPath: "assets/icons/info.svg",
                    title: 'About App',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SwipeLogoutButton(onLogout: _logout),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: AppText.titleLarge(
            'Setting',
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        IconButton(
          onPressed: () {},
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 36, height: 36),
          splashRadius: 20,
          icon: SvgPicture.asset(
            "assets/icons/search.svg",
            colorFilter: const ColorFilter.mode(
              AppColors.textPrimary,
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard();

  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<ProfileViewModel>();
    final profile = profileState.profile;
    final displayName = profile?.displayName ?? 'Member';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withAlpha(130)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withAlpha(20),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(AppRoutes.editProfile),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _UserAvatar(profile: profile, isLoading: profileState.isLoading),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.bodyMedium(
                      displayName,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          color: AppColors.textDisabled,
                          size: 14,
                        ),
                        SizedBox(width: 6),
                        AppText.bodyMedium(
                          'Member',
                          color: AppColors.textDisabled,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.profile, required this.isLoading});

  final UserProfileModel? profile;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = profile?.resolvedAvatarUrl;

    return ClipOval(
      child: SizedBox(
        width: 60,
        height: 60,
        child: avatarUrl == null
            ? ColoredBox(
                color: AppColors.primary50,
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : AppText.bodyMedium(
                          profile?.initials ?? 'MF',
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                ),
              )
            : CachedNetworkImage(
                imageUrl: avatarUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const ColoredBox(
                  color: AppColors.primary50,
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => ColoredBox(
                  color: AppColors.primary50,
                  child: Center(
                    child: AppText.bodyMedium(
                      profile?.initials ?? 'MF',
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withAlpha(130)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withAlpha(20),
            blurRadius: 18,
            offset: const Offset(0, 10),
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

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.svgPath, required this.title, this.onTap});

  final String svgPath;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 52,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              SvgPicture.asset(
                svgPath,
                colorFilter: const ColorFilter.mode(
                  AppColors.buttonColor,
                  BlendMode.srcIn,
                ),
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppText.bodyMedium(
                  title,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textDisabled,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SwipeLogoutButton extends StatefulWidget {
  const SwipeLogoutButton({super.key, required this.onLogout});

  final Future<void> Function() onLogout;

  @override
  State<SwipeLogoutButton> createState() => _SwipeLogoutButtonState();
}

class _SwipeLogoutButtonState extends State<SwipeLogoutButton> {
  double _dragValue = 0;
  bool _isFinished = false;
  bool _isLoggingOut = false;

  void _onHorizontalDragUpdate(DragUpdateDetails details, double maxWidth) {
    if (_isFinished) return;

    setState(() {
      _dragValue += (details.primaryDelta ?? 0) / (maxWidth - 60);
      _dragValue = _dragValue.clamp(0, 1);
    });
  }

  Future<void> _onHorizontalDragEnd(DragEndDetails details) async {
    if (_isFinished || _isLoggingOut) return;

    if (_dragValue > 0.8) {
      setState(() {
        _dragValue = 1;
        _isFinished = true;
        _isLoggingOut = true;
      });
      await widget.onLogout();
      return;
    }

    setState(() {
      _dragValue = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double handleSize = 54;
        const double padding = 4;
        final maxWidth = constraints.maxWidth;
        final availableWidth = maxWidth - handleSize - (padding * 2);
        final currentPosition = _dragValue * availableWidth;

        return Container(
          height: 64,
          width: maxWidth,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: AppColors.error.withValues(alpha: 0.10),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Opacity(
                  opacity: 1 - (_dragValue * 0.8),
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: [
                          AppColors.error.withValues(alpha: 0.95),
                          AppColors.error.withValues(alpha: 0.62),
                          AppColors.error.withValues(alpha: 0.82),
                        ],
                        stops: const [0, 0.5, 1],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: const Text(
                      'Swipe to logout',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: padding,
                top: padding,
                bottom: padding,
                width: currentPosition + handleSize,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.error.withValues(alpha: 0.15),
                        AppColors.error.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
              Positioned(
                left: padding + currentPosition,
                top: padding,
                bottom: padding,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    _onHorizontalDragUpdate(details, maxWidth);
                  },
                  onHorizontalDragEnd: (details) {
                    _onHorizontalDragEnd(details);
                  },
                  child: Container(
                    width: handleSize,
                    height: handleSize,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.error.withValues(alpha: 0.30),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _isLoggingOut
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.error,
                            ),
                          )
                        : const Icon(
                            Icons.logout_rounded,
                            color: AppColors.error,
                            size: 24,
                            weight: 100,
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
