import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_color.dart';
import '../../core/widgets/app_text.dart';
import '../../data/models/book_model.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/repositories/book_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../shared/widgets/wishlist_heart.dart';
import '../profile/viewmodels/profile_viewmodel.dart';
import '../../core/constants/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _refreshVersion = 0;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProfileViewModel>().loadProfile();
    });
  }

  Future<void> _refreshHome() async {
    setState(() => _refreshVersion++);
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _HomeHeader(),
                const SizedBox(height: 10),
                _SearchSection(
                  onSearch: (query) {
                    setState(() {
                      _searchQuery = query;
                      _refreshVersion++;
                    });
                  },
                ),
                const SizedBox(height: 10),
                _CategoriesSection(
                  refreshVersion: _refreshVersion,
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (category) {
                    setState(() => _selectedCategory = category);
                  },
                ),
                const SizedBox(height: 10),
                const _BannerCarousel(),
                const SizedBox(height: 18),
                const _QuickActionSection(),
                const SizedBox(height: 18),
                _FeaturedSection(refreshVersion: _refreshVersion),
                const SizedBox(height: 10),
                _NewArrivalsSection(
                  refreshVersion: _refreshVersion,
                  selectedCategory: _selectedCategory,
                  searchQuery: _searchQuery,
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
                  Flexible(
                    child: AppText.subTitle(
                      displayName,
                      color: AppColors.textPrimary,
                      maxLines: 1,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
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

class _CategoriesSection extends StatefulWidget {
  const _CategoriesSection({
    required this.refreshVersion,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final int refreshVersion;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  @override
  State<_CategoriesSection> createState() => _CategoriesSectionState();
}

class _CategoriesSectionState extends State<_CategoriesSection> {
  late Future<List<String>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _loadCategories();
  }

  @override
  void didUpdateWidget(covariant _CategoriesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshVersion != widget.refreshVersion) {
      _categoriesFuture = _loadCategories();
    }
  }

  Future<List<String>> _loadCategories() async {
    try {
      final categories = await CategoryRepository().getCategories();
      return ['All', ...categories.map((category) => category.name)];
    } catch (_) {
      return const ['All'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<List<String>>(
          future: _categoriesFuture,
          builder: (context, snapshot) {
            final categories = snapshot.data ?? const ['All'];

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(categories.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == categories.length - 1 ? 0 : 10,
                    ),
                    child: GestureDetector(
                      onTap: () => widget.onCategorySelected(categories[index]),
                      child: _CategoryChip(
                        label: categories[index],
                        isSelected:
                            categories[index] == widget.selectedCategory,
                      ),
                    ),
                  );
                }),
              ),
            );
          },
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
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 1,
      ),
    );
  }
}

class _SearchSection extends StatelessWidget {
  const _SearchSection({required this.onSearch});

  final ValueChanged<String> onSearch;

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
      child: RawAutocomplete<BookModel>(
        optionsBuilder: (TextEditingValue textEditingValue) async {
          if (textEditingValue.text.isEmpty) {
            return const Iterable<BookModel>.empty();
          }
          // Fetch live suggestions from API
          final books = await BookRepository().getBooks(
            search: textEditingValue.text,
          );
          return books;
        },
        onSelected: (BookModel selection) {
          onSearch(selection.title);
        },
        displayStringForOption: (BookModel option) => option.title,
        fieldViewBuilder:
            (
              BuildContext context,
              TextEditingController textEditingController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted,
            ) {
              return Row(
                children: [
                  const SizedBox(width: 20),
                  SvgPicture.asset(
                    'assets/icons/search.svg',
                    colorFilter: const ColorFilter.mode(
                      AppColors.buttonColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      onSubmitted: (String value) {
                        onFieldSubmitted();
                        onSearch(value);
                      },
                      onChanged: (val) {
                        if (val.isEmpty) onSearch('');
                      },
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
                    color: Colors.transparent,
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
                            'assets/icons/scan-line.svg',
                            colorFilter: const ColorFilter.mode(
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
              );
            },
        optionsViewBuilder:
            (
              BuildContext context,
              AutocompleteOnSelected<BookModel> onSelected,
              Iterable<BookModel> options,
            ) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 8.0,
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final BookModel option = options.elementAt(index);
                        return InkWell(
                          onTap: () {
                            onSelected(option);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 12.0,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.history_rounded,
                                  size: 16,
                                  color: AppColors.textDisabled,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    option.title,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
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
    return SizedBox(
      width: 46,
      height: 46,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
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
                child: Material(
                  color: AppColors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onTap,
                    child: Center(
                      child: SvgPicture.asset(
                        iconPath,
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          AppColors.textPrimary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (badgeCount != null)
            Positioned(
              right: -2,
              top: -4,
              child: IgnorePointer(
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
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FeaturedSection extends StatefulWidget {
  const _FeaturedSection({required this.refreshVersion});

  final int refreshVersion;

  @override
  State<_FeaturedSection> createState() => _FeaturedSectionState();
}

class _FeaturedSectionState extends State<_FeaturedSection> {
  late Future<List<BookModel>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = BookRepository().getBooks(featured: true);
  }

  @override
  void didUpdateWidget(covariant _FeaturedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshVersion != widget.refreshVersion) {
      _booksFuture = BookRepository().getBooks(featured: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Featured'),
        const SizedBox(height: 12),
        FutureBuilder<List<BookModel>>(
          future: _booksFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(
                    color: AppColors.buttonColor,
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              );
            }

            final books = snapshot.data ?? [];
            if (books.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: AppText.bodySmall(
                    'No featured books.',
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(books.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == books.length - 1 ? 0 : 16,
                    ),
                    child: _BookModelFeaturedCard(book: books[index]),
                  );
                }),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _BookModelFeaturedCard extends StatelessWidget {
  const _BookModelFeaturedCard({required this.book});

  final BookModel book;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BookModelCover(
            book: book,
            height: 156,
            showFavorite: true,
            hasShadow: false, // Turn off inner shadow since container has one
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  '\$${book.price}',
                  color: AppColors.buttonColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NewArrivalsSection extends StatefulWidget {
  const _NewArrivalsSection({
    required this.refreshVersion,
    required this.selectedCategory,
    required this.searchQuery,
  });

  final int refreshVersion;
  final String selectedCategory;
  final String searchQuery;

  @override
  State<_NewArrivalsSection> createState() => _NewArrivalsSectionState();
}

class _NewArrivalsSectionState extends State<_NewArrivalsSection> {
  late Future<List<BookModel>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = BookRepository().getBooks(
      category: widget.selectedCategory,
      search: widget.searchQuery,
    );
  }

  @override
  void didUpdateWidget(covariant _NewArrivalsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshVersion != widget.refreshVersion ||
        oldWidget.selectedCategory != widget.selectedCategory ||
        oldWidget.searchQuery != widget.searchQuery) {
      _booksFuture = BookRepository().getBooks(
        category: widget.selectedCategory,
        search: widget.searchQuery,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'New Arrivals'),
        const SizedBox(height: 12),
        FutureBuilder<List<BookModel>>(
          future: _booksFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(
                    color: AppColors.buttonColor,
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              );
            }

            final books = snapshot.data ?? [];
            if (books.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: AppText.bodySmall(
                    'No new arrivals.',
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }

            return GridView.builder(
              itemCount: books.length,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.54,
              ),
              itemBuilder: (context, index) =>
                  _BookModelGridCard(book: books[index]),
            );
          },
        ),
      ],
    );
  }
}

class _BookModelGridCard extends StatelessWidget {
  const _BookModelGridCard({required this.book});

  final BookModel book;

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
          _BookModelCover(book: book, height: 210),
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
                          '\$${book.price}',
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

class _BookModelCover extends StatelessWidget {
  const _BookModelCover({
    required this.book,
    required this.height,
    this.showFavorite = false,
    this.hasShadow = false,
  });

  final BookModel book;
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
              child: CachedNetworkImage(
                imageUrl: book.coverUrl,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const Icon(Icons.error),
                placeholder: (context, url) => const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
            if (showFavorite)
              Positioned(
                right: 6,
                top: 6,
                child: WishlistHeart(bookId: book.id),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionSection extends StatelessWidget {
  const _QuickActionSection();

  @override
  Widget build(BuildContext context) {
    final allActions = [
      _QuickActionItem(
        title: 'My Orders',
        iconPath: 'assets/images/to-do-list.png',
        onTap: () => context.push(AppRoutes.orders),
      ),
      _QuickActionItem(
        title: 'Wishlist',
        iconPath: 'assets/images/list.png',
        onTap: () => context.push(AppRoutes.wishlist),
      ),
      _QuickActionItem(
        title: 'Cart',
        iconPath: 'assets/images/shopping-bag.png',
        onTap: () => context.push(AppRoutes.cart),
      ),
      _QuickActionItem(
        title: 'Shipping',
        iconData: Icons.local_shipping_outlined,
        onTap: () => context.push(AppRoutes.shippingAddress),
      ),
      _QuickActionItem(
        title: 'Password',
        iconData: Icons.lock_outline,
        onTap: () => context.push(AppRoutes.changePassword),
      ),
      _QuickActionItem(
        title: 'Profile',
        iconData: Icons.person_outline,
        onTap: () => context.push(AppRoutes.editProfile),
      ),
    ];

    // 2. Determine which items to display
    List<Widget> displayedItems;

    if (allActions.length > 6) {
      // Take the first 4 items and add a "More" item
      displayedItems = allActions.sublist(0, 5);
      displayedItems.add(
        _QuickActionItem(
          title: 'More',
          iconPath: 'assets/images/application.png',
          iconColor: Colors.grey,
          onTap: () {
            _showAllActionsBottomSheet(context, allActions);
          },
        ),
      );
    } else {
      displayedItems = allActions;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Quick Action'),
        const SizedBox(height: 16),

        // 3. Layout the items in rows of 3
        LayoutBuilder(
          builder: (context, constraints) {
            // Calculate item width dynamically so exactly 3 items fit per row
            // Adjust the subtraction value based on your desired horizontal spacing
            final itemWidth = (constraints.maxWidth - 32) / 3;

            return Wrap(
              spacing: 16, // Horizontal space between items
              runSpacing: 16, // Vertical space between rows
              children: displayedItems.map((item) {
                return SizedBox(width: itemWidth, child: item);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  // Optional: A clean way to show the rest of the items when "More" is tapped
  void _showAllActionsBottomSheet(BuildContext context, List<Widget> actions) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(spacing: 16, runSpacing: 16, children: actions),
        );
      },
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  const _QuickActionItem({
    required this.title,
    this.iconPath,
    this.iconData,
    this.iconColor,
    required this.onTap,
  });

  final String title;
  final String? iconPath;
  final IconData? iconData;
  final Color? iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: iconPath != null
                  ? Image.asset(iconPath!, width: 52, height: 52)
                  : Icon(
                      iconData,
                      size: 28,
                      color: iconColor ?? AppColors.buttonColor,
                    ),
            ),
          ),
          const SizedBox(height: 8),
          AppText.bodySmall(
            title,
            color: AppColors.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }
}
