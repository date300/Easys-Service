import 'package:flutter/foundation.dart';

class ProductVariant {
  final String? color;
  final String? size;
  final double price;
  final int stock;
  final String? sku;

  ProductVariant({
    this.color,
    this.size,
    required this.price,
    required this.stock,
    this.sku,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      color: json['color']?.toString(),
      size: json['size']?.toString(),
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      stock: int.tryParse(json['stock']?.toString() ?? '') ?? 0,
      sku: json['sku']?.toString(),
    );
  }
}

class ProductImage {
  final int id;
  final String imageUrl;
  final int sortOrder;

  ProductImage({
    required this.id,
    required this.imageUrl,
    required this.sortOrder,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] ?? 0,
      imageUrl: json['image_url']?.toString() ?? '',
      sortOrder: json['sort_order'] ?? 0,
    );
  }
}

class ProductModel {
  final String id;
  final String title;
  final String? subtitle;
  final String? description;
  final String image;
  final List<ProductImage> images;
  final List<ProductVariant> variants;
  final double wholesalePrice;
  final double originalPrice;
  final double maxResalePrice;
  final String? category;
  final String? brand;
  final double rating;
  final int reviewCount;
  final int stock;
  final String? status;
  final String? sku;
  final String? slug;
  final int viewCount;
  final String? vendorName;
  final String? businessName;
  final bool isWishlisted;
  final bool isReselling;
  final double myMargin;

  ProductModel({
    required this.id,
    required this.title,
    this.subtitle,
    this.description,
    required this.image,
    this.images = const [],
    this.variants = const [],
    required this.wholesalePrice,
    required this.originalPrice,
    required this.maxResalePrice,
    this.category,
    this.brand,
    required this.rating,
    this.reviewCount = 0,
    required this.stock,
    this.status,
    this.sku,
    this.slug,
    this.viewCount = 0,
    this.vendorName,
    this.businessName,
    this.isWishlisted = false,
    this.isReselling = false,
    this.myMargin = 0,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final price = double.tryParse(json['price']?.toString() ?? '') ?? 0.0;
    final discountPriceStr = json['discount_price']?.toString() ?? '';
    final discountPrice = double.tryParse(discountPriceStr);

    // Handle images from API
    List<ProductImage> imageList = [];
    if (json['images'] != null && json['images'] is List) {
      imageList = (json['images'] as List)
          .map((e) => ProductImage.fromJson(e))
          .toList();
    }

    // Handle variants from API
    List<ProductVariant> variantList = [];
    if (json['variants'] != null && json['variants'] is List) {
      variantList = (json['variants'] as List)
          .map((e) => ProductVariant.fromJson(e))
          .toList();
    }

    // Determine thumbnail
    String thumbnail = json['thumbnail']?.toString() ?? '';
    if (thumbnail.isEmpty && imageList.isNotEmpty) {
      thumbnail = imageList.first.imageUrl;
    }
    final imageUrl = thumbnail.isNotEmpty &&
            (thumbnail.startsWith('http://') || thumbnail.startsWith('https://'))
        ? thumbnail
        : 'https://via.placeholder.com/400?text=No+Image';

    // Calculate wholesale price
    final wholesale = (discountPrice != null && discountPrice > 0 && discountPrice < price)
        ? discountPrice
        : (price > 0 ? price * 0.85 : 0.0);

    return ProductModel(
      id: json['id']?.toString() ?? '',
      title: json['product_name']?.toString() ?? 'Untitled',
      subtitle: json['brand']?.toString(),
      description: json['description']?.toString(),
      image: imageUrl,
      images: imageList,
      variants: variantList,
      wholesalePrice: wholesale,
      originalPrice: price,
      maxResalePrice: price * 1.5,
      category: json['category_id']?.toString(),
      brand: json['brand']?.toString(),
      rating: double.tryParse(json['avg_rating']?.toString() ?? '') ?? 0.0,
      reviewCount: int.tryParse(json['review_count']?.toString() ?? '') ?? 0,
      stock: int.tryParse(json['stock']?.toString() ?? '') ?? 0,
      status: json['status']?.toString(),
      sku: json['sku']?.toString(),
      slug: json['slug']?.toString(),
      viewCount: int.tryParse(json['view_count']?.toString() ?? '') ?? 0,
      vendorName: json['vendor_name']?.toString(),
      businessName: json['business_name']?.toString(),
      isWishlisted: json['is_wishlisted'] == 1 || json['is_wishlisted'] == true,
      isReselling: false,
      myMargin: 0,
    );
  }

  ProductModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? description,
    String? image,
    List<ProductImage>? images,
    List<ProductVariant>? variants,
    double? wholesalePrice,
    double? originalPrice,
    double? maxResalePrice,
    String? category,
    String? brand,
    double? rating,
    int? reviewCount,
    int? stock,
    String? status,
    String? sku,
    String? slug,
    int? viewCount,
    String? vendorName,
    String? businessName,
    bool? isWishlisted,
    bool? isReselling,
    double? myMargin,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      image: image ?? this.image,
      images: images ?? this.images,
      variants: variants ?? this.variants,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      originalPrice: originalPrice ?? this.originalPrice,
      maxResalePrice: maxResalePrice ?? this.maxResalePrice,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      stock: stock ?? this.stock,
      status: status ?? this.status,
      sku: sku ?? this.sku,
      slug: slug ?? this.slug,
      viewCount: viewCount ?? this.viewCount,
      vendorName: vendorName ?? this.vendorName,
      businessName: businessName ?? this.businessName,
      isWishlisted: isWishlisted ?? this.isWishlisted,
      isReselling: isReselling ?? this.isReselling,
      myMargin: myMargin ?? this.myMargin,
    );
  }

  double get myPrice => wholesalePrice + myMargin;
  double get maxMargin => maxResalePrice - wholesalePrice;
  bool get isInStock => stock > 0;
  bool get isLowStock => stock > 0 && stock <= 10;
}
