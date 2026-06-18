import 'package:flutter/material.dart';
import '../../../core/di/injection.dart';
import '../../../data/models/book_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/repositories/book_repository.dart';
import '../../../data/repositories/category_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final _bookRepo = sl<BookRepository>();
  final _categoryRepo = sl<CategoryRepository>();

  List<BookModel> featuredBooks = [];
  List<BookModel> newArrivalBooks = [];
  List<CategoryModel> categories = [];

  bool isLoadingFeatured = false;
  bool isLoadingNewArrivals = false;
  bool isLoadingCategories = false;

  Future<void> loadFeaturedBooks() async {
    isLoadingFeatured = true;
    notifyListeners();
    try {
      final books = await _bookRepo.getBooks(featured: true);
      featuredBooks = books;
    } catch (e) {
      debugPrint('Error loading featured books: $e');
    } finally {
      isLoadingFeatured = false;
      notifyListeners();
    }
  }

  Future<void> loadNewArrivals() async {
    isLoadingNewArrivals = true;
    notifyListeners();
    try {
      final booksMap = await _bookRepo.getBooksPaginated(
        sort: 'newest',
      );
      final List<BookModel> booksList = List<BookModel>.from(booksMap['books'] ?? []);
      newArrivalBooks = booksList;
    } catch (e) {
      debugPrint('Error loading new arrivals: $e');
    } finally {
      isLoadingNewArrivals = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    isLoadingCategories = true;
    notifyListeners();
    try {
      final cats = await _categoryRepo.getCategories();
      categories = cats;
    } catch (e) {
      debugPrint('Error loading categories: $e');
    } finally {
      isLoadingCategories = false;
      notifyListeners();
    }
  }

  Future<void> loadAll() async {
    await Future.wait([
      loadFeaturedBooks(),
      loadNewArrivals(),
      loadCategories(),
    ]);
  }
}
