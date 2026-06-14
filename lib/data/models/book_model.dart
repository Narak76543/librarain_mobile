import 'category_model.dart';
import 'review_model.dart';

class BookModel {
  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.price,
    required this.coverUrl,
    required this.stock,
    required this.isbn,
    required this.language,
    required this.pages,
    required this.publisher,
    required this.publishedDate,
    required this.featured,
    required this.ratingAverage,
    required this.ratingCount,
    required this.isActive,
    this.category,
    this.fileSize,
    this.purchases,
    this.reviews,
  });

  final String id;
  final String title;
  final String author;
  final String description;
  final String price;
  final String coverUrl;
  final int stock;
  final String isbn;
  final String language;
  final int pages;
  final String publisher;
  final String publishedDate;
  final bool featured;
  final String ratingAverage;
  final int ratingCount;
  final bool isActive;
  final CategoryModel? category;
  final String? fileSize;
  final String? purchases;
  final List<ReviewModel>? reviews;

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: json['price']?.toString() ?? '0.00',
      coverUrl: json['cover_url']?.toString() ?? '',
      stock: json['stock'] as int? ?? 0,
      isbn: json['isbn']?.toString() ?? '',
      language: json['language']?.toString() ?? '',
      pages: json['pages'] as int? ?? 0,
      publisher: json['publisher']?.toString() ?? '',
      publishedDate: json['published_date']?.toString() ?? '',
      featured: json['featured'] == true,
      ratingAverage: json['rating_average']?.toString() ?? '0.00',
      ratingCount: json['rating_count'] as int? ?? 0,
      isActive: json['is_active'] != false,
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      fileSize: json['file_size']?.toString(),
      purchases: json['purchases']?.toString(),
      reviews: json['reviews'] != null
          ? (json['reviews'] as List).map((r) => ReviewModel.fromJson(r as Map<String, dynamic>)).toList()
          : null,
    );
  }
}
