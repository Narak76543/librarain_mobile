import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../../core/constants/app_routes.dart';
import '../../core/theme/app_color.dart';
import '../../core/widgets/app_text.dart';
import '../auth/widgets/water_background.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _openLogin(BuildContext context) {
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.waterBlue,
        body: WaterBackground(
          child: IntroductionScreen(
            rawPages: const [
              _IntroPage(
                icon: Icons.auto_stories_outlined,
                title: 'Discover Books',
                description:
                    'Browse ebooks, audiobooks, and magazines from your library in one simple place.',
              ),
              _IntroPage(
                icon: Icons.bookmark_added_outlined,
                title: 'Save Your Picks',
                description:
                    'Keep your favorite reads close and build a personal shelf for later.',
              ),
              _IntroPage(
                icon: Icons.phone_iphone_rounded,
                title: 'Read Anywhere',
                description:
                    'Enjoy your books from your phone or tablet whenever you have a quiet moment.',
              ),
            ],
            onDone: () => _openLogin(context),
            onSkip: () => _openLogin(context),
            showSkipButton: true,
            globalBackgroundColor: AppColors.transparent,
            controlsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
            dotsDecorator: DotsDecorator(
              activeColor: AppColors.white,
              color: AppColors.white.withAlpha(105),
              activeSize: const Size(28, 8),
              size: const Size(8, 8),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(99),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(99),
              ),
              spacing: const EdgeInsets.symmetric(horizontal: 4),
            ),
            skip: const AppText.button(
              'SKIP',
              color: AppColors.white,
              fontSize: 12,
            ),
            next: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.white,
              size: 30,
            ),
            done: const AppText.button(
              'START',
              color: AppColors.white,
              fontSize: 12,
            ),
            baseBtnStyle: TextButton.styleFrom(
              foregroundColor: AppColors.white,
              minimumSize: const Size(48, 44),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            curve: Curves.easeOutCubic,
            animationDuration: 320,
            safeAreaList: const [false, false, true, false],
          ),
        ),
      ),
    );
  }
}

class _IntroPage extends StatelessWidget {
  const _IntroPage({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 26, 28, 116),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _BrandLogo(),
            const Spacer(),
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: AppColors.white.withAlpha(32),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.white.withAlpha(70)),
              ),
              child: Icon(icon, color: AppColors.white, size: 54),
            ),
            const SizedBox(height: 34),
            AppText.titleMedium(
              title,
              color: AppColors.white,
              fontSize: 34,
              height: 1.12,
            ),
            const SizedBox(height: 14),
            AppText.bodyMedium(
              description,
              color: AppColors.primary50,
              height: 1.45,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  const _BrandLogo();

  @override
  Widget build(BuildContext context) {
    return const Text.rich(
      TextSpan(
        text: 'Library',
        style: TextStyle(
          color: AppColors.white,
          fontFamily: 'NunitoSans',
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        children: [
          TextSpan(
            text: 'on',
            style: TextStyle(color: AppColors.primary50),
          ),
        ],
      ),
    );
  }
}
