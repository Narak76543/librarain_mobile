import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_text_style.dart';
import '../../../core/widgets/app_text.dart';
import '../../../providers/shop_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../cart/viewmodels/cart_viewmodel.dart';
import '../widgets/book_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/shimmer_grid.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<ShopProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shopProvider = context.watch<ShopProvider>();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const AppText.titleSmall(
          "Get What You Want",
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart_outlined, color: AppColors.textPrimary),
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.buttonColor,
                      shape: BoxShape.circle,
                    ),
                    child: AppText.caption(
                      '${context.watch<CartViewModel>().items.length}',
                      color: AppColors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () => context.push(AppRoutes.cart),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // [1] SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
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
                        controller: _searchController,
                        cursorColor: AppColors.buttonColor,
                        style: AppTextStyle.bodyLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: "Search books, authors...",
                          hintStyle: AppTextStyle.bodyMedium.copyWith(
                            color: AppColors.textDisabled.withAlpha(190),
                            fontSize: 13,
                          ),
                          isCollapsed: true,
                        ),
                        onChanged: (val) => shopProvider.onSearchChanged(val),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const FilterBottomSheet(),
                        );
                      },
                      child: shopProvider.activeFilterCount > 0
                          ? Stack(
                              clipBehavior: Clip.none,
                              children: [
                                const Icon(Icons.tune_rounded, color: AppColors.buttonColor),
                                Positioned(
                                  top: -2,
                                  right: -2,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.buttonColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : const Icon(Icons.tune_rounded, color: AppColors.textDisabled),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // [2] ACTIVE FILTER CHIPS
            if (shopProvider.hasActiveFilters)
              Container(
                height: 40,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    if (shopProvider.selectedCategory.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(shopProvider.selectedCategory),
                          onDeleted: () => shopProvider.onCategorySelected(shopProvider.selectedCategory),
                          backgroundColor: AppColors.buttonColor.withAlpha(20),
                          labelStyle: AppTextStyle.caption.copyWith(
                            color: AppColors.buttonColor,
                            fontWeight: FontWeight.w600,
                          ),
                          deleteIconColor: AppColors.buttonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: AppColors.buttonColor.withAlpha(40)),
                          ),
                          onSelected: (_) {},
                        ),
                      ),
                    if (shopProvider.selectedSort.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(shopProvider.sortLabel),
                          onDeleted: () => shopProvider.onSortSelected(''),
                          backgroundColor: AppColors.buttonColor.withAlpha(20),
                          labelStyle: AppTextStyle.caption.copyWith(
                            color: AppColors.buttonColor,
                            fontWeight: FontWeight.w600,
                          ),
                          deleteIconColor: AppColors.buttonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: AppColors.buttonColor.withAlpha(40)),
                          ),
                          onSelected: (_) {},
                        ),
                      ),
                    if (shopProvider.priceFilterActive)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text('\$${shopProvider.minPrice.toInt()}–\$${shopProvider.maxPrice.toInt()}'),
                          onDeleted: () => shopProvider.clearPriceFilter(),
                          backgroundColor: AppColors.buttonColor.withAlpha(20),
                          labelStyle: AppTextStyle.caption.copyWith(
                            color: AppColors.buttonColor,
                            fontWeight: FontWeight.w600,
                          ),
                          deleteIconColor: AppColors.buttonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: AppColors.buttonColor.withAlpha(40)),
                          ),
                          onSelected: (_) {},
                        ),
                      ),
                  ],
                ),
              ),

            // [3] CATEGORY CHIPS
            Container(
              height: 35,
              margin: const EdgeInsets.only(bottom: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCategoryChip(context, shopProvider, 'All', ''),
                  ...shopProvider.categories.map((c) {
                    return _buildCategoryChip(context, shopProvider, c.name, c.slug);
                  }),
                ],
              ),
            ),

            // [4] RESULTS HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  AppText.bodyMedium(
                    "${shopProvider.total} books found",
                    color: AppColors.textPrimary.withAlpha(160),
                    fontWeight: FontWeight.w600,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const FilterBottomSheet(),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        children: [
                          AppText.bodySmall(
                            "Sort: ${shopProvider.sortLabel}",
                            color: AppColors.textPrimary.withAlpha(180),
                            fontWeight: FontWeight.w600,
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.textDisabled),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // [5] BOOK GRID
            if (shopProvider.isLoading)
              const ShimmerGrid()
            else if (shopProvider.books.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: EmptyState(
                  icon: Icons.book,
                  title: 'No Books Found',
                  subtitle: 'Try adjusting your filters or search query.',
                  buttonLabel: 'Clear Filters',
                  onButtonPressed: () => shopProvider.clearAllFilters(),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.60,
                ),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: shopProvider.books.length + (shopProvider.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == shopProvider.books.length) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.buttonColor));
                  }
                  final book = shopProvider.books[index];
                  return BookCard(
                    book: book,
                    onTap: () => context.push('/book/${book.id}'),
                    onAddToCart: () {
                      context.read<CartViewModel>().addToCart(book);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${book.title} added to cart!'),
                          backgroundColor: AppColors.buttonColor,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, ShopProvider shopProvider, String label, String slug) {
    final isSelected = shopProvider.selectedCategory == slug;
    return GestureDetector(
      onTap: () => shopProvider.onCategorySelected(slug),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: 35,
        alignment: Alignment.center,
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
      ),
    );
  }
}
