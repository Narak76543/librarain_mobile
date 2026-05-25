class WishlistItem {
  final String id;
  final String bookId;
  final String? bookTitle;
  final String? bookAuthor;
  final String? bookCover;
  final double? bookPrice;
  final double? bookRating;
  final String? categoryName;
  final String createdAt;

  const WishlistItem({
    required this.id,
    required this.bookId,
    this.bookTitle,
    this.bookAuthor,
    this.bookCover,
    this.bookPrice,
    this.bookRating,
    this.categoryName,
    required this.createdAt,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) => WishlistItem(
        id: json['id'] as String,
        bookId: json['book_id'] as String,
        bookTitle: json['book_title'] as String?,
        bookAuthor: json['book_author'] as String?,
        bookCover: json['book_cover'] as String?,
        bookPrice: json['book_price'] != null
            ? double.tryParse(json['book_price'].toString())
            : null,
        bookRating: json['book_rating'] != null
            ? double.tryParse(json['book_rating'].toString())
            : null,
        categoryName: json['category_name'] as String?,
        createdAt: json['created_at'] as String,
      );
}
