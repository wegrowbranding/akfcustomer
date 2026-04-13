import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/notification_model.dart';
import '../providers/notification_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadNotifications();
    }
  }

  Future<void> _loadNotifications({bool refresh = false}) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    if (authProvider.token != null) {
      await notificationProvider.fetchNotifications(
        authProvider.token!,
        refresh: refresh,
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.backgroundColor,
    appBar: AppBar(
      title: const Text(
        'Notifications',
        style: TextStyle(
          color: Color(0xFF1A1A1A),
          fontWeight: FontWeight.w300,
          fontFamily: 'Serif',
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          size: 20,
          color: Colors.black87,
        ),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryColor),
          onPressed: () => _loadNotifications(refresh: true),
        ),
      ],
    ),
    body: Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.notifications.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          );
        }

        if (provider.error != null && provider.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(provider.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _loadNotifications(refresh: true),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  size: 80,
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No notifications yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'We\'ll notify you when something important happens.',
                  style: TextStyle(color: Colors.black38),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _loadNotifications(refresh: true),
          color: AppTheme.primaryColor,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount:
                provider.notifications.length + (provider.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == provider.notifications.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                );
              }

              final notification = provider.notifications[index];
              return _NotificationCard(notification: notification);
            },
          ),
        );
      },
    ),
  );
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});
  final NotificationItem notification;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          if (!notification.isRead && authProvider.token != null) {
            notificationProvider.markAsRead(
              authProvider.token!,
              notification.id,
            );
          }
          // Navigate based on type
          if (notification.type == 'order_placed' &&
              notification.referenceId != null) {
            // context.push('/orders/${notification.referenceId}');
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      (notification.isRead
                              ? Colors.grey
                              : AppTheme.primaryColor)
                          .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconForType(notification.type),
                  color: notification.isRead
                      ? Colors.grey
                      : AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              color: notification.isRead
                                  ? Colors.black54
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: notification.isRead
                            ? Colors.black38
                            : Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.formattedDate,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black26,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'order_placed':
        return Icons.shopping_cart_outlined;
      case 'login_alert':
        return Icons.lock_outline_rounded;
      case 'delivery_update':
        return Icons.local_shipping_outlined;
      default:
        return Icons.notifications_none_rounded;
    }
  }
}
