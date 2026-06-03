import 'package:flutter/foundation.dart';
import 'dart:async';
import '../data/models/book_model.dart';
import '../data/models/category_model.dart';
import '../data/repositories/book_repository.dart';

class ShopProvider extends ChangeNotifier {
  final _repo = BookRepository();

  // State
  List<BookModel>     books             = [];
  List<CategoryModel> categories        = [];
  int                 total             = 0;
  bool                isLoading         = false;
  bool                isLoadingMore     = false;
  String              errorMessage      = '';

  // Filters
  String  searchQuery       = '';
  String  selectedCategory  = '';
  String  selectedSort      = '';
  double  minPrice          = 0;
  double  maxPrice          = 100;
  bool    priceFilterActive = false;

  // Pagination
  int  _offset = 0;
  final int _limit = 10;
  bool get hasMore => books.length < total;

  // Search debounce timer
  Timer? _searchTimer;

  // Init — called when Shop tab opens
  Future<void> init() async {
    if (categories.isEmpty) await loadCategories();
    if (books.isEmpty) await loadBooks(reset: true);
  }

  Future<void> loadCategories() async {
    try {
      categories = await _repo.getCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load categories: $e');
    }
  }

  Future<void> loadBooks({bool reset = false}) async {
    if (reset) {
      _offset = 0;
      books   = [];
    }

    if (reset) {
      isLoading = true;
    } else {
      isLoadingMore = true;
    }
    notifyListeners();

    try {
      final result = await _repo.getBooksPaginated(
        search:   searchQuery.isEmpty      ? null : searchQuery,
        category: selectedCategory.isEmpty ? null : selectedCategory,
        sort:     selectedSort.isEmpty     ? null : selectedSort,
        minPrice: priceFilterActive        ? minPrice : null,
        maxPrice: priceFilterActive        ? maxPrice : null,
        limit:    _limit,
        offset:   _offset,
      );

      final newBooks = result['books'] as List<BookModel>;
      if (reset) {
        books = newBooks;
      } else {
        books.addAll(newBooks);
      }
      total   = result['total'] as int;
      _offset = books.length;
      errorMessage = '';

    } catch (e) {
      errorMessage = 'Failed to load books. Check your connection.';
      debugPrint('Shop load error: $e');
    } finally {
      isLoading     = false;
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore || isLoading || !hasMore) return;
    await loadBooks(reset: false);
  }

  // Search with 500ms debounce
  void onSearchChanged(String query) {
    _searchTimer?.cancel();
    searchQuery = query;
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      loadBooks(reset: true);
    });
  }

  void onCategorySelected(String slug) {
    selectedCategory = selectedCategory == slug ? '' : slug;
    loadBooks(reset: true);
    notifyListeners();
  }

  void onSortSelected(String sort) {
    selectedSort = sort;
    loadBooks(reset: true);
    notifyListeners();
  }

  void onPriceRangeApplied(double min, double max) {
    minPrice          = min;
    maxPrice          = max;
    priceFilterActive = true;
    loadBooks(reset: true);
    notifyListeners();
  }

  void clearPriceFilter() {
    priceFilterActive = false;
    minPrice          = 0;
    maxPrice          = 100;
    loadBooks(reset: true);
    notifyListeners();
  }

  void clearAllFilters() {
    searchQuery       = '';
    selectedCategory  = '';
    selectedSort      = '';
    priceFilterActive = false;
    minPrice          = 0;
    maxPrice          = 100;
    loadBooks(reset: true);
    notifyListeners();
  }

  bool get hasActiveFilters =>
    selectedCategory.isNotEmpty ||
    selectedSort.isNotEmpty     ||
    priceFilterActive;

  int get activeFilterCount {
    int n = 0;
    if (selectedCategory.isNotEmpty) n++;
    if (selectedSort.isNotEmpty)     n++;
    if (priceFilterActive)           n++;
    return n;
  }

  String get sortLabel {
    switch (selectedSort) {
      case 'newest':     return 'Newest';
      case 'price_asc':  return 'Price ↑';
      case 'price_desc': return 'Price ↓';
      case 'rating':     return 'Top Rated';
      default:           return 'Relevance';
    }
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }
}
