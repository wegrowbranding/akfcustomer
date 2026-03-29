import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/constants/string_constants.dart';
import '../../../core/themes/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/screens/product_list_screen.dart';
import '../providers/shopping_provider.dart';
import 'address_list_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
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
        Provider.of<ShoppingProvider>(context, listen: false).fetchCart(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final shoppingProvider = Provider.of<ShoppingProvider>(context);
    final cart = shoppingProvider.cart;
    final token = Provider.of<AuthProvider>(context, listen: false).token;

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
                  child: shoppingProvider.isLoading && cart == null
                      ? Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        )
                      : cart == null || cart.items.isEmpty
                      ? _buildEmptyCart()
                      : _buildCartList(cart, token!, shoppingProvider),
                ),
                if (cart != null && cart.items.isNotEmpty)
                  _buildBottomBar(cart),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => const Padding(
    padding: EdgeInsets.fromLTRB(24, 20, 24, 10),
    child: Text(
      StringConstants.myBouquet,
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w300,
        fontFamily: 'Serif',
        color: Color(0xFF1A1A1A),
      ),
    ),
  );

  Widget _buildEmptyCart() => Center(
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
              ),
            ],
          ),
          child: Icon(
            Icons.shopping_bag_outlined,
            size: 60,
            color: primaryColor.withValues(alpha: 0.2),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          StringConstants.cartEmpty,
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Serif',
            fontWeight: FontWeight.w300,
          ),
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
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
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
              StringConstants.shopNow,
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

  Widget _buildCartList(
    dynamic cart,
    String token,
    ShoppingProvider provider,
  ) => ListView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
    itemCount: cart.items.length,
    itemBuilder: (context, index) {
      final item = cart.items[index];

      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
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
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(20),
                image: item.product.primaryMediaId != null
                    ? DecorationImage(
                        image: NetworkImage(
                          ApiConstants.storageUrl(item.product.primaryMediaId!),
                        ),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {},
                      )
                    : null,
              ),
              child: item.product.primaryImageUrl == null
                  ? Center(
                      child: Icon(
                        Icons.local_florist_outlined,
                        size: 30,
                        color: primaryColor.withValues(alpha: 0.3),
                      ),
                    )
                  : null,
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
                          item.product.productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            provider.updateCart(token, item.productId, 0),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Colors.black.withValues(alpha: 0.2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${item.product.price}',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _qtyButton(Icons.remove_rounded, () {
                              if (item.quantity > 1) {
                                provider.updateCart(
                                  token,
                                  item.productId,
                                  item.quantity - 1,
                                );
                              } else {
                                provider.updateCart(token, item.productId, 0);
                              }
                            }),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              child: Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            _qtyButton(Icons.add_rounded, () {
                              provider.updateCart(
                                token,
                                item.productId,
                                item.quantity + 1,
                              );
                            }),
                          ],
                        ),
                      ),
                      Text(
                        '₹${((double.parse(item.product.price)) * (item.quantity as int)).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );

  Widget _qtyButton(IconData icon, VoidCallback onPressed) => GestureDetector(
    onTap: onPressed,
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5),
        ],
      ),
      child: Icon(icon, size: 14, color: primaryColor),
    ),
  );

  Widget _buildBottomBar(dynamic cart) => Container(
    padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 20,
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
              StringConstants.subtotalAmount,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black45,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '₹${(cart.totalAmount as double).toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                fontFamily: 'Serif',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddressListScreen()),
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
                StringConstants.proceedToCheckout,
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
}
