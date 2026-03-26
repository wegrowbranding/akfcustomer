import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/constants/string_constants.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/screens/product_detail_screen.dart';
import '../providers/shopping_provider.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
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
        Provider.of<ShoppingProvider>(
          context,
          listen: false,
        ).fetchWishlist(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final shoppingProvider = Provider.of<ShoppingProvider>(context);
    final wishlist = shoppingProvider.wishlist;

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
                _buildHeader(context),
                Expanded(
                  child: shoppingProvider.isLoading && wishlist == null
                      ? Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        )
                      : (wishlist == null || wishlist.items.isEmpty)
                      ? _buildEmptyWishlist()
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.65,
                                crossAxisSpacing: 18,
                                mainAxisSpacing: 18,
                              ),
                          itemCount: wishlist.items.length,
                          itemBuilder: (context, index) {
                            final item = wishlist.items[index];
                            return _WishlistProductCard(
                              item: item,
                              primaryColor: primaryColor,
                              secondaryColor: secondaryColor,
                              backgroundColor: backgroundColor,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
            ),
            const Text(
              StringConstants.appName,
              style: TextStyle(
                letterSpacing: 4,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            const SizedBox(width: 40), // Balance for back button
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Saved Blooms',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w300,
            fontFamily: 'Serif',
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    ),
  );

  Widget _buildEmptyWishlist() => Center(
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
            Icons.favorite_border_rounded,
            size: 60,
            color: primaryColor.withValues(alpha: 0.2),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Your wishlist is empty',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Serif',
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Keep track of arrangements you adore.',
          style: TextStyle(color: Colors.black.withValues(alpha: 0.4)),
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () => Navigator.pop(context),
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
              'EXPLORE PRODUCTS',
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

class _WishlistProductCard extends StatelessWidget {
  const _WishlistProductCard({
    required this.item,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
  });
  final dynamic item;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final token = Provider.of<AuthProvider>(context).token;
    final shoppingProvider = Provider.of<ShoppingProvider>(
      context,
      listen: false,
    );

    // High-quality flower placeholder
    const String flowerUrl =
        'https://images.unsplash.com/photo-1519337020834-263d80c1519a?q=80&w=500&auto=format&fit=crop';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: product.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      image: DecorationImage(
                        image: NetworkImage(
                          product.primaryMediaId != null
                              ? ApiConstants.storageUrl(product.primaryMediaId!)
                              : flowerUrl,
                        ),
                        onError: (exception, stackTrace) {},
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () {
                        if (token != null) {
                          shoppingProvider.toggleWishlist(
                            token,
                            product.id,
                            'remove',
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.favorite_rounded,
                          color: primaryColor,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF2D2D2D),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹${product.price}',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      if (token != null) {
                        shoppingProvider.updateCart(token, product.id, 1);
                        AppSnackBar.show(
                          context,
                          message: 'Added to your bouquet',
                          type: SnackBarType.success,
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.2),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'ADD TO CART',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
