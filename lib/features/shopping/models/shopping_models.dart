import '../../home/models/home_models.dart';

class CartItem {
  CartItem({
    required this.id,
    required this.cartId,
    required this.productId,
    required this.quantity,
    required this.product,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: json['id'],
    cartId: json['cart_id'],
    productId: json['product_id'],
    quantity: json['quantity'],
    product: Product.fromJson(json['product']),
  );
  final int id;
  final int cartId;
  final int productId;
  int quantity;
  final Product product;
}

class Cart {
  Cart({required this.cartId, required this.items, required this.totalAmount});

  factory Cart.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List? ?? [];
    return Cart(
      cartId: json['cart_id'],
      items: itemsList.map((i) => CartItem.fromJson(i)).toList(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
    );
  }
  final int cartId;
  final List<CartItem> items;
  final double totalAmount;
}

class Address {
  Address({
    required this.id,
    required this.name,
    required this.phone,
    required this.addressLine1,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
    required this.isDefault,
    this.addressLine2,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    id: json['id'],
    name: json['name'] ?? '',
    phone: json['phone'] ?? '',
    addressLine1: json['address_line1'] ?? '',
    addressLine2: json['address_line2'],
    city: json['city'] ?? '',
    state: json['state'] ?? '',
    pincode: json['pincode'] ?? '',
    country: json['country'] ?? '',
    isDefault: json['is_default'] == 1,
  );
  final int id;
  final String name;
  final String phone;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String pincode;
  final String country;
  final bool isDefault;

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'address_line1': addressLine1,
    'address_line2': addressLine2 ?? '',
    'city': city,
    'state': state,
    'pincode': pincode,
    'country': country,
    'is_default': isDefault,
  };
}

class CouponResponse {
  CouponResponse({
    required this.couponCode,
    required this.discountAmount,
    required this.finalAmount,
  });

  factory CouponResponse.fromJson(Map<String, dynamic> json) => CouponResponse(
    couponCode: json['coupon_code'],
    discountAmount: (json['discount_amount'] ?? 0).toDouble(),
    finalAmount: (json['final_amount'] ?? 0).toDouble(),
  );
  final String couponCode;
  final double discountAmount;
  final double finalAmount;
}

class WishlistItem {
  WishlistItem({
    required this.id,
    required this.wishlistId,
    required this.productId,
    required this.product,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) => WishlistItem(
    id: json['id'],
    wishlistId: json['wishlist_id'],
    productId: json['product_id'],
    product: Product.fromJson(json['product']),
  );
  final int id;
  final int wishlistId;
  final int productId;
  final Product product;
}

class Wishlist {
  Wishlist({required this.wishlistId, required this.items});

  factory Wishlist.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List? ?? [];
    return Wishlist(
      wishlistId: json['wishlist_id'],
      items: itemsList.map((i) => WishlistItem.fromJson(i)).toList(),
    );
  }
  final int wishlistId;
  final List<WishlistItem> items;
}
