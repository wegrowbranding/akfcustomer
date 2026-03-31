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
    this.history = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List?) ?? [];
    final historyList = (json['history'] as List?) ?? [];

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
      history: historyList.map((i) => OrderHistory.fromJson(i)).toList(),
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
  final List<OrderHistory> history;

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

class OrderHistory {
  OrderHistory({
    required this.id,
    required this.assignmentId,
    required this.status,
    required this.remarks,
    required this.createdAt,
    this.assignment,
  });

  factory OrderHistory.fromJson(Map<String, dynamic> json) => OrderHistory(
        id: json['id'] ?? 0,
        assignmentId: json['assignment_id'] ?? 0,
        status: json['status'] ?? '',
        remarks: json['remarks'] ?? '',
        createdAt: json['created_at'] ?? '',
        assignment: json['assignment'] != null
            ? Assignment.fromJson(json['assignment'])
            : null,
      );
  final int id;
  final int assignmentId;
  final String status;
  final String remarks;
  final String createdAt;
  final Assignment? assignment;
}

class Assignment {
  Assignment({
    required this.id,
    required this.orderId,
    required this.deliveryStaffId,
    required this.status,
    this.deliveryStaff,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) => Assignment(
        id: json['id'] ?? 0,
        orderId: json['order_id'] ?? 0,
        deliveryStaffId: json['delivery_staff_id'] ?? 0,
        status: json['status'] ?? '',
        deliveryStaff: json['delivery_staff'] != null
            ? DeliveryStaff.fromJson(json['delivery_staff'])
            : null,
      );
  final int id;
  final int orderId;
  final int deliveryStaffId;
  final String status;
  final DeliveryStaff? deliveryStaff;
}

class DeliveryStaff {
  DeliveryStaff({
    required this.id,
    required this.vehicleType,
    required this.vehicleNumber,
    this.staff,
  });

  factory DeliveryStaff.fromJson(Map<String, dynamic> json) => DeliveryStaff(
        id: json['id'] ?? 0,
        vehicleType: json['vehicle_type'] ?? '',
        vehicleNumber: json['vehicle_number'] ?? '',
        staff: json['staff'] != null ? Staff.fromJson(json['staff']) : null,
      );
  final int id;
  final String vehicleType;
  final String vehicleNumber;
  final Staff? staff;
}

class Staff {
  Staff({
    required this.id,
    required this.fullName,
    required this.phone,
  });

  factory Staff.fromJson(Map<String, dynamic> json) => Staff(
        id: json['id'] ?? 0,
        fullName: json['full_name'] ?? '',
        phone: json['phone'] ?? '',
      );
  final int id;
  final String fullName;
  final String phone;
}
