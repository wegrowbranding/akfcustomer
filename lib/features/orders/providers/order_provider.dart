import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_service.dart';
import '../models/order_models.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();
  List<Order> _orders = [];
  Order? _selectedOrderDetails;
  Order? _lastOrder;

  bool _isLoading = false;
  String? _error;

  final ApiService _apiService;

  List<Order> get orders => _orders;
  Order? get selectedOrderDetails => _selectedOrderDetails;
  Order? get lastOrder => _lastOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchOrders(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get(
        ApiConstants.orders,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final orderList = data['data']['data'] as List? ?? [];
        _orders = orderList.map((o) => Order.fromJson(o)).toList();
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

  Future<void> fetchOrderDetails(String token, int orderId) async {
    _isLoading = true;
    _error = null;
    _selectedOrderDetails = null;
    notifyListeners();

    try {
      final response = await _apiService.get(
        '${ApiConstants.orders}/$orderId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        _selectedOrderDetails = Order.fromJson(data['data']);
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

  // This should be called by ShoppingProvider after successful order placement
  void setLastOrder(Order order) {
    _lastOrder = order;
    notifyListeners();
  }

  Future<bool> cancelOrder(String token, int orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        ApiConstants.cancelOrder(orderId),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        await fetchOrderDetails(token, orderId); // Refresh details
        await fetchOrders(token); // Update the list as well
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
