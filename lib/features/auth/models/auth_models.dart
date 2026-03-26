import 'dart:convert';

class User {
  User({
    required this.id,
    required this.customerCode,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.status,
    required this.userType,
    this.profileImage,
    this.gender,
    this.dateOfBirth,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    customerCode: json['customer_code'] ?? '',
    fullName: json['full_name'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    profileImage: json['profile_image'],
    gender: json['gender'],
    dateOfBirth: json['date_of_birth'],
    status: json['status'] ?? 'active',
    userType: json['user_type'] ?? 'customer',
  );

  factory User.fromJsonString(String jsonStr) =>
      User.fromJson(jsonDecode(jsonStr));
  final int id;
  final String customerCode;
  final String fullName;
  final String email;
  final String phone;
  final String? profileImage;
  final String? gender;
  final String? dateOfBirth;
  final String status;
  final String userType;

  Map<String, dynamic> toJson() => {
    'id': id,
    'customer_code': customerCode,
    'full_name': fullName,
    'email': email,
    'phone': phone,
    'profile_image': profileImage,
    'gender': gender,
    'date_of_birth': dateOfBirth,
    'status': status,
    'user_type': userType,
  };

  String toJsonString() => jsonEncode(toJson());
}

class AuthResponse {
  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
    this.errors,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    success: json['success'] ?? false,
    token: json['data'] != null ? json['data']['token'] : null,
    user: (json['data'] != null && json['data']['user'] != null)
        ? User.fromJson(json['data']['user'])
        : null,
    message: json['message'] ?? '',
    errors: json['errors'],
  );
  final bool success;
  final String? token;
  final User? user;
  final String message;
  final Map<String, dynamic>? errors;
}
