import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CategoryStyle {
  final String label;
  final IconData icon;
  final Color color;

  CategoryStyle({
    required this.label,
    required this.icon,
    required this.color,
  });
}

final Map<String, CategoryStyle> _categoryStyles = {
  'All': CategoryStyle(label: 'All', icon: CupertinoIcons.square_grid_2x2, color: const Color(0xFF29B6F6)),
  'Smart Watch': CategoryStyle(label: 'Smart Watch', icon: CupertinoIcons.clock, color: const Color(0xFF6366F1)),
  'Neckband': CategoryStyle(label: 'Neckband', icon: CupertinoIcons.headphones, color: const Color(0xFFEC4899)),
  'Airpods': CategoryStyle(label: 'Airpods', icon: CupertinoIcons.music_note, color: const Color(0xFF10B981)),
  'Power Bank': CategoryStyle(label: 'Power Bank', icon: CupertinoIcons.battery_100, color: const Color(0xFFF59E0B)),
  'Earphone': CategoryStyle(label: 'Earphone', icon: CupertinoIcons.mic, color: const Color(0xFF3B82F6)),
  'Electronics': CategoryStyle(label: 'Electronics', icon: CupertinoIcons.device_phone_portrait, color: const Color(0xFF6366F1)),
  'Fashion': CategoryStyle(label: 'Fashion', icon: CupertinoIcons.bag, color: const Color(0xFF10B981)),
  'Audio': CategoryStyle(label: 'Audio', icon: CupertinoIcons.volume_up, color: const Color(0xFFEC4899)),
  'Watches': CategoryStyle(label: 'Watches', icon: CupertinoIcons.clock, color: const Color(0xFFF59E0B)),
  'Home': CategoryStyle(label: 'Home', icon: CupertinoIcons.house, color: const Color(0xFF3B82F6)),
  'Sports': CategoryStyle(label: 'Sports', icon: CupertinoIcons.bolt, color: const Color(0xFFEF4444)),
  'Beauty': CategoryStyle(label: 'Beauty', icon: CupertinoIcons.heart, color: const Color(0xFFD946EF)),
  'Books': CategoryStyle(label: 'Books', icon: CupertinoIcons.book, color: const Color(0xFF8B5CF6)),
  'Toys': CategoryStyle(label: 'Toys', icon: CupertinoIcons.gift, color: const Color(0xFF06B6D4)),
};

CategoryStyle getCategoryStyle(String category) {
  return _categoryStyles[category] ?? CategoryStyle(
    label: category,
    icon: CupertinoIcons.tag,
    color: const Color(0xFF29B6F6),
  );
}

class ProductModel {
  final String id;
  final String title;
  final String? subtitle;
  final String image;
  final double wholesalePrice;
  final double? originalPrice;
  final double maxResalePrice;
  final String category;
  final double rating;
  bool isReselling;
  double myMargin;

  ProductModel({
    required this.id,
    required this.title,
    this.subtitle,
    required this.image,
    required this.wholesalePrice,
    this.originalPrice,
    required this.maxResalePrice,
    required this.category,
    required this.rating,
    this.isReselling = false,
    this.myMargin = 0,
  });

  double get myPrice => wholesalePrice + myMargin;
  double get maxMargin => maxResalePrice - wholesalePrice;
}
