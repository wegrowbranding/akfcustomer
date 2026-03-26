import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/constants/string_constants.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shopping/providers/shopping_provider.dart';
import '../models/home_models.dart';
import '../providers/home_provider.dart';
import 'product_detail_screen.dart';
import 'product_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Theme Constants - Simplified to use AppTheme
  final Color primaryColor = AppTheme.primaryColor;
  final Color secondaryColor = AppTheme.secondaryColor;
  final Color backgroundColor = AppTheme.backgroundColor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token != null) {
        Provider.of<HomeProvider>(context, listen: false).fetchDashboard(token);
        Provider.of<HomeProvider>(
          context,
          listen: false,
        ).updateLastActive(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);

    if (homeProvider.isLoading && homeProvider.dashboardData == null) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }

    if (homeProvider.error != null && homeProvider.dashboardData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: primaryColor),
            const SizedBox(height: 16),
            Text(
              homeProvider.error!,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      );
    }

    final data = homeProvider.dashboardData;
    if (data == null) {
      return const Center(child: Text('No data found'));
    }

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: () async {
        final token = Provider.of<AuthProvider>(context, listen: false).token;
        if (token != null) {
          await homeProvider.fetchDashboard(token);
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // 0. Search Field
            _buildSearchField(),

            const SizedBox(height: 10),

            // 1. Featured Promo Banner
            _buildPromoBanner(),

            const SizedBox(height: 32),

            // 2. Categories Section
            _buildSectionHeader(
              StringConstants.shopByCategory,
              onSeeAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProductListScreen(popNeeded: true),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 110,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: data.categories.length,
                itemBuilder: (context, index) =>
                    _buildCategoryItem(data.categories[index]),
              ),
            ),

            const SizedBox(height: 32),

            // 3. New Arrivals (Recent Products)
            _buildSectionHeader(StringConstants.newArrivals),
            const SizedBox(height: 16),
            SizedBox(
              height: 260,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: data.recentProducts.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _ProductCard(
                    product: data.recentProducts[index],
                    primaryColor: primaryColor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 4. Curated Selection (Featured Products)
            _buildSectionHeader(StringConstants.curatedForYou),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: data.featuredProducts.length,
                itemBuilder: (context, index) => _ProductCard(
                  product: data.featuredProducts[index],
                  primaryColor: primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w300,
            fontFamily: 'Serif',
            color: Colors.black87,
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              StringConstants.viewAll,
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.w800,
                color: primaryColor,
              ),
            ),
          ),
      ],
    ),
  );

  Widget _buildSearchField() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ProductListScreen(popNeeded: true),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: primaryColor, size: 22),
            const SizedBox(width: 12),
            Text(
              StringConstants.searchHint,
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.2),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildPromoBanner() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.local_florist,
              size: 150,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  StringConstants.bloomIntoSpring,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  StringConstants.seasonalBouquetsPromo,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const ProductListScreen(popNeeded: true),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      StringConstants.shopNow,
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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

  Widget _buildCategoryItem(Category cat) => Padding(
    padding: const EdgeInsets.only(right: 20),
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductListScreen(
              popNeeded: true,
              categoryId: cat.id,
              categoryName: cat.categoryName,
            ),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            height: 70,
            width: 70,
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
            child: Center(
              child: Text(
                cat.categoryName[0],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            cat.categoryName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    ),
  );
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.primaryColor});
  final Product product;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(productId: product.id),
        ),
      );
    },
    child: Container(
      width: 170,
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
          // Image Area
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.05),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    image: product.primaryMediaId != null
                        ? DecorationImage(
                            image: NetworkImage(
                              ApiConstants.storageUrl(product.primaryMediaId!),
                            ),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {},
                          )
                        : null,
                  ),
                  child: product.primaryImageUrl == null
                      ? Center(
                          child: Icon(
                            Icons.local_florist_outlined,
                            size: 50,
                            color: primaryColor.withValues(alpha: 0.3),
                          ),
                        )
                      : null,
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () async {
                      final auth = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      final shopping = Provider.of<ShoppingProvider>(
                        context,
                        listen: false,
                      );
                      if (auth.token != null) {
                        final success = await shopping.toggleWishlist(
                          auth.token!,
                          product.id,
                          'add',
                        );
                        if (success && context.mounted) {
                          AppSnackBar.show(
                            context,
                            message: StringConstants.wishlistUpdated,
                            type: SnackBarType.success,
                          );
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite_border,
                        size: 16,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Details Area
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF2D2D2D),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${product.price}',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final auth = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );
                        final shopping = Provider.of<ShoppingProvider>(
                          context,
                          listen: false,
                        );
                        if (auth.token != null) {
                          final success = await shopping.updateCart(
                            auth.token!,
                            product.id,
                            1,
                          );
                          if (success && context.mounted) {
                            AppSnackBar.show(
                              context,
                              message: StringConstants.addedToBouquet,
                              type: SnackBarType.success,
                            );
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
