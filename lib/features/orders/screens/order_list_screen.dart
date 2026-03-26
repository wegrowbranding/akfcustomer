import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/string_constants.dart';
import '../../../core/themes/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/screens/product_list_screen.dart';
import '../providers/order_provider.dart';
import 'order_detail_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final Color primaryColor = AppTheme.primaryColor;
  final Color secondaryColor = AppTheme.secondaryColor;
  final Color backgroundColor = AppTheme.backgroundColor;
  final Color textColor = const Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token != null) {
        Provider.of<OrderProvider>(context, listen: false).fetchOrders(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final orders = orderProvider.orders;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background Decorative Element
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.03),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Expanded(
                  child: orderProvider.isLoading && orders.isEmpty
                      ? Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        )
                      : orders.isEmpty
                      ? _buildEmptyOrders()
                      : RefreshIndicator(
                          color: primaryColor,
                          onRefresh: () async {
                            final token = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            ).token;
                            if (token != null) {
                              await orderProvider.fetchOrders(token);
                            }
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 10,
                            ),
                            itemCount: orders.length,
                            itemBuilder: (context, index) {
                              final order = orders[index];
                              return _OrderCard(
                                order: order,
                                primaryColor: primaryColor,
                                backgroundColor: backgroundColor,
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() => const Padding(
    padding: EdgeInsets.fromLTRB(24, 20, 24, 20),
    child: Text(
      StringConstants.orderHistory,
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w300,
        fontFamily: 'Serif',
        color: Color(0xFF1A1A1A),
      ),
    ),
  );

  Widget _buildEmptyOrders() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.assignment_outlined,
            size: 60,
            color: primaryColor.withValues(alpha: 0.2),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          StringConstants.noOrdersYet,
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Serif',
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your floral journey begins with your first selection.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black.withValues(alpha: 0.4)),
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ProductListScreen(popNeeded: true),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Text(
              StringConstants.startShopping,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.primaryColor,
    required this.backgroundColor,
  });
  final dynamic order;
  final Color primaryColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: order.id)),
      );
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${order.orderNumber}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.placedAt.split('T')[0],
                        style: const TextStyle(
                          color: Colors.black26,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _statusBadge(order.orderStatus),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 1, thickness: 0.5, color: Color(0xFFEEEEEE)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    StringConstants.totalAmount,
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w800,
                      color: Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${order.finalAmount}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      StringConstants.details,
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _statusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = primaryColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
