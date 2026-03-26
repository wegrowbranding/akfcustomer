import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/string_constants.dart';
import '../../home/screens/home_screen.dart';
import '../../orders/providers/order_provider.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  Color get primaryColor => const Color(0xFFE91E63);
  Color get secondaryColor => const Color(0xFFF06292);
  Color get backgroundColor => const Color(0xFFF9F6F2);
  Color get textColor => const Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final order = orderProvider.lastOrder;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background Decorative Elements
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.03),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: secondaryColor.withValues(alpha: 0.02),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 1. Success Animation/Icon
                    _buildSuccessIcon(),

                    const SizedBox(height: 40),

                    // 2. Editorial Heading
                    const Text(
                      StringConstants.appName,
                      style: TextStyle(
                        letterSpacing: 6,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: Colors.black38,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Bouquet Placed\nSuccessfully',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34,
                        height: 1.1,
                        fontWeight: FontWeight.w300,
                        fontFamily: 'Serif',
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your artisanal arrangement is now being prepared with care for your sanctuary.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black.withValues(alpha: 0.5),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // 3. Order Details Card
                    if (order != null) _buildOrderSummaryCard(order),

                    const SizedBox(height: 60),

                    // 4. Action Button
                    _buildHomeButton(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessIcon() => Container(
    padding: const EdgeInsets.all(30),
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: primaryColor.withValues(alpha: 0.1),
          blurRadius: 30,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check_rounded, size: 60, color: Colors.white),
    ),
  );

  Widget _buildOrderSummaryCard(dynamic order) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ORDER REF:',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w800,
                color: Colors.black26,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '#${order.orderNumber}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Divider(height: 1, thickness: 0.5),
        ),
        _summaryRow('Total Paid', '₹${order.finalAmount}', isBold: true),
        if (order.discountAmount > 0) ...[
          const SizedBox(height: 12),
          _summaryRow(
            'Boutique Savings',
            '-₹${order.discountAmount}',
            isHighlight: true,
          ),
        ],
        const SizedBox(height: 12),
        _summaryRow('Arrival Date', order.placedAt.split('T')[0]),
      ],
    ),
  );

  Widget _summaryRow(
    String label,
    String value, {
    bool isBold = false,
    bool isHighlight = false,
  }) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          color: isHighlight ? primaryColor : Colors.black45,
          fontSize: 14,
          fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontWeight: isBold || isHighlight ? FontWeight.w900 : FontWeight.w600,
          color: isHighlight
              ? primaryColor
              : (isBold ? Colors.black : Colors.black87),
          fontSize: isBold ? 16 : 14,
        ),
      ),
    ],
  );

  Widget _buildHomeButton(BuildContext context) => GestureDetector(
    onTap: () {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (_) => const HomeScreen()),
      );
    },
    child: Container(
      height: 65,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'BACK TO HOME',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 14,
          ),
        ),
      ),
    ),
  );
}
