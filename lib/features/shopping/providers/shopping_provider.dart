import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_service.dart';
import '../../home/models/home_models.dart';
import '../models/shopping_models.dart';

class ShoppingProvider extends ChangeNotifier {
  ShoppingProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();
  Cart? _cart;
  List<Address> _addresses = [];
  Wishlist? _wishlist;
  List<Product> _recentlyViewed = [];
  CouponResponse? _appliedCoupon;

  bool _isLoading = false;
  String? _error;

  final ApiService _apiService;

  Cart? get cart => _cart;
  List<Address> get addresses => _addresses;
  Wishlist? get wishlist => _wishlist;
  List<Product> get recentlyViewed => _recentlyViewed;
  CouponResponse? get appliedCoupon => _appliedCoupon;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool _isSingleProductInWishlist = false;
  bool get isSingleProductInWishlist => _isSingleProductInWishlist;

  bool isWishlisted(int productId) =>
      _wishlist?.items.any((item) => item.productId == productId) ?? false;

  Future<void> fetchWishlist(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get(
        ApiConstants.wishlist,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        _wishlist = Wishlist.fromJson(data['data']);
      } else {
        _error = data['message'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleWishlist(
    String token,
    int productId,
    String action,
  ) async {
    try {
      final response = await _apiService.post(
        ApiConstants.updateWishlist,
        data: {'product_id': productId, 'action': action},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        await fetchWishlist(token);
        return true;
      } else {
        _error = data['message'];
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<void> checkProductInWishlist(String token, int productId) async {
    notifyListeners();

    try {
      final response = await _apiService.get(
        '${ApiConstants.checkProductInWishlist}?product_id=$productId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        _isSingleProductInWishlist = data['data']['is_in_wishlist'] ?? false;
      }
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchRecentlyViewed(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get(
        ApiConstants.recentlyViewed,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final rvList = data['data']['data'] as List? ?? [];
        _recentlyViewed = rvList
            .map((rv) => Product.fromJson(rv['product']))
            .toList();
      } else {
        _error = data['message'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsViewed(String token, int productId) async {
    try {
      await _apiService.post(
        '${ApiConstants.markAsViewed}/$productId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      // Silent error
    }
  }

  Future<void> fetchCart(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get(
        ApiConstants.cart,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        _cart = Cart.fromJson(data['data']);
      } else {
        _error = data['message'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateCart(String token, int productId, int quantity) async {
    try {
      final response = await _apiService.post(
        ApiConstants.cartUpdate,
        data: {'product_id': productId, 'quantity': quantity},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        _appliedCoupon =
            null; // Clear coupon on cart update to avoid stale totals
        await fetchCart(token);
        return true;
      } else {
        _error = data['message'];
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchAddresses(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get(
        ApiConstants.addresses,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final addrList = data['data'] as List? ?? [];
        _addresses = addrList.map((a) => Address.fromJson(a)).toList();
      } else {
        _error = data['message'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAddress(String token, Address address) async {
    try {
      final response = await _apiService.post(
        ApiConstants.addAddress,
        data: address.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        await fetchAddresses(token);
        return true;
      } else {
        _error = data['message'];
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> editAddress(String token, int addressId, Address address) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.put(
        '/addresses/$addressId',
        data: address.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        await fetchAddresses(token);
        return true;
      } else {
        _error = data['message'];
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAddress(String token, int addressId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.delete(
        '/addresses/$addressId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        await fetchAddresses(token);
        return true;
      } else {
        _error = data['message'];
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> applyCoupon(
    String token,
    String couponCode,
    double amount,
  ) async {
    try {
      final response = await _apiService.post(
        ApiConstants.applyCoupon,
        data: {'coupon_code': couponCode, 'amount': amount},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        _appliedCoupon = CouponResponse.fromJson(data['data']);
        return true;
      } else {
        _error = data['message'];
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> placeOrder(
    String token,
    int addressId,
    String paymentMethod,
    String? couponCode,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        ApiConstants.placeOrder,
        data: {
          'address_id': addressId,
          'payment_method': paymentMethod,
          'coupon_code': couponCode,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        _cart = null;
        _appliedCoupon = null;
        return data['data'];
      } else {
        _error = data['message'];
        return null;
      }
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetError() {
    _error = null;
    notifyListeners();
  }
}
