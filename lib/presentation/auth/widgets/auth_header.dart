import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/widgets/app_text.dart';
import 'water_background.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.fallbackRoute = AppRoutes.login,
  });

  final String title;
  final bool showBackButton;
  final String fallbackRoute;

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(fallbackRoute);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 330,
      child: WaterBackground(
        showWave: true,
        waveHeight: 105,
        child: Stack(
          children: [
            if (showBackButton)
              SafeArea(
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.white,
                    size: 16,
                  ),
                  onPressed: () => _handleBack(context),
                ),
              ),

            Positioned(
              left: 28,
              bottom: 130,
              child: AppText.authScreenTitle(title),
            ),
          ],
        ),
      ),
    );
  }
}
