import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/constants/string_constants.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/order_provider.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({required this.orderId, super.key});
  final int orderId;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  // Design Tokens
  final Color primaryColor = const Color(0xFFE91E63);
  final Color secondaryColor = const Color(0xFFF06292);
  final Color backgroundColor = const Color(0xFFF9F6F2);
  final Color textColor = const Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token != null) {
        Provider.of<OrderProvider>(
          context,
          listen: false,
        ).fetchOrderDetails(token, widget.orderId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final order = orderProvider.selectedOrderDetails;

    if (orderProvider.isLoading && order == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    if (order == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: Text('Order details not found')),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background Decorative Element
          Positioned(
            top: -50,
            right: -50,
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
              children: [
                _buildHeader(context, order.orderNumber),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildStatusCard(order),
                        const SizedBox(height: 32),
                        const Text(
                          'Your Selection',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w300,
                            fontFamily: 'Serif',
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildItemsList(order),
                        const SizedBox(height: 32),
                        _buildCostSummary(order),
                        const SizedBox(height: 40),
                        if (order.orderStatus.toLowerCase() != 'cancelled')
                          _buildCancelButton(context, orderProvider),
                        const SizedBox(height: 80),
                      ],
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

  Widget _buildCancelButton(BuildContext context, OrderProvider provider) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: GestureDetector(
          onTap: () => _showCancelConfirmation(context, provider),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'REQUEST CANCEL',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      );

  void _showCancelConfirmation(
    BuildContext parentContext,
    OrderProvider provider,
  ) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Cancel Order?',
          style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.w300),
        ),
        content: const Text(
          'Are you sure you want to request a cancellation for this arrangement?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('STAY'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // ✅ use dialog context to close

              final token = Provider.of<AuthProvider>(
                parentContext,
                listen: false,
              ).token;

              if (token != null) {
                final success = await provider.cancelOrder(
                  token,
                  widget.orderId,
                );

                if (success && mounted) {
                  AppSnackBar.show(
                    parentContext,
                    message: 'Cancellation request sent successfully',
                    type: SnackBarType.success,
                  );
                } else if (mounted) {
                  AppSnackBar.show(
                    parentContext,
                    message: provider.error ?? 'Failed to cancel order',
                    type: SnackBarType.error,
                  );
                }
              }
            },
            child: const Text('CANCEL', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String orderNo) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 10, 24, 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              StringConstants.appName,
              style: TextStyle(
                letterSpacing: 4,
                fontWeight: FontWeight.w800,
                fontSize: 10,
                color: Colors.black54,
              ),
            ),
            Text(
              '#$orderNo',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black38,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildStatusCard(dynamic order) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [primaryColor, secondaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: primaryColor.withValues(alpha: 0.2),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.orderStatus.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Placed on ${order.placedAt.split('T')[0]}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildItemsList(dynamic order) => ListView.separated(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: order.items.length,
    separatorBuilder: (_, _) => const SizedBox(height: 16),
    itemBuilder: (context, index) {
      final item = order.items[index];
      // Placeholder Unsplash image for flowers
      const String flowerUrl =
          'https://images.unsplash.com/photo-1526047932273-341f2a7631f9?q=80&w=200&auto=format&fit=crop';

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: NetworkImage(
                    item.product.primaryMediaId != null
                        ? ApiConstants.storageUrl(item.product.primaryMediaId!)
                        : flowerUrl,
                  ),
                  onError: (exception, stackTrace) {},
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Qty: ${item.quantity} x ₹${item.price}',
                    style: const TextStyle(color: Colors.black45, fontSize: 13),
                  ),
                ],
              ),
            ),
            Text(
              '₹${item.totalPrice}',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: primaryColor,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    },
  );

  Widget _buildCostSummary(dynamic order) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transaction Summary',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 20),
        _summaryRow('Subtotal', '₹${order.totalAmount}'),
        if (order.discountAmount > 0) ...[
          const SizedBox(height: 12),
          _summaryRow(
            'Boutique Discount',
            '-₹${order.discountAmount}',
            isHighlight: true,
          ),
        ],
        const SizedBox(height: 12),
        _summaryRow('Shipping Fee', 'COMPLIMENTARY', isHighlight: true),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Divider(height: 1),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Paid',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w300,
                fontFamily: 'Serif',
              ),
            ),
            Text(
              '₹${order.finalAmount}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Icon(Icons.payment_rounded, size: 18, color: primaryColor),
              const SizedBox(width: 12),
              Text(
                'Paid via ${order.paymentMethod.toUpperCase()}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _summaryRow(String label, String value, {bool isHighlight = false}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isHighlight
                  ? primaryColor.withValues(alpha: 0.7)
                  : Colors.black45,
              fontSize: 14,
              fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: isHighlight ? primaryColor : Colors.black87,
            ),
          ),
        ],
      );
}
