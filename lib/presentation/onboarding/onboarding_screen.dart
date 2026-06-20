import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_s2_flutter/core/theme/app_color.dart';

import '../../core/constants/app_routes.dart';

class _IntroData {
  final String imagePath;
  final String title;
  final String description;

  const _IntroData({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_IntroData> pages = const [
    _IntroData(
      imagePath: 'assets/images/books.png',
      title: 'Discover Books',
      description:
          'Browse ebooks, audiobooks, and magazines from your library in one simple place.',
    ),
    _IntroData(
      imagePath: 'assets/images/reading.png',
      title: 'Save Your Picks',
      description:
          'Keep your favorite reads close and build a personal shelf for later.',
    ),
    _IntroData(
      imagePath: 'assets/images/reading (1).png',
      title: 'Read Anywhere',
      description:
          'Enjoy your books from your phone or tablet whenever you have a quiet moment.',
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-cache images for better performance to prevent jank when swiping
    for (var page in pages) {
      precacheImage(AssetImage(page.imagePath), context);
    }
  }

  void _openLogin(BuildContext context) {
    context.go(AppRoutes.login);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // SKIP button at top right
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, right: 24),
                  child: AnimatedOpacity(
                    opacity: _currentPage == pages.length - 1 ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: TextButton(
                      onPressed: () => _openLogin(context),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF9E9E9E),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  itemCount: pages.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Image.asset(
                              pages[index].imagePath,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF9FAFB),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Illustration Here',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Color(0xFF9E9E9E)),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 48),

                          // Title
                          Text(
                            pages[index].title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E1E1E),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Description
                          Text(
                            pages[index].description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF757575),
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Control Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dynamic Dots
                    Row(
                      children: List.generate(pages.length, (dotIndex) {
                        final isActive = dotIndex == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.only(right: 8),
                          width: isActive ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.buttonColor
                                : AppColors.buttonColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),

                    // Next/Start Button morphing animation
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                      height: 56,
                      width: _currentPage == pages.length - 1 ? 140 : 56,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentPage == pages.length - 1) {
                            _openLogin(context);
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOutCubic,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: _currentPage == pages.length - 1
                            ? const Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : const Icon(
                                Icons.arrow_forward_rounded,
                                size: 24,
                              ),
                      ),
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
