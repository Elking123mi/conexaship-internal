class Product {
  final int? id;
  final String name;
  final String description;
  final double price;
  final double? compareAtPrice;
  final String? sku;
  final int stock;
  final String? category;
  final List<String>? images;
  final bool isActive;
  final double? rating;
  final int? reviewCount;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    this.compareAtPrice,
    this.sku,
    required this.stock,
    this.category,
    this.images,
    this.isActive = true,
    this.rating,
    this.reviewCount,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  bool get isOnSale => compareAtPrice != null && compareAtPrice! > price;
  double get discountPercentage =>
      isOnSale ? ((compareAtPrice! - price) / compareAtPrice! * 100) : 0;
  bool get inStock => stock > 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int?,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      compareAtPrice:
          json['compare_at_price'] != null ? (json['compare_at_price'] as num).toDouble() : null,
      sku: json['sku'],
      stock: json['stock'] ?? 0,
      category: json['category'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      reviewCount: json['review_count'] ?? json['reviewCount'],
      metadata: json['metadata'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'compare_at_price': compareAtPrice,
      'sku': sku,
      'stock': stock,
      'category': category,
      'images': images,
      'is_active': isActive,
      'rating': rating,
      'review_count': reviewCount,
      'metadata': metadata,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
