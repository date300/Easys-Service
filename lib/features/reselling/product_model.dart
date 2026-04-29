import 'package:flutter/foundation.dart';

class ProductModel {
  final String id;
  final String title;
  final String subtitle;
  final String image;
  final double wholesalePrice;
  final double originalPrice;
  final double maxResalePrice;
  final String category;
  final double rating;
  final bool isReselling;
  final double myMargin;

  ProductModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.wholesalePrice,
    required this.originalPrice,
    required this.maxResalePrice,
    required this.category,
    required this.rating,
    this.isReselling = false,
    this.myMargin = 0,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final price = double.tryParse(json['price']?.toString() ?? '') ?? 0.0;
    final discountPriceStr = json['discount_price']?.toString() ?? '';
    final discountPrice = double.tryParse(discountPriceStr) ?? 0.0;

    final thumbnail = json['thumbnail']?.toString() ?? '';
    final imageUrl = thumbnail.isNotEmpty &&
            (thumbnail.startsWith('http://') || thumbnail.startsWith('https://'))
        ? thumbnail
        : 'https://via.placeholder.com/400?text=No+Image';

    // Use discount_price as wholesale price if available and lower than regular price,
    // otherwise fall back to 85% of original price
    final wholesale = (discountPrice > 0 && discountPrice < price)
        ? discountPrice
        : (price > 0 ? price * 0.85 : 0.0);

    return ProductModel(
      id: json['id']?.toString() ?? '',
      title: json['product_name']?.toString() ?? 'Untitled',
      subtitle: json['description']?.toString() ?? json['brand']?.toString() ?? '',
      image: imageUrl,
      wholesalePrice: wholesale,
      originalPrice: price,
      maxResalePrice: price * 1.5,
      category: json['brand']?.toString() ?? 'General',
      rating: double.tryParse(json['avg_rating']?.toString() ?? '') ?? 0.0,
      isReselling: false,
      myMargin: 0,
    );
  }

  ProductModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? image,
    double? wholesalePrice,
    double? originalPrice,
    double? maxResalePrice,
    String? category,
    double? rating,
    bool? isReselling,
    double? myMargin,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      image: image ?? this.image,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      originalPrice: originalPrice ?? this.originalPrice,
      maxResalePrice: maxResalePrice ?? this.maxResalePrice,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      isReselling: isReselling ?? this.isReselling,
      myMargin: myMargin ?? this.myMargin,
    );
  }
}
