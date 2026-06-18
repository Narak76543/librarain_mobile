import 'package:flutter/foundation.dart';
import '../../../data/models/wishlist_model.dart';
import '../../../data/repositories/wishlist_repository.dart';
import '../../../core/di/injection.dart';

class WishlistViewModel extends ChangeNotifier {
  final _repo = sl<WishlistRepository>();

  List<WishlistItem> items = [];
  Set<String> wishlistedIds = {};
  bool isLoading = false;
  String errorMessage = '';

  Future<void> loadWishlist() async {
    isLoading = true;
    notifyListeners();
    try {
      items = await _repo.getWishlist();
      wishlistedIds = items.map((i) => i.bookId).toSet();
      errorMessage = '';
    } catch (e) {
      errorMessage = 'Failed to load wishlist';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggle(String bookId) async {
    final wasWishlisted = wishlistedIds.contains(bookId);

    // Optimistic UI update
    if (wasWishlisted) {
      wishlistedIds.remove(bookId);
      items.removeWhere((i) => i.bookId == bookId);
    } else {
      wishlistedIds.add(bookId);
    }
    notifyListeners();

    try {
      await _repo.toggleWishlist(bookId);
      // Wait, should we reload the whole list to get full item details?
      // Yes, if we added it, it's safer to reload in background to get the new WishlistItem object
      if (!wasWishlisted) {
        _repo.getWishlist().then((newItems) {
          items = newItems;
          notifyListeners();
        });
      }
    } catch (e) {
      // Revert on error
      if (wasWishlisted) {
        wishlistedIds.add(bookId);
      } else {
        wishlistedIds.remove(bookId);
        items.removeWhere((i) => i.bookId == bookId);
      }
      notifyListeners();
      throw Exception('Failed to update wishlist');
    }
  }

  bool isWishlisted(String bookId) => wishlistedIds.contains(bookId);

  int get totalCount => items.length;
}
