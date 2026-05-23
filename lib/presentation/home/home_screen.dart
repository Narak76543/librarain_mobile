import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_color.dart';
import '../../core/widgets/app_text.dart';
import '../../data/models/user_profile_model.dart';
import '../profile/viewmodels/profile_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProfileViewModel>().loadProfile();
    });
  }

  Future<void> _refreshHome() async {
    await context.read<ProfileViewModel>().refreshProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.buttonColor,
          backgroundColor: AppColors.white,
          displacement: 28,
          onRefresh: _refreshHome,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HomeHeader(),
                SizedBox(height: 24),
                _SearchSection(),
                SizedBox(height: 24),
                _BannerCarousel(),
                SizedBox(height: 24),
                _CategoriesSection(),
                SizedBox(height: 24),
                _BooksSection(
                  title: 'Featured',
                  books: _Book.featuredBooks,
                  layout: _BooksSectionLayout.horizontal,
                ),
                SizedBox(height: 24),
                _BooksSection(
                  title: 'New Arrivals',
                  books: _Book.newArrivalBooks,
                  layout: _BooksSectionLayout.grid,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileViewModel>().profile;
    final displayName = profile?.displayName ?? 'Member';

    return Row(
      children: [
        _ProfileAvatar(profile: profile),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: AppText.subTitle(
                      'Good Morning',
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Expanded(
                    child: AppText.subTitle(
                      displayName,
                      color: AppColors.textPrimary,
                      maxLines: 1,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.verified_rounded,
                    color: AppColors.primary400,
                    size: 15,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _HeaderIconButton(iconPath: 'assets/icons/heart.svg', onTap: () {}),
        const SizedBox(width: 10),
        _HeaderIconButton(
          iconPath: 'assets/icons/bell.svg',
          badgeCount: 12,
          onTap: () {},
        ),
      ],
    );
  }
}

class _Book {
  const _Book({
    required this.title,
    required this.author,
    required this.price,
    required this.imagePath,
    this.isFavorite = false,
  });

  final String title;
  final String author;
  final String price;
  final String imagePath;
  final bool isFavorite;

  static const List<_Book> featuredBooks = [
    _Book(
      title: 'The Modern Art of Storytelling',
      author: 'Julian Barnes',
      price: '\$24.99',
      imagePath: 'assets/images/books/image.png',
      isFavorite: true,
    ),
    _Book(
      title: 'Echoes of Silence',
      author: 'Sarah J. Maas',
      price: '\$19.50',
      imagePath: 'assets/images/books/image-2.jpg',
      isFavorite: true,
    ),
    _Book(
      title: 'Journey to the Unknown',
      author: 'David Mitchell',
      price: '\$22.00',
      imagePath: 'assets/images/books/image-3.jpg',
    ),
    _Book(
      title: 'Designing Tomorrow',
      author: 'Clara Finch',
      price: '\$28.00',
      imagePath: 'assets/images/books/image-4.jpg',
    ),
  ];

  static const List<_Book> newArrivalBooks = [
    _Book(
      title: 'Architecture Today',
      author: 'Liam Hudson',
      price: '\$32.00',
      imagePath: 'assets/images/books/image-5.jpg',
    ),
    _Book(
      title: 'Natural Habits',
      author: 'James Clear',
      price: '\$18.99',
      imagePath: 'assets/images/books/image-6.jpg',
    ),
    _Book(
      title: 'Creative Flows',
      author: 'Maria Popova',
      price: '\$26.50',
      imagePath: 'assets/images/books/image-7.jpg',
    ),
    _Book(
      title: 'The Peak Within',
      author: 'Alex Honnold',
      price: '\$21.00',
      imagePath: 'assets/images/books/image-8.jpg',
    ),
  ];
}

enum _BooksSectionLayout { horizontal, grid }

class _BooksSection extends StatelessWidget {
  const _BooksSection({
    required this.title,
    required this.books,
    required this.layout,
  });

  final String title;
  final List<_Book> books;
  final _BooksSectionLayout layout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: title),
        const SizedBox(height: 12),
        if (layout == _BooksSectionLayout.horizontal)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(books.length, (index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: index == books.length - 1 ? 0 : 16,
                  ),
                  child: _FeaturedBookCard(book: books[index]),
                );
              }),
            ),
          )
        else
          GridView.builder(
            itemCount: books.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.54,
            ),
            itemBuilder: (context, index) => _BookGridCard(book: books[index]),
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppText.titleSmall(
            title,
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        const AppText.button(
          'See all',
          color: AppColors.buttonColor,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ],
    );
  }
}

class _FeaturedBookCard extends StatelessWidget {
  const _FeaturedBookCard({required this.book});

  final _Book book;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 118,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BookCover(
            book: book,
            height: 156,
            showFavorite: true,
            hasShadow: true,
          ),
          const SizedBox(height: 10),
          AppText.bodySmall(
            book.title,
            color: AppColors.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            height: 1.2,
          ),
          const SizedBox(height: 3),
          AppText.caption(
            book.author,
            color: AppColors.textPrimary.withAlpha(150),
            fontSize: 9.5,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          AppText.button(
            book.price,
            color: AppColors.buttonColor,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ],
      ),
    );
  }
}

class _BookGridCard extends StatelessWidget {
  const _BookGridCard({required this.book});

  final _Book book;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withAlpha(130)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withAlpha(34),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: AppColors.buttonColor.withAlpha(18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BookCover(book: book, height: 210),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.bodySmall(
                    book.title,
                    color: AppColors.textPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  AppText.caption(
                    book.author,
                    color: AppColors.textPrimary.withAlpha(150),
                    fontSize: 8,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: AppText.button(
                          book.price,
                          color: AppColors.buttonColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: AppColors.buttonColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: AppColors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookCover extends StatelessWidget {
  const _BookCover({
    required this.book,
    required this.height,
    this.showFavorite = false,
    this.hasShadow = false,
  });

  final _Book book;
  final double height;
  final bool showFavorite;
  final bool hasShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: AppColors.textPrimary.withAlpha(26),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Image.asset(book.imagePath, fit: BoxFit.cover),
            ),
            if (showFavorite)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textPrimary.withAlpha(20),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    book.isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: AppColors.buttonColor,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BannerCarousel extends StatefulWidget {
  const _BannerCarousel();

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  static const List<String> _bannerImages = [
    'assets/images/banner-1.jpg',
    'assets/images/banner-02.jpg',
    'assets/images/banner-3.jpg',
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 156,
            viewportFraction: 1,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 900),
            autoPlayCurve: Curves.easeInOutCubic,
            enlargeCenterPage: false,
            enableInfiniteScroll: true,
            onPageChanged: (index, reason) {
              setState(() => _currentIndex = index);
            },
          ),
          items: _bannerImages.map((imagePath) {
            return Builder(
              builder: (context) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    imagePath,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_bannerImages.length, (index) {
            final bool isActive = index == _currentIndex;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              width: isActive ? 18 : 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.buttonColor
                    : AppColors.primary100.withAlpha(150),
                borderRadius: BorderRadius.circular(99),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection();

  static const List<String> _categories = [
    'All',
    'Fiction',
    'Science',
    'History',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText.titleSmall(
          'Categories',
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(_categories.length, (index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index == _categories.length - 1 ? 0 : 10,
                ),
                child: _CategoryChip(
                  label: _categories[index],
                  isSelected: index == 0,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.isSelected});

  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.buttonColor : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? AppColors.buttonColor : AppColors.border,
        ),
      ),
      child: AppText.button(
        label,
        color: isSelected ? AppColors.white : AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        height: 1,
      ),
    );
  }
}

class _SearchSection extends StatelessWidget {
  const _SearchSection();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.buttonColor, width: 0.4),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withAlpha(14),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          SvgPicture.asset(
            'assets/icons/search.svg',
            colorFilter: ColorFilter.mode(
              AppColors.buttonColor,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              cursorColor: AppColors.primary,
              textInputAction: TextInputAction.search,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Search books',
                hintStyle: TextStyle(
                  color: AppColors.textDisabled.withAlpha(190),
                  fontSize: 13,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: AppColors.buttonColor.withValues(alpha: 0.1),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {},
              child: SizedBox(
                width: 42,
                height: 42,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(
                    'assets/icons/spline-pointer.svg',
                    colorFilter: ColorFilter.mode(
                      AppColors.buttonColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({this.profile});

  final UserProfileModel? profile;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = profile?.resolvedAvatarUrl;

    return Container(
      width: 50,
      height: 50,
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary100, AppColors.accent100],
        ),
      ),
      child: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: SizedBox(
            width: 42,
            height: 42,
            child: avatarUrl == null
                ? ColoredBox(
                    color: AppColors.primary50,
                    child: Center(
                      child: AppText.button(
                        profile?.initials ?? 'MF',
                        color: AppColors.primary,
                        fontSize: 13,
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
                          width: 16,
                          height: 16,
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
                        child: AppText.button(
                          profile?.initials ?? 'MF',
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.iconPath,
    required this.onTap,
    this.badgeCount,
  });

  final String iconPath;
  final VoidCallback onTap;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: const CircleBorder(),
      elevation: 8,
      shadowColor: AppColors.textPrimary.withAlpha(18),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                iconPath,
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  AppColors.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
              if (badgeCount != null)
                Positioned(
                  right: -2,
                  top: -4,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: AppText.caption(
                      '$badgeCount',
                      color: AppColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
