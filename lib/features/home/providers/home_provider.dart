import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/device_service.dart';
import '../../../core/storage/preference_service.dart';
import '../models/home_models.dart';

class HomeProvider extends ChangeNotifier {
  HomeProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();
  DashboardData? _dashboardData;
  List<Product> _products = [];
  Product? _selectedProduct;
  List<Product> _relatedProducts = [];

  bool _isLoading = false;
  String? _error;

  final ApiService _apiService;

  DashboardData? get dashboardData => _dashboardData;
  List<Product> get products => _products;
  Product? get selectedProduct => _selectedProduct;
  List<Product> get relatedProducts => _relatedProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDashboard(String? token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get(
        ApiConstants.dashboard,
        options: token != null && token.isNotEmpty
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        _dashboardData = DashboardData.fromJson(data['data']);
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

  Future<void> fetchProducts(
    String? token, {
    String search = '',
    int? categoryId,
    String? minPrice,
    String? maxPrice,
    String? sort,
  }) async {
    _products = [];
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final Map<String, dynamic> queryParams = {
        'search': search,
        'max_price': maxPrice ?? '',
        'min_price': minPrice ?? '',
        'sort': sort ?? '', //price_asc,price_desc,newest
      };
      if (categoryId != null) {
        queryParams['category_id'] = categoryId;
      }

      final response = await _apiService.get(
        ApiConstants.products,
        queryParameters: queryParams,
        options: token != null && token.isNotEmpty
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final productList = data['data']['data'] as List? ?? [];
        _products = productList.map((p) => Product.fromJson(p)).toList();
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

  Future<void> fetchProductDetails(String? token, int productId) async {
    _selectedProduct = null;
    _relatedProducts = [];
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get(
        '${ApiConstants.products}/$productId',
        options: token != null && token.isNotEmpty
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        _selectedProduct = Product.fromJson(data['data']['product']);
        final relatedList = data['data']['related_products'] as List? ?? [];
        _relatedProducts = relatedList.map((p) => Product.fromJson(p)).toList();
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

  Future<void> updateLastActive(String token) async {
    try {
      final deviceDetails = await DeviceService.getDeviceData();
      await _apiService.post(
        ApiConstants.deviceLastActive,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {'device_id': deviceDetails['device_id']},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logoutDevice() async {
    try {
      final token = await PreferenceService.getToken();
      final deviceDetails = await DeviceService.getDeviceData();
      await _apiService.post(
        ApiConstants.logoutDevice,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {'device_id': deviceDetails['device_id']},
      );
    } catch (e) {
      rethrow;
    }
  }

  void clearSelectedProduct() {
    _selectedProduct = null;
    _relatedProducts = [];
    _isLoading = true;
    notifyListeners();
  }

  void clearProducts() {
    _products = [];
    _isLoading = true;
    notifyListeners();
  }
}
