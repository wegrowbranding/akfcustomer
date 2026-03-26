import '../../home/models/home_models.dart';

class OrderItem {
  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    required this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: json['id'],
    orderId: json['order_id'],
    productId: json['product_id'],
    quantity: json['quantity'],
    price: json['price']?.toString() ?? '0.00',
    totalPrice: json['total_price']?.toString() ?? '0.00',
    product: Product.fromJson(json['product']),
  );
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final String price;
  final String totalPrice;
  final Product product;
}

class Order {
  Order({
    required this.id,
    required this.orderNumber,
    required this.totalAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.paymentStatus,
    required this.orderStatus,
    required this.paymentMethod,
    required this.addressId,
    required this.placedAt,
    this.items = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List?) ?? [];

    return Order(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      totalAmount: _toDouble(json['total_amount']),
      discountAmount: _toDouble(json['discount_amount']),
      finalAmount: _toDouble(json['final_amount']),
      paymentStatus: json['payment_status'] ?? '',
      orderStatus: json['order_status'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      addressId: json['address_id'] ?? 0,
      placedAt: json['placed_at'] ?? '',
      items: itemsList.map((i) => OrderItem.fromJson(i)).toList(),
    );
  }
  final int id;
  final String orderNumber;
  final double totalAmount;
  final double discountAmount;
  final double finalAmount;
  final String paymentStatus;
  final String orderStatus;
  final String paymentMethod;
  final int addressId;
  final String placedAt;
  final List<OrderItem> items;

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0;
  }
}
