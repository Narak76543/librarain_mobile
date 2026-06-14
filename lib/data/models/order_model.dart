class OrderItemModel {
  final String  id;
  final String? bookId;
  final String? bookTitle;
  final String? bookAuthor;
  final String? bookCover;
  final String? categoryName;
  final int     quantity;
  final double  priceAtPurchase;
  final double  subtotal;

  OrderItemModel({
    required this.id,
    this.bookId,
    this.bookTitle,
    this.bookAuthor,
    this.bookCover,
    this.categoryName,
    required this.quantity,
    required this.priceAtPurchase,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
    id:              json['id']                as String,
    bookId:          json['book_id']           as String?,
    bookTitle:       json['book_title']        as String?,
    bookAuthor:      json['book_author']       as String?,
    bookCover:       json['book_cover']        as String?,
    categoryName:    json['category_name']     as String?,
    quantity:        json['quantity']          as int,
    priceAtPurchase: double.parse(json['price_at_purchase'].toString()),
    subtotal:        double.parse(json['subtotal'].toString()),
  );
}

class OrderModel {
  final String           id;
  final String           shortId;
  final double           total;
  final String           status;
  final String           createdAt;
  final List<OrderItemModel> orderItems;
  final String           deliveryWay;
  final String?          deliveryPartner;
  final String?          deliveryAddress;
  final String           paymentMethod;

  OrderModel({
    required this.id,
    required this.shortId,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.orderItems,
    required this.deliveryWay,
    this.deliveryPartner,
    this.deliveryAddress,
    required this.paymentMethod,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id:              json['id']         as String,
    shortId:         (json['id'] as String).substring(0, 8).toUpperCase(),
    total:           double.parse(json['total'].toString()),
    status:          json['status']     as String,
    createdAt:       json['created_at'] as String,
    orderItems:      (json['order_items'] as List? ?? [])
        .map((i) => OrderItemModel.fromJson(i))
        .toList(),
    deliveryWay:     json['delivery_way'] as String? ?? 'Pick Up',
    deliveryPartner: json['delivery_partner'] as String?,
    deliveryAddress: json['delivery_address'] as String?,
    paymentMethod:   json['payment_method'] as String? ?? 'COD',
  );
}

class OrderSummaryModel {
  final String           orderId;
  final String           shortId;
  final String           status;
  final String           createdAt;
  final String           customerName;
  final String           customerEmail;
  final String           customerPhone;
  final List<OrderItemModel> items;
  final int              itemCount;
  final double           subtotal;
  final double           discount;
  final double           delivery;
  final double           total;
  final String           deliveryWay;
  final String?          deliveryPartner;
  final String?          deliveryAddress;
  final String           paymentMethod;

  OrderSummaryModel({
    required this.orderId,
    required this.shortId,
    required this.status,
    required this.createdAt,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.items,
    required this.itemCount,
    required this.subtotal,
    required this.discount,
    required this.delivery,
    required this.total,
    required this.deliveryWay,
    this.deliveryPartner,
    this.deliveryAddress,
    required this.paymentMethod,
  });

  factory OrderSummaryModel.fromJson(Map<String, dynamic> json) {
    final order    = json['order']    as Map<String, dynamic>;
    final customer = json['customer'] as Map<String, dynamic>;
    final summary  = json['summary']  as Map<String, dynamic>;
    return OrderSummaryModel(
      orderId:         order['id']        as String,
      shortId:         order['short_id']  as String,
      status:          order['status']    as String,
      createdAt:       order['created_at']as String,
      customerName:    customer['full_name'] as String,
      customerEmail:   customer['email']     as String,
      customerPhone:   customer['phone']  as String? ?? '',
      items: (json['items'] as List)
          .map((i) => OrderItemModel.fromJson(i))
          .toList(),
      itemCount:       json['item_count'] as int,
      subtotal:        double.parse(summary['subtotal'].toString()),
      discount:        double.parse(summary['discount'].toString()),
      delivery:        double.parse(summary['delivery'].toString()),
      total:           double.parse(summary['total'].toString()),
      deliveryWay:     order['delivery_way'] as String? ?? 'Pick Up',
      deliveryPartner: order['delivery_partner'] as String?,
      deliveryAddress: order['delivery_address'] as String?,
      paymentMethod:   order['payment_method'] as String? ?? 'COD',
    );
  }
}
