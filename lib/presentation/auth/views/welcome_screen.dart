import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_texts.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/theme/app_color.dart';
import '../widgets/primary_button.dart';
import '../widgets/water_background.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.waterBlue,
        body: WaterBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText.authBrand(AppTexts.appName),
                  const Spacer(),
                  const AppText.authHeroTitle(AppTexts.waterDelivery),
                  const SizedBox(height: 8),
                  const SizedBox(
                    width: 250,
                    child: AppText.authHeroSubtitle(AppTexts.welcomeSubtitle),
                  ),
                  const SizedBox(height: 30),
                  const _WelcomeActions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeActions extends StatelessWidget {
  const _WelcomeActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PrimaryButton(
          title: AppTexts.login,
          isOnDark: true,
          onPressed: () => context.push(AppRoutes.login),
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          title: AppTexts.signUp,
          isOutlined: true,
          isOnDark: true,
          onPressed: () => context.push(AppRoutes.register),
        ),
      ],
    );
  }
}
