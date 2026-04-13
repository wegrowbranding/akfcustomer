import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/constants/string_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/login_prompt.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shopping/providers/shopping_provider.dart';
import '../../shopping/screens/address_list_screen.dart';
import '../models/home_models.dart';
import '../providers/home_provider.dart';
import 'reviews_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({required this.productId, super.key});
  final int productId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isAdding = false;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  // Design Tokens - Simplified to use AppTheme
  final Color primaryColor = AppTheme.primaryColor;
  final Color secondaryColor = AppTheme.secondaryColor;
  final Color backgroundColor = AppTheme.backgroundColor;
  final Color accentColor = const Color(
    0xFF4A5D4E,
  ); // Sage Green from onboarding for pro look

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _addToCart() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final shopping = Provider.of<ShoppingProvider>(context, listen: false);

    if (auth.token == null) {
      LoginPrompt.show(context);
      return;
    }

    setState(() => _isAdding = true);
    final success = await shopping.updateCart(auth.token!, widget.productId, 1);
    setState(() => _isAdding = false);

    if (success && mounted) {
      AppSnackBar.show(
        context,
        message: StringConstants.addedToBouquet,
        type: SnackBarType.success,
      );
    }
  }

  Future<void> _toggleWishlist(bool addOrRemove) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final shopping = Provider.of<ShoppingProvider>(context, listen: false);
    if (auth.token == null) {
      LoginPrompt.show(context);
      return;
    }

    final success = await shopping.toggleWishlist(
      auth.token!,
      widget.productId,
      addOrRemove ? 'add' : 'delete',
    );

    if (success && mounted) {
      AppSnackBar.show(
        context,
        message: StringConstants.wishlistUpdated,
        type: SnackBarType.success,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    final home = Provider.of<HomeProvider>(context, listen: false);
    final shopping = Provider.of<ShoppingProvider>(context, listen: false);

    home.clearSelectedProduct();
    home.fetchProductDetails(token, widget.productId);
    if (token != null) {
      shopping.markAsViewed(token, widget.productId);
      shopping.checkProductInWishlist(token, widget.productId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);

    if (homeProvider.isLoading && homeProvider.selectedProduct == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    final product = homeProvider.selectedProduct;
    if (product == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: Text('Product not found')),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.9),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Colors.black87,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          Consumer<ShoppingProvider>(
            builder: (context, shopping, child) {
              final isProductWishlisted = shopping.isWishlisted(
                widget.productId,
              );
              return CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.9),
                child: IconButton(
                  onPressed: isProductWishlisted
                      ? () => _toggleWishlist(false)
                      : () => _toggleWishlist(true),
                  icon: Icon(
                    isProductWishlisted
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: isProductWishlisted ? primaryColor : Colors.black87,
                    size: 20,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.9),
            child: IconButton(
              onPressed: () async {
                final ShareParams params = ShareParams(
                  text:
                      '''🌸 ${product.productName} \n${product.description ?? 'A beautiful bloom just for you 🌼'} \n💰 Price: ₹${product.price} \n🛍️ Order now and brighten your day!''',
                );
                await SharePlus.instance.share(params);
              },
              icon: const Icon(
                Icons.share_outlined,
                size: 20,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Premium Product Image Section
            _buildHeroImage(product),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand & Category Label
                  Text(
                    StringConstants.premiumSelection,
                    style: TextStyle(
                      letterSpacing: 3,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Product Name
                  Text(
                    product.productName,
                    style: const TextStyle(
                      fontSize: 32,
                      height: 1.1,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'Serif',
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Price & Rating Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${product.price}',
                        style: TextStyle(
                          fontSize: 26,
                          color: primaryColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber.shade600,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '4.8 (120 reviews)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Availability Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: product.stockQuantity > 0
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.stockQuantity > 0
                          ? StringConstants.inStock
                          : StringConstants.outOfStock,
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1,
                        color: product.stockQuantity > 0
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Description Section
                  const Text(
                    StringConstants.theStory,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'Serif',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product.description ??
                        'Each bloom is hand-selected from our artisanal gardens to ensure lasting freshness and beauty in your sanctuary.',
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.6),
                      height: 1.8,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Reviews Link
                  _buildReviewsSection(widget.productId),

                  const SizedBox(height: 48),
                ],
              ),
            ),

            // Related Products
            if (homeProvider.relatedProducts.isNotEmpty) ...[
              _buildRelatedProductsSection(homeProvider.relatedProducts),
              const SizedBox(height: 120), // Bottom padding for action bar
            ],
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  Widget _buildHeroImage(Product product) => Stack(
    children: [
      Container(
        height: MediaQuery.of(context).size.height * 0.55,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
          child: PageView.builder(
            controller: _pageController,
            itemCount: product.media.length,
            onPageChanged: (index) =>
                setState(() => _currentImageIndex = index),
            itemBuilder: (context, index) {
              final media = product.media[index];
              return InkWell(
                onTap: () => _showFullScreenImage(media.id),
                child: Hero(
                  tag: 'product_image_${media.id}',
                  child: Image.network(
                    ApiConstants.storageUrl(media.id),
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return Center(
                        child: CircularProgressIndicator(
                          color: primaryColor.withValues(alpha: 0.2),
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: backgroundColor,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: primaryColor.withValues(alpha: 0.2),
                        size: 40,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      // Image Counter/Indicator
      if (product.media.length > 1)
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: product.media
                .asMap()
                .entries
                .map(
                  (entry) => Container(
                    width: _currentImageIndex == entry.key ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentImageIndex == entry.key
                          ? primaryColor
                          : Colors.white.withValues(alpha: 0.5),
                      boxShadow: [
                        if (_currentImageIndex == entry.key)
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      // Subtle Gradient Overlay at the bottom of image
      Positioned.fill(
        child: IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.15),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );

  void _showFullScreenImage(int mediaId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4,
                  boundaryMargin: const EdgeInsets.all(20),
                  child: Hero(
                    tag: 'product_image_$mediaId',
                    child: Image.network(
                      ApiConstants.storageUrl(mediaId),
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.black45,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsSection(int productId) => InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ReviewsScreen(productId: productId)),
      );
    },
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.rate_review_outlined,
              color: primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  StringConstants.customerImpressions,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  'Read what others are saying',
                  style: TextStyle(color: Colors.black45, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.black.withValues(alpha: 0.3)),
        ],
      ),
    ),
  );

  Widget _buildRelatedProductsSection(List<Product> products) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          StringConstants.complementsWellWith,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w300,
            fontFamily: 'Serif',
          ),
        ),
      ),
      const SizedBox(height: 20),
      SizedBox(
        height: 280,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          scrollDirection: Axis.horizontal,
          itemCount: products.length,
          itemBuilder: (context, index) {
            final rp = products[index];
            return Padding(
              padding: const EdgeInsets.only(right: 20),
              child: _RelatedProductCard(
                product: rp,
                primaryColor: primaryColor,
              ),
            );
          },
        ),
      ),
    ],
  );

  Widget _buildBottomActionBar() => Container(
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
    child: Row(
      children: [
        // Add to Cart Pill
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: _isAdding ? null : _addToCart,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
              ),
              child: Center(
                child: _isAdding
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: primaryColor,
                        ),
                      )
                    : Text(
                        StringConstants.addToCart,
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Buy Now Premium Pill
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: () async {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              if (auth.token == null) {
                LoginPrompt.show(context);
                return;
              }
              await _addToCart();
              if (mounted) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddressListScreen()),
                );
              }
            },
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  StringConstants.buyNow,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _RelatedProductCard extends StatelessWidget {
  const _RelatedProductCard({
    required this.product,
    required this.primaryColor,
  });
  final Product product;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      context.pushReplacement('${AppRoutes.productDetail}/${product.id}');
    },
    child: Container(
      width: 180,
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
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(
                        product.primaryMediaId != null
                            ? ApiConstants.storageUrl(product.primaryMediaId!)
                            : 'https://images.unsplash.com/photo-1533616688419-b7a585564566?q=80&w=400&auto=format&fit=crop',
                      ),
                      onError: (exception, stackTrace) {},
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Consumer<ShoppingProvider>(
                    builder: (context, shopping, child) {
                      final isWishlisted = shopping.isWishlisted(product.id);
                      return GestureDetector(
                        onTap: () async {
                          final auth = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );
                          if (auth.token != null) {
                            final success = await shopping.toggleWishlist(
                              auth.token!,
                              product.id,
                              isWishlisted ? 'delete' : 'add',
                            );
                            if (success && context.mounted) {
                              AppSnackBar.show(
                                context,
                                message: StringConstants.wishlistUpdated,
                                type: SnackBarType.success,
                              );
                            }
                          } else {
                            LoginPrompt.show(context);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isWishlisted
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 14,
                            color: primaryColor,
                          ),
                        ),
                      );
                    },
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
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
