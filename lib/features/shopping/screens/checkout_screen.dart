import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/string_constants.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../auth/providers/auth_provider.dart';
import '../../orders/models/order_models.dart';
import '../../orders/providers/order_provider.dart';
import '../models/shopping_models.dart';
import '../providers/shopping_provider.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({required this.address, super.key});
  final Address address;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _couponController = TextEditingController();
  bool _isApplyingCoupon = false;

  final Color primaryColor = AppTheme.primaryColor;
  final Color secondaryColor = AppTheme.secondaryColor;
  final Color backgroundColor = AppTheme.backgroundColor;
  final Color textColor = const Color(0xFF1A1A1A);

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) {
      return;
    }

    setState(() => _isApplyingCoupon = true);
    final shoppingProvider = Provider.of<ShoppingProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (shoppingProvider.cart == null) {
      return;
    }

    final success = await shoppingProvider.applyCoupon(
      authProvider.token!,
      code,
      shoppingProvider.cart!.totalAmount,
    );
    setState(() => _isApplyingCoupon = false);

    if (!success && mounted) {
      AppSnackBar.show(
        context,
        message: shoppingProvider.error ?? 'Failed to apply coupon',
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _placeOrder() async {
    final shoppingProvider = Provider.of<ShoppingProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final orderData = await shoppingProvider.placeOrder(
      authProvider.token!,
      widget.address.id,
      'cod',
      shoppingProvider.appliedCoupon?.couponCode,
    );

    if (orderData != null && mounted) {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      orderProvider.setLastOrder(Order.fromJson(orderData));

      await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
        (route) => route.isFirst,
      );
    } else if (mounted) {
      AppSnackBar.show(
        context,
        message: shoppingProvider.error ?? 'Failed to place order',
        type: SnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final shoppingProvider = Provider.of<ShoppingProvider>(context);
    final cart = shoppingProvider.cart;

    if (cart == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    final appliedCoupon = shoppingProvider.appliedCoupon;

    final double subtotal = cart.totalAmount;
    final double discount = appliedCoupon?.discountAmount ?? 0;
    final double finalAmount = appliedCoupon?.finalAmount ?? subtotal;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        _buildSectionLabel(StringConstants.shippingDestination),
                        const SizedBox(height: 12),
                        _buildAddressCard(),

                        const SizedBox(height: 32),
                        _buildSectionLabel(StringConstants.promotionalCode),
                        const SizedBox(height: 12),
                        _buildCouponField(appliedCoupon),

                        const SizedBox(height: 32),
                        _buildSectionLabel(StringConstants.billingSummary),
                        const SizedBox(height: 12),
                        _buildOrderSummaryCard(subtotal, discount, finalAmount),

                        const SizedBox(height: 32),
                        _buildSectionLabel(StringConstants.paymentMethod),
                        const SizedBox(height: 12),
                        _buildPaymentMethod(),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomAction(finalAmount, shoppingProvider),
    );
  }

  Widget _buildHeader(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 10, 24, 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              StringConstants.appName,
              style: TextStyle(
                letterSpacing: 4,
                fontWeight: FontWeight.w800,
                fontSize: 10,
                color: Colors.black54,
              ),
            ),
            Text(
              StringConstants.checkoutSummary,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w300,
                fontFamily: 'Serif',
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildSectionLabel(String label) => Text(
    label,
    style: const TextStyle(
      fontSize: 11,
      letterSpacing: 2,
      fontWeight: FontWeight.w800,
      color: Colors.black38,
    ),
  );

  Widget _buildAddressCard() => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.location_on_rounded, color: primaryColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.address.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${widget.address.addressLine1}, ${widget.address.city}, ${widget.address.state} - ${widget.address.pincode}',
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.6),
                  height: 1.5,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Phone: ${widget.address.phone}',
                style: const TextStyle(
                  color: Colors.black38,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildCouponField(dynamic appliedCoupon) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: _couponController,
          onChanged: (value) => setState(() {}),
          onTapOutside: (event) =>
              FocusManager.instance.primaryFocus?.unfocus(),
          style: const TextStyle(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'Enter code (e.g., BLOOM20)',
            hintStyle: TextStyle(
              color: Colors.black.withValues(alpha: 0.2),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Iconsax.ticket_discount,
              color: primaryColor,
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 20,
            ),
            suffixIcon: _couponController.text.isNotEmpty
                ? _isApplyingCoupon
                      ? Container(
                          width: 18,
                          height: 18,
                          margin: const EdgeInsets.all(15),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: primaryColor,
                          ),
                        )
                      : IconButton(
                          icon: Icon(Iconsax.tick_circle, color: primaryColor),
                          onPressed: _isApplyingCoupon ? null : _applyCoupon,
                        )
                : null,
          ),
        ),
      ),
      if (appliedCoupon != null)
        Padding(
          padding: const EdgeInsets.only(top: 12, left: 10),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 14,
              ),
              const SizedBox(width: 8),
              Text(
                'Code ${appliedCoupon.couponCode} applied to your selection.',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
    ],
  );

  Widget _buildOrderSummaryCard(
    double subtotal,
    double discount,
    double finalAmount,
  ) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      children: [
        _priceRow(StringConstants.boutiqueSubtotal, '₹$subtotal'),
        if (discount > 0) ...[
          const SizedBox(height: 16),
          _priceRow(
            StringConstants.artisanalDiscount,
            '-₹$discount',
            isHighlight: true,
          ),
        ],
        const SizedBox(height: 16),
        _priceRow(
          StringConstants.shippingAndHandling,
          'COMPLIMENTARY',
          isHighlight: true,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Divider(height: 1, thickness: 0.5),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              StringConstants.totalPayable,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w300,
                fontFamily: 'Serif',
              ),
            ),
            Text(
              '₹$finalAmount',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildPaymentMethod() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: RadioListTile(
      value: 'cod',
      // ignore: deprecated_member_use
      groupValue: 'cod',
      // ignore: deprecated_member_use
      onChanged: (_) {},
      title: const Text(
        'Cash on Delivery',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
      subtitle: const Text(
        'Pay upon arrival at your sanctuary',
        style: TextStyle(fontSize: 12),
      ),
      activeColor: primaryColor,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    ),
  );

  Widget _buildBottomAction(
    double finalAmount,
    ShoppingProvider shoppingProvider,
  ) => Container(
    padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
    decoration: BoxDecoration(
      color: backgroundColor,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, -5),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              StringConstants.grandTotal,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black45,
              ),
            ),
            Text(
              '₹$finalAmount',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: shoppingProvider.isLoading ? null : _placeOrder,
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
            child: Center(
              child: shoppingProvider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      StringConstants.placeOrder,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _priceRow(String label, String value, {bool isHighlight = false}) =>
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
              fontWeight: isHighlight ? FontWeight.w700 : FontWeight.normal,
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
