class Product {
  final int id;
  final String name;
  final String price;
  final String? regularPrice;
  final String? description;
  final String? shortDescription;
  final List<String> imageUrls;
  final bool inStock;
  final String? sku;
  final List<int> relatedIds;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.regularPrice,
    this.description,
    this.shortDescription,
    required this.imageUrls,
    required this.inStock,
    this.sku,
    required this.relatedIds,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      regularPrice: json['regular_price'],
      description: json['description'],
      shortDescription: json['short_description'],
      imageUrls: (json['images'] as List<dynamic>?)
              ?.map((img) => img['src'] as String)
              .toList() ??
          [],
      inStock: json['stock_status'] == 'instock',
      sku: json['sku'] as String?,
      relatedIds: (json['related_ids'] as List<dynamic>?)
              ?.map((id) => id as int)
              .toList() ??
          [],
    );
  }

  // Static list of products
  static final List<Product> staticProducts = [
    Product(
      id: 1,
      name: 'Wireless Headphones',
      price: '\$89.99',
      regularPrice: '\$99.99',
      description: 'High-quality wireless headphones with noise cancellation',
      shortDescription: 'Wireless headphones with noise cancellation',
      imageUrls: [
        'https://tdiscount.tn/wp-content/uploads/2025/03/tv-condor-50-smart-ultra-hd-4k-1-1.webp',
        'https://tdiscount.tn/wp-content/uploads/2024/12/objectif-canon-ef-24-105mm-f4l-is-ii-usm.png',
      ],
      inStock: true,
      sku: 'WH001',
      relatedIds: [2, 3],
    ),
    Product(
      id: 2,
      name: 'Bluetooth Speaker',
      price: '\$75.38',
      regularPrice: '\$85.00',
      description: 'Portable Bluetooth speaker with excellent sound quality',
      shortDescription: 'Portable Bluetooth speaker',
      imageUrls: [
        'https://tdiscount.tn/wp-content/uploads/2024/12/appareil-photo-hybride-eos-r10-objectif-rf-s-18-45-mm.png',
        'https://tdiscount.tn/wp-content/uploads/2025/03/tv-condor-50-smart-ultra-hd-4k-1-1.webp',
      ],
      inStock: true,
      sku: 'BS001',
      relatedIds: [1, 4],
    ),
    Product(
      id: 3,
      name: 'Phone Case',
      price: '\$25.50',
      regularPrice: '\$30.00',
      description: 'Protective phone case with shockproof design',
      shortDescription: 'Protective phone case',
      imageUrls: [
        'https://tdiscount.tn/wp-content/uploads/2024/12/objectif-canon-ef-24-105mm-f4l-is-ii-usm.png',
        'https://tdiscount.tn/wp-content/uploads/2024/12/appareil-photo-hybride-eos-r10-objectif-rf-s-18-45-mm.png',
        'https://tdiscount.tn/wp-content/uploads/2025/03/tv-condor-50-smart-ultra-hd-4k-1-1.webp',
      ],
      inStock: true,
      sku: 'PC001',
      relatedIds: [1, 5],
    ),
    Product(
      id: 4,
      name: 'Laptop Stand',
      price: '\$99.00',
      regularPrice: '\$120.00',
      description: 'Adjustable laptop stand for better ergonomics',
      shortDescription: 'Adjustable laptop stand',
      imageUrls: [
        'https://tdiscount.tn/wp-content/uploads/2025/03/tv-condor-50-smart-ultra-hd-4k-1-1.webp',
        'https://tdiscount.tn/wp-content/uploads/2024/12/objectif-canon-ef-24-105mm-f4l-is-ii-usm.png',
      ],
      inStock: true,
      sku: 'LS001',
      relatedIds: [5, 6],
    ),
    Product(
      id: 5,
      name: 'USB Cable',
      price: '\$25.00',
      regularPrice: '\$30.00',
      description: 'High-speed USB cable for data transfer and charging',
      shortDescription: 'High-speed USB cable',
      imageUrls: [
        'https://tdiscount.tn/wp-content/uploads/2024/12/appareil-photo-hybride-eos-r10-objectif-rf-s-18-45-mm.png',
        'https://tdiscount.tn/wp-content/uploads/2025/03/tv-condor-50-smart-ultra-hd-4k-1-1.webp',
      ],
      inStock: true,
      sku: 'UC001',
      relatedIds: [4, 7],
    ),
    Product(
      id: 6,
      name: 'Gaming Mouse',
      price: '\$75.25',
      regularPrice: '\$85.00',
      description: 'High-precision gaming mouse with RGB lighting',
      shortDescription: 'High-precision gaming mouse',
      imageUrls: [
        'https://tdiscount.tn/wp-content/uploads/2024/12/objectif-canon-ef-24-105mm-f4l-is-ii-usm.png',
        'https://tdiscount.tn/wp-content/uploads/2024/12/appareil-photo-hybride-eos-r10-objectif-rf-s-18-45-mm.png',
      ],
      inStock: true,
      sku: 'GM001',
      relatedIds: [7, 8],
    ),
    Product(
      id: 7,
      name: 'Tablet',
      price: '\$300.00',
      regularPrice: '\$350.00',
      description: '10-inch tablet with high-resolution display',
      shortDescription: '10-inch tablet',
      imageUrls: [
        'https://tdiscount.tn/wp-content/uploads/2025/03/tv-condor-50-smart-ultra-hd-4k-1-1.webp',
        'https://tdiscount.tn/wp-content/uploads/2024/12/appareil-photo-hybride-eos-r10-objectif-rf-s-18-45-mm.png',
        'https://tdiscount.tn/wp-content/uploads/2024/12/objectif-canon-ef-24-105mm-f4l-is-ii-usm.png',
      ],
      inStock: true,
      sku: 'TB001',
      relatedIds: [8, 9],
    ),
    Product(
      id: 8,
      name: 'Screen Protector',
      price: '\$20.00',
      regularPrice: '\$25.00',
      description: 'Tempered glass screen protector',
      shortDescription: 'Tempered glass screen protector',
      imageUrls: [
        'https://tdiscount.tn/wp-content/uploads/2024/12/appareil-photo-hybride-eos-r10-objectif-rf-s-18-45-mm.png',
        'https://tdiscount.tn/wp-content/uploads/2025/03/tv-condor-50-smart-ultra-hd-4k-1-1.webp',
      ],
      inStock: true,
      sku: 'SP001',
      relatedIds: [7, 10],
    ),
    Product(
      id: 9,
      name: 'Phone Charger',
      price: '\$25.99',
      regularPrice: '\$30.00',
      description: 'Fast charging phone charger',
      shortDescription: 'Fast charging phone charger',
      imageUrls: [
        'https://tdiscount.tn/wp-content/uploads/2024/12/objectif-canon-ef-24-105mm-f4l-is-ii-usm.png',
        'https://tdiscount.tn/wp-content/uploads/2024/12/appareil-photo-hybride-eos-r10-objectif-rf-s-18-45-mm.png',
      ],
      inStock: true,
      sku: 'PCH001',
      relatedIds: [10, 1],
    ),
    Product(
      id: 10,
      name: 'Earbuds',
      price: '\$20.00',
      regularPrice: '\$25.00',
      description: 'Wireless earbuds with charging case',
      shortDescription: 'Wireless earbuds',
      imageUrls: [
        'https://tdiscount.tn/wp-content/uploads/2025/03/tv-condor-50-smart-ultra-hd-4k-1-1.webp',
        'https://tdiscount.tn/wp-content/uploads/2024/12/objectif-canon-ef-24-105mm-f4l-is-ii-usm.png',
        'https://tdiscount.tn/wp-content/uploads/2024/12/appareil-photo-hybride-eos-r10-objectif-rf-s-18-45-mm.png',
      ],
      inStock: true,
      sku: 'EB001',
      relatedIds: [1, 2],
    ),
  ];

  // Helper method to get product by ID
  static Product? getProductById(int id) {
    try {
      return staticProducts.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }
}
