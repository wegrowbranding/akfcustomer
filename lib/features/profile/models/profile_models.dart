class UserProfile {
  UserProfile({
    required this.id,
    required this.customerCode,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.status,
    this.profileImage,
    this.dateOfBirth,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'],
    customerCode: json['customer_code'] ?? '',
    fullName: json['full_name'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    profileImage: json['profile_image'],
    gender: json['gender'] ?? '',
    dateOfBirth: json['date_of_birth'],
    status: json['status'] ?? '',
  );
  final int id;
  final String customerCode;
  final String fullName;
  final String email;
  final String phone;
  final String? profileImage;
  final String gender;
  final String? dateOfBirth;
  final String status;
}

class Review {
  Review({
    required this.id,
    required this.productId,
    required this.customerId,
    required this.rating,
    required this.review,
    required this.createdAt,
    this.customer,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['id'],
    productId: json['product_id'],
    customerId: json['customer_id'],
    rating: json['rating'],
    review: json['review'] ?? '',
    createdAt: json['created_at'] ?? '',
    customer: json['customer'] != null
        ? ReviewCustomer.fromJson(json['customer'])
        : null,
  );
  final int id;
  final int productId;
  final int customerId;
  final int rating;
  final String review;
  final String createdAt;
  final ReviewCustomer? customer;
}

class ReviewCustomer {
  ReviewCustomer({required this.id, required this.fullName, this.profileImage});

  factory ReviewCustomer.fromJson(Map<String, dynamic> json) => ReviewCustomer(
    id: json['id'],
    fullName: json['full_name'] ?? '',
    profileImage: json['profile_image'],
  );
  final int id;
  final String fullName;
  final String? profileImage;
}
