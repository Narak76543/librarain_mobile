import 'package:flutter/material.dart';

import '../../../data/models/book_model.dart';
import '../../../data/repositories/book_repository.dart';
import '../../../core/di/injection.dart';

class BookDetailViewModel extends ChangeNotifier {
  BookDetailViewModel({BookRepository? bookRepository})
      : _bookRepository = bookRepository ?? sl<BookRepository>();

  final BookRepository _bookRepository;

  BookModel? _book;
  bool _isLoading = false;
  String? _error;

  BookModel? get book => _book;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchBookDetails(String bookId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _book = await _bookRepository.getBookById(bookId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _book = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
