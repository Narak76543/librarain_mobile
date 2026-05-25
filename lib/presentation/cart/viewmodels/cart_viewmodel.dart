import 'package:flutter/material.dart';

import '../../../data/models/book_model.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../data/repositories/order_repository.dart';

class CartViewModel extends ChangeNotifier {
  CartViewModel({CartRepository? cartRepository})
      : _cartRepository = cartRepository ?? CartRepository();

  final CartRepository _cartRepository;

  List<CartItemModel> _items = [];
  bool _isLoading = false;
  String? _error;

  List<CartItemModel> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get subtotal {
    double total = 0.0;
    for (final item in _items) {
      final priceStr = item.book.price.replaceAll('\$', '').trim();
      final price = double.tryParse(priceStr) ?? 0.0;
      total += price * item.quantity;
    }
    return total;
  }

  Future<void> fetchCart() async {
    _setLoading(true);
    try {
      _items = await _cartRepository.getCart();
      _error = null;
    } on CartException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addToCart(BookModel book) async {
    _setLoading(true);
    try {
      await _cartRepository.addToCart(book.id, 1);
      await fetchCart(); // Refresh cart to get the new state and item IDs
    } on CartException catch (e) {
      _error = e.message;
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> removeFromCart(String itemId) async {
    _setLoading(true);
    try {
      await _cartRepository.removeFromCart(itemId);
      await fetchCart();
    } on CartException catch (e) {
      _error = e.message;
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> increaseQuantity(String itemId) async {
    final item = _items.firstWhere((i) => i.id == itemId);
    _setLoading(true);
    try {
      await _cartRepository.updateCartItem(itemId, item.quantity + 1);
      await fetchCart();
    } on CartException catch (e) {
      _error = e.message;
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> decreaseQuantity(String itemId) async {
    final item = _items.firstWhere((i) => i.id == itemId);
    if (item.quantity > 1) {
      _setLoading(true);
      try {
        await _cartRepository.updateCartItem(itemId, item.quantity - 1);
        await fetchCart();
      } on CartException catch (e) {
        _error = e.message;
        _setLoading(false);
        rethrow;
      }
    } else {
      await removeFromCart(itemId);
    }
  }

  Future<void> clearCart() async {
    _setLoading(true);
    try {
      await _cartRepository.clearCart();
      _items.clear();
      _error = null;
    } on CartException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> placeOrder() async {
    _setLoading(true);
    try {
      // The order repository requires its own instance or we can just instantiate it here
      // To keep it simple without adding a constructor arg, we instantiate it here:
      final orderRepo = OrderRepository();
      final success = await orderRepo.placeOrder();
      if (success) {
        _items.clear();
        _error = null;
      }
      return success;
    } on OrderException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
