import 'book_model.dart';

class CartItemModel {
  CartItemModel({
    required this.id,
    required this.book,
    this.quantity = 1,
  });

  final String id;
  final BookModel book;
  int quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id']?.toString() ?? '',
      quantity: json['quantity'] as int? ?? 1,
      book: BookModel(
        id: json['book_id']?.toString() ?? '',
        title: json['book_title']?.toString() ?? 'Unknown Book',
        author: '',
        description: '',
        price: json['book_price']?.toString() ?? '0.00',
        coverUrl: json['book_cover']?.toString() ?? '',
        stock: 0,
        isbn: '',
        language: '',
        pages: 0,
        publisher: '',
        publishedDate: '',
        featured: false,
        ratingAverage: '0.00',
        ratingCount: 0,
        isActive: true,
      ),
    );
  }
}
