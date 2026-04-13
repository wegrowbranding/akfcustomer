import 'package:intl/intl.dart';

class NotificationResponse {
  NotificationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      NotificationResponse(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: json['data'] != null && json['data'] is Map<String, dynamic>
            ? NotificationPageData.fromJson(json['data'])
            : null,
      );
  final bool success;
  final String message;
  final NotificationPageData? data;
}

class NotificationPageData {
  NotificationPageData({
    required this.total,
    required this.limit,
    required this.page,
    required this.data,
  });

  factory NotificationPageData.fromJson(Map<String, dynamic> json) =>
      NotificationPageData(
        total: json['total'] ?? 0,
        limit: json['limit'] ?? 20,
        page: json['page'] ?? 1,
        data: (json['data'] as List? ?? [])
            .map((e) => NotificationItem.fromJson(e))
            .toList(),
      );
  final int total;
  final int limit;
  final int page;
  final List<NotificationItem> data;
}

class NotificationItem {
  NotificationItem({
    required this.id,
    required this.customerId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
    this.referenceId,
    this.imageUrl,
    this.readAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        id: json['id'] ?? 0,
        customerId: json['customer_id'] ?? 0,
        title: json['title'] ?? '',
        message: json['message'] ?? '',
        type: json['type'] ?? '',
        referenceId: json['reference_id'],
        imageUrl: json['image_url'],
        isRead: json['is_read'] == 1,
        readAt: json['read_at'] != null
            ? DateTime.tryParse(json['read_at'].toString())
            : null,
        createdAt:
            DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
        updatedAt:
            DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now(),
      );
  final int id;
  final int customerId;
  final String title;
  final String message;
  final String type;
  final int? referenceId;
  final String? imageUrl;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get formattedDate =>
      DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);
}

class UnreadCountResponse {
  UnreadCountResponse({
    required this.success,
    required this.message,
    required this.unreadCount,
  });

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) =>
      UnreadCountResponse(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        unreadCount: json['data'] != null
            ? json['data']['unread_count'] ?? 0
            : 0,
      );
  final bool success;
  final String message;
  final int unreadCount;
}
