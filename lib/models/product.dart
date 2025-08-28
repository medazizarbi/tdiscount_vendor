class Product {
  final String id; // MongoDB ObjectId as String
  final String storeId;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final List<String> images;
  final String? category;
  final String status; // 'active', 'inactive', 'out_of_stock'
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.storeId,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    required this.images,
    this.category,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // Computed property to check if product is in stock
  bool get inStock => stock > 0 && status != 'out_of_stock';

  // Computed property to check if product is active
  bool get isActive => status == 'active';

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? json['id'] ?? '', // Handle both _id and id fields
      storeId: json['storeId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] ?? 0,
      images: List<String>.from(json['images'] ?? []),
      category: json['category'],
      status: json['status'] ?? 'active',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'storeId': storeId,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'images': images,
      'category': category,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper method to format price with currency
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  // Copy with method for updating product properties
  Product copyWith({
    String? id,
    String? storeId,
    String? name,
    String? description,
    double? price,
    int? stock,
    List<String>? images,
    String? category,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      images: images ?? this.images,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, stock: $stock, status: $status)';
  }
}
