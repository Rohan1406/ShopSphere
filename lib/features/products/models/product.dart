class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final String brand;
  final double rating;
  final int reviewsCount;
  final bool inStock;
  final bool isNewArrival;
  final DateTime? createdAt;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.category = 'general',
    this.brand = 'ShopSphere',
    this.rating = 4.5,
    this.reviewsCount = 120,
    this.inStock = true,
    this.isNewArrival = false,
    this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    DateTime? parsedCreatedAt;
    if (json['createdAt'] != null) {
      if (json['createdAt'] is String) {
        parsedCreatedAt = DateTime.tryParse(json['createdAt'] as String);
      }
    }

    return Product(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      category: (json['category'] as String?) ?? 'general',
      brand: (json['brand'] as String?) ?? 'ShopSphere',
      rating: ((json['rating'] ?? 4.5) as num).toDouble(),
      reviewsCount: ((json['reviewsCount'] ?? json['reviewCount'] ?? 120) as num).toInt(),
      inStock: (json['inStock'] as bool?) ?? true,
      isNewArrival: (json['isNewArrival'] as bool?) ?? false,
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'brand': brand,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'inStock': inStock,
      'isNewArrival': isNewArrival,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  Product copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    String? brand,
    double? rating,
    int? reviewsCount,
    bool? inStock,
    bool? isNewArrival,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      inStock: inStock ?? this.inStock,
      isNewArrival: isNewArrival ?? this.isNewArrival,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          price == other.price &&
          imageUrl == other.imageUrl &&
          category == other.category &&
          brand == other.brand &&
          rating == other.rating &&
          reviewsCount == other.reviewsCount &&
          inStock == other.inStock &&
          isNewArrival == other.isNewArrival;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      price.hashCode ^
      imageUrl.hashCode ^
      category.hashCode ^
      brand.hashCode ^
      rating.hashCode ^
      reviewsCount.hashCode ^
      inStock.hashCode ^
      isNewArrival.hashCode;
}
