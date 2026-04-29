class ProductModel {
  final int id;
  final int userId;
  final int businessId;
  final String productName;
  final String slug;
  final String brand;
  final double price;
  final double? discountPrice;
  final int categoryId;
  final String description;
  final int stock;
  final String sku;
  final String status;
  final String? thumbnail;
  final double avgRating;
  final int reviewCount;
  final int viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  bool isReselling;

  ProductModel({
    required this.id,
    required this.userId,
    required this.businessId,
    required this.productName,
    required this.slug,
    required this.brand,
    required this.price,
    this.discountPrice,
    required this.categoryId,
    required this.description,
    required this.stock,
    required this.sku,
    required this.status,
    this.thumbnail,
    required this.avgRating,
    required this.reviewCount,
    required this.viewCount,
    required this.createdAt,
    required this.updatedAt,
    this.isReselling = false,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      businessId: json['business_id'] ?? 0,
      productName: json['product_name'] ?? 'Unknown',
      slug: json['slug'] ?? '',
      brand: json['brand'] ?? 'Generic',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      discountPrice: json['discount_price'] != null ? double.tryParse(json['discount_price'].toString()) : null,
      categoryId: json['category_id'] ?? 0,
      description: json['description'] ?? '',
      stock: json['stock'] ?? 0,
      sku: json['sku'] ?? '',
      status: json['status'] ?? 'active',
      thumbnail: json['thumbnail'],
      avgRating: double.tryParse(json['avg_rating'].toString()) ?? 0.0,
      reviewCount: json['review_count'] ?? 0,
      viewCount: json['view_count'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'business_id': businessId,
      'product_name': productName,
      'slug': slug,
      'brand': brand,
      'price': price,
      'discount_price': discountPrice,
      'category_id': categoryId,
      'description': description,
      'stock': stock,
      'sku': sku,
      'status': status,
      'thumbnail': thumbnail,
      'avg_rating': avgRating,
      'review_count': reviewCount,
      'view_count': viewCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper getters
  String get imageUrl => thumbnail ?? 'https://via.placeholder.com/300?text=No+Image';
  String get category => 'Products';
  double get rating => avgRating;
  double get discountPercentage => discountPrice != null ? ((price - discountPrice!) / price * 100) : 0;
  bool get isInStock => stock > 0;
}
