import 'package:flutter/material.dart';
import '../../../features/home/models/home_models.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.product,
    required this.onTap,
    required this.onAddToCart,
    required this.onToggleWishlist,
    super.key,
    this.isInWishlist = false,
  });
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final VoidCallback onToggleWishlist;
  final bool isInWishlist;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 2,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: product.primaryImageUrl != null
                    ? Image.network(
                        product.primaryImageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Icon(Icons.error, color: Colors.red),
                            ),
                      )
                    : const Center(
                        child: Icon(Icons.image, color: Colors.grey, size: 40),
                      ),
              ),
            ),

            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Category
                  if (product.category != null)
                    Text(
                      product.category!.categoryName,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),

                  const SizedBox(height: 8),

                  // Price
                  Text(
                    '₹${product.price}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Stock Status
                  if (product.stockQuantity > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'In Stock',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Out of Stock',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Action Buttons
                  Row(
                    children: [
                      // Add to Cart
                      Expanded(
                        child: ElevatedButton(
                          onPressed: product.stockQuantity > 0
                              ? onAddToCart
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                          child: const Text('Add to Cart'),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Wishlist Button
                      IconButton(
                        onPressed: onToggleWishlist,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: Icon(
                          isInWishlist ? Icons.favorite : Icons.favorite_border,
                          color: isInWishlist ? Colors.red : Colors.grey[600],
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
    ),
  );
}

class ProductGridCard extends StatelessWidget {
  const ProductGridCard({
    required this.product,
    required this.onTap,
    required this.onAddToCart,
    required this.onToggleWishlist,
    super.key,
    this.isInWishlist = false,
  });
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final VoidCallback onToggleWishlist;
  final bool isInWishlist;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 2,
    margin: const EdgeInsets.all(8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: product.primaryImageUrl != null
                    ? Image.network(
                        product.primaryImageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Icon(Icons.error, color: Colors.red),
                            ),
                      )
                    : const Center(
                        child: Icon(Icons.image, color: Colors.grey, size: 40),
                      ),
              ),
            ),
          ),

          // Product Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  product.productName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Category
                if (product.category != null)
                  Text(
                    product.category!.categoryName,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),

                const SizedBox(height: 8),

                // Price
                Text(
                  '₹${product.price}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),

                const SizedBox(height: 8),

                // Stock Status
                if (product.stockQuantity > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'In Stock',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.green[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Out of Stock',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.red[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // Action Buttons
                Row(
                  children: [
                    // Add to Cart
                    Expanded(
                      child: ElevatedButton(
                        onPressed: product.stockQuantity > 0
                            ? onAddToCart
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Add to Cart',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Wishlist Button
                    IconButton(
                      onPressed: onToggleWishlist,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      icon: Icon(
                        isInWishlist ? Icons.favorite : Icons.favorite_border,
                        color: isInWishlist ? Colors.red : Colors.grey[600],
                        size: 20,
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
