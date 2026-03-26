class Category {
  Category({
    required this.id,
    required this.categoryName,
    this.bannerImage,
    this.logoImage,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'],
    categoryName: json['category_name'] ?? '',
    bannerImage: json['banner_image'],
    logoImage: json['logo_image'],
  );
  final int id;
  final String categoryName;
  final String? bannerImage;
  final String? logoImage;
}

class ProductMedia {
  ProductMedia({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.isPrimary,
  });

  factory ProductMedia.fromJson(Map<String, dynamic> json) => ProductMedia(
    id: json['id'],
    fileName: json['file_name'] ?? '',
    fileUrl: json['file_url'] ?? '',
    fileType: json['file_type'] ?? 'image',
    isPrimary: json['pivot'] != null && (json['pivot']['is_primary'] == 1),
  );
  final int id;
  final String fileName;
  final String fileUrl;
  final String fileType;
  final bool isPrimary;
}

class Product {
  Product({
    required this.id,
    required this.productCode,
    required this.productName,
    required this.categoryId,
    required this.price,
    required this.stockQuantity,
    required this.media,
    this.description,
    this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final mediaList = json['media'] as List? ?? [];
    return Product(
      id: json['id'],
      productCode: json['product_code'] ?? '',
      productName: json['product_name'] ?? '',
      categoryId: json['category_id'] ?? 0,
      price: json['price']?.toString() ?? '0.00',
      stockQuantity: (json['stock_quantity'] ?? 0).toDouble(),
      description: json['description'],
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
      media: mediaList.map((m) => ProductMedia.fromJson(m)).toList(),
    );
  }
  final int id;
  final String productCode;
  final String productName;
  final int categoryId;
  final String price;
  final double stockQuantity;
  final String? description;
  final Category? category;
  final List<ProductMedia> media;

  String? get primaryImageUrl {
    if (media.isEmpty) {
      return null;
    }
    final primary = media.firstWhere(
      (m) => m.isPrimary,
      orElse: () => media.first,
    );
    return primary.fileUrl;
  }

  int? get primaryMediaId {
    if (media.isEmpty) {
      return null;
    }
    final primary = media.firstWhere(
      (m) => m.isPrimary,
      orElse: () => media.first,
    );
    return primary.id;
  }
}

class DashboardData {
  DashboardData({
    required this.banners,
    required this.categories,
    required this.recentProducts,
    required this.featuredProducts,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final cats = json['categories'] as List? ?? [];
    final recents = json['recent_products'] as List? ?? [];
    final featured = json['featured_products'] as List? ?? [];

    return DashboardData(
      banners: json['banners'] ?? [],
      categories: cats.map((c) => Category.fromJson(c)).toList(),
      recentProducts: recents.map((p) => Product.fromJson(p)).toList(),
      featuredProducts: featured.map((p) => Product.fromJson(p)).toList(),
    );
  }
  final List<dynamic> banners;
  final List<Category> categories;
  final List<Product> recentProducts;
  final List<Product> featuredProducts;
}
