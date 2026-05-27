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
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image Placeholder
                        SizedBox(
                          width: 280,
                          height: 280,
                          child: Image.asset(
                            pages[index].imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF5F5F7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text(
                                    'Image Placeholder\n(Add PNG later)',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color(0xFF9A9A9A)),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 60),

                        // Dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(pages.length, (dotIndex) {
                            final isActive = dotIndex == _currentPage;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.black
                                    : Colors.transparent,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1.5,
                                ),
                                shape: BoxShape.circle,
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 30),

                        // Title
                        Text(
                          pages[index].title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Description
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          child: Text(
                            pages[index].description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF6B7280),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Bottom Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => _openLogin(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'SKIP',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_currentPage == pages.length - 1) {
                          _openLogin(context);
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 36,
                          vertical: 16,
                        ),
                      ),
                      child: Text(
                        _currentPage == pages.length - 1 ? 'START' : 'NEXT',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
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
