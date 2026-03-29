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

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({
    super.key,
    this.categoryId,
    this.categoryName,
    this.searchText,
    this.popNeeded,
  });
  final int? categoryId;
  final String? categoryName;
  final String? searchText;
  final bool? popNeeded;

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  String _selectedSort = '';

  // Design Tokens - Simplified to use AppTheme
  final Color primaryColor = AppTheme.primaryColor;
  final Color secondaryColor = AppTheme.secondaryColor;
  final Color backgroundColor = AppTheme.backgroundColor;
  final Color accentColor = const Color(0xFF4A5D4E); // Sage Green

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchText ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token != null) {
        Provider.of<ShoppingProvider>(
          context,
          listen: false,
        ).fetchWishlist(token);
        Provider.of<HomeProvider>(context, listen: false).fetchProducts(
          token,
          categoryId: widget.categoryId,
          search: widget.searchText ?? '',
        );
      }
    });
  }

  void _onSearch() {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token != null) {
      setState(() {}); // Ensure UI shows loading or current state
      Provider.of<HomeProvider>(context, listen: false).fetchProducts(
        token,
        search: _searchController.text.trim(),
        categoryId: widget.categoryId,
        minPrice: _minPriceController.text.trim(),
        maxPrice: _maxPriceController.text.trim(),
        sort: _selectedSort,
      );
    }
  }

  void _resetLocalFilters() {
    setState(() {
      _searchController.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
      _selectedSort = '';
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Refine Search',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Text(
                  'Price Range',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _minPriceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Min ₹',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _maxPriceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Max ₹',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Text(
                  'Sort By',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildSortChip('Newest', 'newest', setModalState),
                    _buildSortChip(
                      'Price: Low to High',
                      'price_asc',
                      setModalState,
                    ),
                    _buildSortChip(
                      'Price: High to Low',
                      'price_desc',
                      setModalState,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setModalState(_resetLocalFilters);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _onSearch();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(String label, String value, StateSetter setModalState) {
    final isSelected = _selectedSort == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setModalState(() {
          _selectedSort = selected ? value : '';
        });
      },
      selectedColor: primaryColor.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: isSelected ? primaryColor : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: isSelected ? primaryColor : Colors.grey[300]!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          final token = Provider.of<AuthProvider>(context, listen: false).token;
          if (token != null) {
            // Reset provider to all products when this screen is closed
            Provider.of<HomeProvider>(
              context,
              listen: false,
            ).fetchProducts(token);
          }
        }
      },
      child: Scaffold(
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
                  // 1. Editorial Header
                  _buildHeader(),

                  // 2. Search Section
                  _buildSearchField(),

                  // 3. Product Grid
                  Expanded(child: _buildContent(homeProvider)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.popNeeded ?? false)
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
          ),
        if (widget.categoryName != null && widget.categoryName!.isNotEmpty)
          Text(
            widget.categoryName ?? 'N/A',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w300,
              fontFamily: 'Serif',
              color: Color(0xFF1A1A1A),
            ),
          )
        else
          const Text(
            StringConstants.ourCollection,
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

  Widget _buildSearchField() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onSubmitted: (_) => _onSearch(),
        decoration: InputDecoration(
          hintText: StringConstants.searchHint,
          hintStyle: TextStyle(
            color: Colors.black.withValues(alpha: 0.2),
            fontSize: 14,
          ),
          prefixIcon: Icon(Icons.search_rounded, color: primaryColor, size: 22),
          suffixIcon: IconButton(
            onPressed: _showFilterBottomSheet,
            icon: Icon(Icons.tune_rounded, color: primaryColor, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
        ),
      ),
    ),
  );

  Widget _buildContent(HomeProvider homeProvider) {
    if (homeProvider.isLoading) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }

    if (homeProvider.error != null) {
      return Center(child: Text(homeProvider.error!));
    }

    if (homeProvider.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_vintage_outlined,
              size: 60,
              color: primaryColor.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            const Text(
              StringConstants.noBloomsFound,
              style: TextStyle(color: Colors.black38),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
      ),
      itemCount: homeProvider.products.length,
      itemBuilder: (context, index) => _ProductListItemCard(
        product: homeProvider.products[index],
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
      ),
    );
  }
}

class _ProductListItemCard extends StatelessWidget {
  const _ProductListItemCard({
    required this.product,
    required this.primaryColor,
    required this.secondaryColor,
  });
  final Product product;
  final Color primaryColor;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    // Elegant placeholder imagery
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
            // Image Area
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
                      fontSize: 14,
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
                            color: primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.add, size: 14, color: primaryColor),
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
}
