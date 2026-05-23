import 'package:flutter/material.dart';

import '../../../data/models/book_model.dart';
import '../../../data/models/cart_item_model.dart';

class CartViewModel extends ChangeNotifier {
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => List.unmodifiable(_items);

  double get subtotal {
    double total = 0.0;
    for (final item in _items) {
      final priceStr = item.book.price.replaceAll('\$', '').trim();
      final price = double.tryParse(priceStr) ?? 0.0;
      total += price * item.quantity;
    }
    return total;
  }

  void addToCart(BookModel book) {
    final existingIndex = _items.indexWhere((item) => item.book.id == book.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += 1;
    } else {
      _items.add(CartItemModel(book: book));
    }
    notifyListeners();
  }

  void removeFromCart(String bookId) {
    _items.removeWhere((item) => item.book.id == bookId);
    notifyListeners();
  }

  void increaseQuantity(String bookId) {
    final index = _items.indexWhere((item) => item.book.id == bookId);
    if (index >= 0) {
      _items[index].quantity += 1;
      notifyListeners();
    }
  }

  void decreaseQuantity(String bookId) {
    final index = _items.indexWhere((item) => item.book.id == bookId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity -= 1;
        notifyListeners();
      } else {
        removeFromCart(bookId);
      }
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
