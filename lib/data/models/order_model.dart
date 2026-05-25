class OrderItemModel {
  OrderItemModel({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.bookCover,
    required this.quantity,
    required this.priceAtPurchase,
    required this.subtotal,
  });

  final String id;
  final String? bookId;
  final String bookTitle;
  final String? bookCover;
  final int quantity;
  final String priceAtPurchase;
  final String subtotal;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id']?.toString() ?? '',
      bookId: json['book_id']?.toString(),
      bookTitle: json['book_title']?.toString() ?? 'Deleted book',
      bookCover: json['book_cover']?.toString(),
      quantity: json['quantity'] as int? ?? 1,
      priceAtPurchase: json['price_at_purchase']?.toString() ?? '0.00',
      subtotal: json['subtotal']?.toString() ?? '0.00',
    );
  }
}

class OrderModel {
  OrderModel({
    required this.id,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.orderItems,
  });

  final String id;
  final String total;
  final String status;
  final String createdAt;
  final List<OrderItemModel> orderItems;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsList = json['order_items'] as List<dynamic>? ?? [];
    return OrderModel(
      id: json['id']?.toString() ?? '',
      total: json['total']?.toString() ?? '0.00',
      status: json['status']?.toString() ?? 'unknown',
      createdAt: json['created_at']?.toString() ?? '',
      orderItems: itemsList
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
