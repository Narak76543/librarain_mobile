import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_color.dart';

const double _navHeight = 68;
const double _navRadius = _navHeight / 2;
const double _navInset = 5;
const double _selectedHeight = _navHeight - (_navInset * 2);
const double _selectedRadius = _selectedHeight / 2;

class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.cartCount = 0,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final int cartCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: Row(
        children: [
          Expanded(
            child: _FloatingNavContainer(
              child: Row(
                children: [
                  Expanded(
                    child: _FloatingNavItem(
                      index: 0,
                      currentIndex: currentIndex,
                      selectedIcon: Icons.home_rounded,
                      unselectedIcon: Icons.home_outlined,
                      onTap: onTap,
                    ),
                  ),
                  Expanded(
                    child: _FloatingNavItem(
                      index: 1,
                      currentIndex: currentIndex,
                      selectedIcon: Icons.storefront_rounded,
                      unselectedIcon: Icons.storefront_outlined,
                      onTap: onTap,
                    ),
                  ),
                  Expanded(
                    child: _FloatingNavItem(
                      index: 2,
                      currentIndex: currentIndex,
                      selectedIcon: Icons.shopping_bag_rounded,
                      unselectedIcon: Icons.shopping_bag_outlined,
                      showBadge: cartCount > 0,
                      onTap: onTap,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          _FloatingNavContainer(
            width: _navHeight,
            child: SizedBox.expand(
              child: _FloatingNavItem(
                index: 3,
                currentIndex: currentIndex,
                selectedIcon: Icons.person_rounded,
                unselectedIcon: Icons.person_outlined,
                onTap: onTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingNavContainer extends StatelessWidget {
  const _FloatingNavContainer({required this.child, this.width});

  final Widget child;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_navRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          width: width,
          height: _navHeight,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(_navRadius),
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.28),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                offset: const Offset(0, 14),
                blurRadius: 30,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(_navInset),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _FloatingNavItem extends StatelessWidget {
  const _FloatingNavItem({
    required this.index,
    required this.currentIndex,
    required this.selectedIcon,
    required this.unselectedIcon,
    required this.onTap,
    this.showBadge = false,
  });

  final int index;
  final int currentIndex;
  final IconData selectedIcon;
  final IconData unselectedIcon;
  final ValueChanged<int> onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;

    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(_selectedRadius),
          onTap: () => onTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            width: double.infinity,
            height: _selectedHeight,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.buttonColor.withValues(alpha: 0.92)
                  : AppColors.transparent,
              borderRadius: BorderRadius.circular(_selectedRadius),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.buttonColor.withValues(alpha: 0.28),
                        offset: const Offset(0, 8),
                        blurRadius: 16,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedScale(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      scale: isSelected ? 1.08 : 1.0,
                      child: Icon(
                        isSelected ? selectedIcon : unselectedIcon,
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textPrimary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 3),
                  ],
                ),
                if (showBadge)
                  Positioned(
                    right: 17,
                    top: 5,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
