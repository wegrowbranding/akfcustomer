import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_service.dart';
import '../models/profile_models.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();
  UserProfile? _profile;
  List<Review> _productReviews = [];
  bool _isLoading = false;
  String? _error;

  final ApiService _apiService;

  UserProfile? get profile => _profile;
  List<Review> get productReviews => _productReviews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfile(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get(
        ApiConstants.profile,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        _profile = UserProfile.fromJson(data['data']);
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

  Future<bool> editProfile(
    String token,
    String name,
    String phone,
    String gender,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.put(
        ApiConstants.profile,
        data: {'full_name': name, 'phone': phone, 'gender': gender},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        _profile = UserProfile.fromJson(data['data']);
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

  Future<void> fetchProductReviews(String token, int productId) async {
    _isLoading = true;
    _error = null;
    _productReviews = [];
    notifyListeners();

    try {
      final response = await _apiService.get(
        '${ApiConstants.productReviews}/$productId/reviews',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final rvList = data['data']['data'] as List? ?? [];
        _productReviews = rvList.map((r) => Review.fromJson(r)).toList();
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

  Future<bool> addReview(
    String token,
    int productId,
    int rating,
    String reviewText,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        '${ApiConstants.reviews}/add',
        data: {'product_id': productId, 'rating': rating, 'review': reviewText},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        await fetchProductReviews(token, productId);
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

  Future<String?> fetchSupportMeta(String token, String key) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get(
        '${ApiConstants.supportMeta}/$key',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return data['data']['meta_value'];
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

  Future<bool> updateProfilePhoto(String token, String base64Image) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.put(
        ApiConstants.updateProfilePhoto,
        data: {'profile_image': base64Image},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        _profile = UserProfile.fromJson(data['data']);
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

  Future<bool> deleteProfilePhoto(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.delete(
        ApiConstants.deleteProfilePhoto,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        _profile = UserProfile.fromJson(data['data']);
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
}
