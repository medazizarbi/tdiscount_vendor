import 'package:flutter/material.dart';

class Order {
  final String id;
  final String storeId;
  final String customerName;
  final String customerEmail;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;

  Order({
    required this.id,
    required this.storeId,
    required this.customerName,
    required this.customerEmail,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? json['id'] ?? '',
      storeId: json['storeId'] ?? '',
      customerName: json['customerName'] ?? '',
      customerEmail: json['customerEmail'] ?? '',
      items: (json['items'] as List?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'storeId': storeId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'notes': notes,
    };
  }

  // Helper getters
  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  // Updated currency formatting to TND
  String get formattedTotal => '${totalAmount.toStringAsFixed(3)} TND';

  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String get formattedDateTime {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return 'En Attente';
      case 'processing':
        return 'En Cours';
      case 'completed':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }
}

class OrderItem {
  final String itemId; // The _id field from the server
  final dynamic productId; // Can be either String or ProductInfo object
  final int quantity;
  final double price;

  OrderItem({
    required this.itemId,
    required this.productId,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    dynamic productData = json['productId'];
    dynamic parsedProductId;

    // Handle different productId formats from server
    if (productData is Map<String, dynamic>) {
      // Full product info object
      parsedProductId = ProductInfo.fromJson(productData);
    } else if (productData is String) {
      // Just the product ID string
      parsedProductId = productData;
    } else {
      // Fallback
      parsedProductId = '';
    }

    return OrderItem(
      itemId: json['_id'] ?? '',
      productId: parsedProductId,
      quantity: json['quantity'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': itemId,
      'productId': productId is ProductInfo
          ? (productId as ProductInfo).toJson()
          : productId,
      'quantity': quantity,
      'price': price,
    };
  }

  // Helper getters
  String get productName {
    if (productId is ProductInfo) {
      return (productId as ProductInfo).name;
    } else if (productId is String) {
      return 'Product'; // Default name when only ID is available
    }
    return 'Unknown Product';
  }

  String get productIdString {
    if (productId is ProductInfo) {
      return (productId as ProductInfo).id;
    } else if (productId is String) {
      return productId as String;
    }
    return '';
  }

  double get productPrice {
    if (productId is ProductInfo) {
      return (productId as ProductInfo).price;
    }
    return price; // Fallback to order item price
  }

  bool get hasProductDetails => productId is ProductInfo;

  double get subtotal => price * quantity;

  // Updated currency formatting to TND (3 decimal places for TND)
  String get formattedPrice => '${price.toStringAsFixed(3)} TND';
  String get formattedSubtotal => '${subtotal.toStringAsFixed(3)} TND';
}

class ProductInfo {
  final String id;
  final String name;
  final double price;

  ProductInfo({
    required this.id,
    required this.name,
    required this.price,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'price': price,
    };
  }
}
