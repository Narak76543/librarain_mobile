import 'book_model.dart';

class CartItemModel {
  CartItemModel({
    required this.book,
    this.quantity = 1,
  });

  final BookModel book;
  int quantity;
}
