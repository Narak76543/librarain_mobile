import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_color.dart';
import '../../core/widgets/app_text.dart';
import '../../data/models/book_model.dart';
import '../../data/repositories/book_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../cart/cart_screen.dart';
import '../cart/viewmodels/cart_viewmodel.dart';
import '../profile/viewmodels/profile_viewmodel.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _refreshVersion = 0;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _sortOption = 'newest';

  late Future<List<BookModel>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  void _fetchBooks() {
    _booksFuture = BookRepository().getBooks(
      category: _selectedCategory,
      search: _searchQuery,
      sort: _sortOption,
    );
  }

  Future<void> _refreshShop() async {
    setState(() {
      _refreshVersion++;
      _fetchBooks();
    });
    await context.read<ProfileViewModel>().refreshProfile();
  }

  void _updateFilter({String? query, String? category, String? sort}) {
    setState(() {
      if (query != null) _searchQuery = query;
      if (category != null) _selectedCategory = category;
      if (sort != null) _sortOption = sort;
      _fetchBooks();
    });
  }

  List<String> get _activeFilters {
    final filters = <String>[];
    if (_selectedCategory != 'All') filters.add(_selectedCategory);
    return filters;
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
                _ShopSearchSection(
                  onSearch: (query) => _updateFilter(query: query),
                ),
                const SizedBox(height: 24),
                _ShopFiltersSection(
                  refreshVersion: _refreshVersion,
                  selectedCategory: _selectedCategory,
                  activeFilters: _activeFilters,
                  onCategorySelected: (cat) => _updateFilter(category: cat),
                  onRemoveFilter: (filter) {
                    if (filter == _selectedCategory) {
                      _updateFilter(category: 'All');
                    }
                  },
                ),
                const SizedBox(height: 24),
                FutureBuilder<List<BookModel>>(
                  future: _booksFuture,
                  builder: (context, snapshot) {
                    final books = snapshot.data ?? [];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ShopResultsToolbar(
                          count: books.length,
                          sortOption: _sortOption,
                          onSortChanged: (sort) => _updateFilter(sort: sort),
                        ),
                        const SizedBox(height: 16),
                        if (snapshot.connectionState == ConnectionState.waiting)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: CircularProgressIndicator(color: AppColors.buttonColor),
                            ),
                          )
                        else if (snapshot.hasError)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Text('Error loading books', style: const TextStyle(color: AppColors.error)),
                            ),
                          )
                        else if (books.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: AppText.bodyMedium('No books found.', color: AppColors.textDisabled),
                            ),
                          )
                        else
                          _ShopBooksGrid(books: books),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShopResultsToolbar extends StatelessWidget {
  const _ShopResultsToolbar({
    required this.count,
    required this.sortOption,
    required this.onSortChanged,
  });

  final int count;
  final String sortOption;
  final ValueChanged<String> onSortChanged;

  String _getSortLabel(String option) {
    switch (option) {
      case 'newest':
        return 'Newest';
      case 'price_asc':
        return 'Price: Low to High';
      case 'price_desc':
        return 'Price: High to Low';
      case 'rating':
        return 'Rating';
      default:
        return 'Newest';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppText.bodySmall(
          '$count books found',
          color: AppColors.textPrimary.withAlpha(170),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        const Spacer(),
        PopupMenuButton<String>(
          offset: const Offset(0, 40),
          color: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onSelected: onSortChanged,
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'newest', child: Text('Newest', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
            PopupMenuItem(value: 'price_asc', child: Text('Price: Low to High', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
            PopupMenuItem(value: 'price_desc', child: Text('Price: High to Low', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
            PopupMenuItem(value: 'rating', child: Text('Rating', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          ],
          child: Container(
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
                AppText.bodySmall(
                  'Sort by: ${_getSortLabel(sortOption)}',
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
        ),
      ],
    );
  }
}

class _ShopBooksGrid extends StatelessWidget {
  const _ShopBooksGrid({required this.books});

  final List<BookModel> books;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: books.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.58,
      ),
      itemBuilder: (context, index) {
        return _ShopBookCard(book: books[index]);
      },
    );
  }
}

class _ShopBookCard extends StatelessWidget {
  const _ShopBookCard({required this.book});

  final BookModel book;

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
                  const SizedBox(height: 6),
                  AppText.caption(
                    book.author,
                    color: AppColors.textPrimary.withAlpha(150),
                    fontSize: 9,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const _RatingStars(),
                      const SizedBox(width: 4),
                      AppText.caption(
                        book.ratingAverage,
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
                          '\$${book.price}',
                          color: AppColors.buttonColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.read<CartViewModel>().addToCart(book);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${book.title} added to cart!',
                                style: const TextStyle(color: AppColors.white),
                              ),
                              backgroundColor: AppColors.buttonColor,
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        child: Container(
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

  final BookModel book;

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
              child: book.coverUrl.isNotEmpty
                  ? Image.network(book.coverUrl, fit: BoxFit.cover)
                  : Container(color: AppColors.primary100),
            ),
            if (book.category != null)
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
                    book.category!.name.toUpperCase(),
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
  const _ShopSearchSection({required this.onSearch});

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
          final books = await BookRepository().getBooks(search: textEditingValue.text);
          return books;
        },
        onSelected: (BookModel selection) {
          onSearch(selection.title);
        },
        displayStringForOption: (BookModel option) => option.title,
        fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
          return Row(
            children: [
              const SizedBox(width: 20),
              SvgPicture.asset(
                'assets/icons/search.svg',
                colorFilter: const ColorFilter.mode(AppColors.buttonColor, BlendMode.srcIn),
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
                        colorFilter: const ColorFilter.mode(AppColors.buttonColor, BlendMode.srcIn),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
          );
        },
        optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<BookModel> onSelected, Iterable<BookModel> options) {
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
                      onTap: () => onSelected(option),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                        child: Row(
                          children: [
                            const Icon(Icons.history_rounded, size: 16, color: AppColors.textDisabled),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                option.title,
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
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

class _ShopFiltersSection extends StatefulWidget {
  const _ShopFiltersSection({
    required this.refreshVersion,
    required this.selectedCategory,
    required this.activeFilters,
    required this.onCategorySelected,
    required this.onRemoveFilter,
  });

  final int refreshVersion;
  final String selectedCategory;
  final List<String> activeFilters;
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<String> onRemoveFilter;

  @override
  State<_ShopFiltersSection> createState() => _ShopFiltersSectionState();
}

class _ShopFiltersSectionState extends State<_ShopFiltersSection> {
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
        if (widget.activeFilters.isNotEmpty) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(widget.activeFilters.length, (index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: index == widget.activeFilters.length - 1 ? 0 : 12,
                  ),
                  child: _ActiveFilterChip(
                    label: widget.activeFilters[index],
                    onRemove: () => widget.onRemoveFilter(widget.activeFilters[index]),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 26),
        ],
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
                        isSelected: categories[index] == widget.selectedCategory,
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

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRemove,
      child: Container(
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
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
              child: Container(
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
                    colorFilter: const ColorFilter.mode(
                      AppColors.buttonColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
            if (context.watch<CartViewModel>().items.isNotEmpty)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: AppText.caption(
                    '${context.watch<CartViewModel>().items.length}',
                    color: AppColors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
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
