import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_color.dart';
import '../../core/widgets/app_text.dart';
import '../../data/repositories/category_repository.dart';
import '../profile/viewmodels/profile_viewmodel.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _refreshVersion = 0;

  Future<void> _refreshShop() async {
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
          onRefresh: _refreshShop,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ShopHeader(),
                const SizedBox(height: 28),
                const _ShopSearchSection(),
                const SizedBox(height: 24),
                _ShopFiltersSection(refreshVersion: _refreshVersion),
                const SizedBox(height: 24),
                const _ShopResultsToolbar(),
                const SizedBox(height: 16),
                const _ShopBooksGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShopResultsToolbar extends StatelessWidget {
  const _ShopResultsToolbar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppText.bodySmall(
          '243 books found',
          color: AppColors.textPrimary.withAlpha(170),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        const Spacer(),
        Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppText.bodySmall(
                'Sort by: Relevance',
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textPrimary.withAlpha(170),
                size: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShopBook {
  const _ShopBook({
    required this.title,
    required this.author,
    required this.price,
    required this.rating,
    required this.category,
    required this.imagePath,
  });

  final String title;
  final String author;
  final String price;
  final String rating;
  final String category;
  final String imagePath;

  static const List<_ShopBook> books = [
    _ShopBook(
      title: 'The Midnight Library',
      author: 'Matt Haig',
      price: '\$18.50',
      rating: '4.2',
      category: 'Fiction',
      imagePath: 'assets/images/books/image.png',
    ),
    _ShopBook(
      title: 'The Silent Patient',
      author: 'Alex Michaelides',
      price: '\$14.20',
      rating: '4.5',
      category: 'Fiction',
      imagePath: 'assets/images/books/image-3.jpg',
    ),
    _ShopBook(
      title: 'The Art of Focus',
      author: 'Jordan Wilson',
      price: '\$19.99',
      rating: '4.0',
      category: 'Self-help',
      imagePath: 'assets/images/books/image-6.jpg',
    ),
    _ShopBook(
      title: 'Empire of Silence',
      author: 'Christopher Ruocchio',
      price: '\$22.00',
      rating: '4.8',
      category: 'History',
      imagePath: 'assets/images/books/image-8.jpg',
    ),
  ];
}

class _ShopBooksGrid extends StatelessWidget {
  const _ShopBooksGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: _ShopBook.books.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.62,
      ),
      itemBuilder: (context, index) {
        return _ShopBookCard(book: _ShopBook.books[index]);
      },
    );
  }
}

class _ShopBookCard extends StatelessWidget {
  const _ShopBookCard({required this.book});

  final _ShopBook book;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border.withAlpha(140)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withAlpha(20),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShopBookCover(book: book),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.bodySmall(
                    book.title,
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  AppText.caption(
                    book.author,
                    color: AppColors.textPrimary.withAlpha(150),
                    fontSize: 9,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const _RatingStars(),
                      const SizedBox(width: 4),
                      AppText.caption(
                        book.rating,
                        color: AppColors.textPrimary.withAlpha(150),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: AppText.button(
                          book.price,
                          color: AppColors.buttonColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppColors.buttonColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: AppColors.white,
                          size: 20,
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

class _ShopBookCover extends StatelessWidget {
  const _ShopBookCover({required this.book});

  final _ShopBook book;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 142,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(book.imagePath, fit: BoxFit.cover),
            ),
            Positioned(
              left: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AppText.caption(
                  book.category.toUpperCase(),
                  color: AppColors.buttonColor,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index == 4 ? Icons.star_border_rounded : Icons.star_rounded,
          color: AppColors.buttonColor,
          size: 10,
        );
      }),
    );
  }
}

class _ShopSearchSection extends StatelessWidget {
  const _ShopSearchSection();

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
                hintText: 'Search books, authors, ISBN...',
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

class _ShopFiltersSection extends StatefulWidget {
  const _ShopFiltersSection({required this.refreshVersion});

  final int refreshVersion;

  @override
  State<_ShopFiltersSection> createState() => _ShopFiltersSectionState();
}

class _ShopFiltersSectionState extends State<_ShopFiltersSection> {
  static const List<String> _activeFilters = ['Fiction', 'Under \$20'];

  late Future<List<String>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _loadCategories();
  }

  @override
  void didUpdateWidget(covariant _ShopFiltersSection oldWidget) {
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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(_activeFilters.length, (index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index == _activeFilters.length - 1 ? 0 : 12,
                ),
                child: _ActiveFilterChip(label: _activeFilters[index]),
              );
            }),
          ),
        ),
        const SizedBox(height: 26),
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
                    child: _CategoryChip(
                      label: categories[index],
                      isSelected: index == 0,
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

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.buttonColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.buttonColor.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText.button(
            label,
            color: AppColors.buttonColor,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.close_rounded,
            color: AppColors.buttonColor,
            size: 17,
          ),
        ],
      ),
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

class _ShopHeader extends StatelessWidget {
  const _ShopHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: AppText.titleLarge(
            'Get What You Want here',
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 16),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withAlpha(18),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: SvgPicture.asset(
                  'assets/icons/shopping-cart.svg',
                  colorFilter: ColorFilter.mode(
                    AppColors.buttonColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
