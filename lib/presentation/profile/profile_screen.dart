import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_routes.dart';
import '../../data/models/user_profile_model.dart';
import '../auth/viewmodels/auth_view_model.dart';
import 'viewmodels/profile_viewmodel.dart';

const Color _backgroundColor = Color(0xFFF3F4F6);
const Color _cardColor = Color(0xFFFFFFFF);
const Color _textPrimary = Color(0xFF1C1C1E);
const Color _textSecondary = Color(0xFF9CA3AF);
const Color _iconColor = Color(0xFF6B7280);
const Color _chevronColor = Color(0xFFD1D5DB);
const Color _dividerColor = Color(0xFFF3F4F6);
const Color _logoutColor = Color(0xFFEF4444);
const BoxShadow _cardShadow = BoxShadow(
  color: Color(0x0A000000),
  blurRadius: 8,
  offset: Offset(0, 2),
);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: _textPrimary,
          backgroundColor: _cardColor,
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
              const _MenuCard(
                children: [
                  _MenuRow(
                    icon: Icons.inventory_2_outlined,
                    title: 'My Orders',
                  ),
                  _MenuRow(
                    icon: Icons.favorite_border_rounded,
                    title: 'My Wishlist',
                  ),
                  _MenuRow(
                    icon: Icons.location_on_outlined,
                    title: 'Shipping Address',
                  ),
                  _MenuRow(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                  ),
                  _MenuRow(
                    icon: Icons.lock_outline_rounded,
                    title: 'Change Password',
                  ),
                  _MenuRow(
                    icon: Icons.info_outline_rounded,
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
          child: Text(
            'Setting',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 36, height: 36),
          splashRadius: 20,
          icon: const Icon(Icons.search_rounded, color: _iconColor, size: 22),
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

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => context.push(AppRoutes.editProfile),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [_cardShadow],
        ),
        child: Row(
          children: [
            _UserAvatar(profile: profile, isLoading: profileState.isLoading),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        color: _textSecondary,
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Member',
                        style: TextStyle(
                          color: _textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
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
                color: const Color(0xFFEFF6FF),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _iconColor,
                          ),
                        )
                      : Text(
                          profile?.initials ?? 'MF',
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              )
            : CachedNetworkImage(
                imageUrl: avatarUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const ColoredBox(
                  color: Color(0xFFEFF6FF),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _iconColor,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => ColoredBox(
                  color: const Color(0xFFEFF6FF),
                  child: Center(
                    child: Text(
                      profile?.initials ?? 'MF',
                      style: const TextStyle(
                        color: Color(0xFF2563EB),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
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
        color: _cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [_cardShadow],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(children.length, (index) {
          return DecoratedBox(
            decoration: BoxDecoration(
              border: index == children.length - 1
                  ? null
                  : const Border(
                      bottom: BorderSide(color: _dividerColor, width: 0.5),
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
  const _MenuRow({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: SizedBox(
        height: 52,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: _iconColor, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: _chevronColor,
                size: 22,
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
            color: _cardColor,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: _logoutColor.withValues(alpha: 0.10),
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
                          _logoutColor.withValues(alpha: 0.95),
                          _logoutColor.withValues(alpha: 0.62),
                          _logoutColor.withValues(alpha: 0.82),
                        ],
                        stops: const [0, 0.5, 1],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: const Text(
                      'Swipe to logout',
                      style: TextStyle(
                        color: _cardColor,
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
                        _logoutColor.withValues(alpha: 0.15),
                        _logoutColor.withValues(alpha: 0.05),
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
                      color: _cardColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _logoutColor.withValues(alpha: 0.30),
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
                              color: _logoutColor,
                            ),
                          )
                        : const Icon(
                            Icons.logout_rounded,
                            color: _logoutColor,
                            size: 24,
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
