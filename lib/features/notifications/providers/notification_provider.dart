import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_service.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider({required ApiService apiService})
    : _apiService = apiService;
  final ApiService _apiService;
  List<NotificationItem> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  List<NotificationItem> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMore => _hasMore;

  Future<void> fetchNotifications(String token, {bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _notifications = [];
      _hasMore = true;
      _isLoading = true;
    } else {
      if (!_hasMore || _isLoadingMore) {
        return;
      }
      _isLoadingMore = true;
    }
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get(
        ApiConstants.notifications,
        queryParameters: {'page': _currentPage},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final Map<String, dynamic> responseData =
          response.data as Map<String, dynamic>;
      final notificationResponse = NotificationResponse.fromJson(responseData);

      if (notificationResponse.success && notificationResponse.data != null) {
        final List<NotificationItem> newNotifications =
            notificationResponse.data!.data;
        if (refresh) {
          _notifications = newNotifications;
        } else {
          _notifications.addAll(newNotifications);
        }

        _hasMore = _notifications.length < notificationResponse.data!.total;
        if (_hasMore) {
          _currentPage++;
        }
      } else {
        _error = notificationResponse.message;
      }
    } catch (e) {
      _error = 'Failed to load notifications: ${e.toString()}';
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> fetchUnreadCount(String token) async {
    try {
      final response = await _apiService.get(
        ApiConstants.unreadCount,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final Map<String, dynamic> responseData =
          response.data as Map<String, dynamic>;
      final countResponse = UnreadCountResponse.fromJson(responseData);

      if (countResponse.success) {
        _unreadCount = countResponse.unreadCount;
        notifyListeners();
      }
    } catch (e) {
      // Silently fail unread count
    }
  }

  Future<bool> markAsRead(String token, int notificationId) async {
    try {
      final response = await _apiService.post(
        ApiConstants.markRead,
        data: {'notification_id': notificationId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final Map<String, dynamic> responseData =
          response.data as Map<String, dynamic>;
      if (responseData['success'] == true) {
        // Update local state
        final index = _notifications.indexWhere(
          (notif) => notif.id == notificationId,
        );
        if (index != -1 && !_notifications[index].isRead) {
          _notifications[index] = NotificationItem(
            id: _notifications[index].id,
            customerId: _notifications[index].customerId,
            title: _notifications[index].title,
            message: _notifications[index].message,
            type: _notifications[index].type,
            referenceId: _notifications[index].referenceId,
            imageUrl: _notifications[index].imageUrl,
            isRead: true,
            readAt: DateTime.now(),
            createdAt: _notifications[index].createdAt,
            updatedAt: _notifications[index].updatedAt,
          );
          if (_unreadCount > 0) {
            _unreadCount--;
          }
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }
}
