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
