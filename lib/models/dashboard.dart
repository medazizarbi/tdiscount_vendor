class DashboardStats {
  final String period;
  final DateRange dateRange;
  final SalesData sales;
  final OrdersData orders;
  final ProductsData products;

  DashboardStats({
    required this.period,
    required this.dateRange,
    required this.sales,
    required this.orders,
    required this.products,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      period: json['period'] ?? '',
      dateRange: DateRange.fromJson(json['dateRange'] ?? {}),
      sales: SalesData.fromJson(json['sales'] ?? {}),
      orders: OrdersData.fromJson(json['orders'] ?? {}),
      products: ProductsData.fromJson(json['products'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'dateRange': dateRange.toJson(),
      'sales': sales.toJson(),
      'orders': orders.toJson(),
      'products': products.toJson(),
    };
  }
}

class DateRange {
  final DateTime startDate;
  final DateTime endDate;

  DateRange({
    required this.startDate,
    required this.endDate,
  });

  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      startDate:
          DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate:
          DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}

class SalesData {
  final double totalSales;
  final int totalOrders;
  final double averageOrderValue;

  SalesData({
    required this.totalSales,
    required this.totalOrders,
    required this.averageOrderValue,
  });

  factory SalesData.fromJson(Map<String, dynamic> json) {
    return SalesData(
      totalSales: (json['totalSales'] ?? 0).toDouble(),
      totalOrders: json['totalOrders'] ?? 0,
      averageOrderValue: (json['averageOrderValue'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSales': totalSales,
      'totalOrders': totalOrders,
      'averageOrderValue': averageOrderValue,
    };
  }
}

class OrdersData {
  final int total;
  final OrdersByStatus byStatus;

  OrdersData({
    required this.total,
    required this.byStatus,
  });

  factory OrdersData.fromJson(Map<String, dynamic> json) {
    return OrdersData(
      total: json['total'] ?? 0,
      byStatus: OrdersByStatus.fromJson(json['byStatus'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'byStatus': byStatus.toJson(),
    };
  }
}

class OrdersByStatus {
  final int completed;
  final int cancelled;
  final int pending;
  final int processing;

  OrdersByStatus({
    required this.completed,
    required this.cancelled,
    this.pending = 0,
    this.processing = 0,
  });

  factory OrdersByStatus.fromJson(Map<String, dynamic> json) {
    return OrdersByStatus(
      completed: json['completed'] ?? 0,
      cancelled: json['cancelled'] ?? 0,
      pending: json['pending'] ?? 0,
      processing: json['processing'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completed': completed,
      'cancelled': cancelled,
      'pending': pending,
      'processing': processing,
    };
  }
}

class ProductsData {
  final int total;
  final int active;
  final int inactive;

  ProductsData({
    required this.total,
    required this.active,
    required this.inactive,
  });

  factory ProductsData.fromJson(Map<String, dynamic> json) {
    return ProductsData(
      total: json['total'] ?? 0,
      active: json['active'] ?? 0,
      inactive: json['inactive'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'active': active,
      'inactive': inactive,
    };
  }
}

// Top Products Response Model
class TopProductsResponse {
  final List<TopProduct> topProducts;

  TopProductsResponse({
    required this.topProducts,
  });

  factory TopProductsResponse.fromJson(Map<String, dynamic> json) {
    return TopProductsResponse(
      topProducts: (json['topProducts'] as List<dynamic>? ?? [])
          .map((item) => TopProduct.fromJson(item))
          .toList(),
    );
  }
}

class TopProduct {
  final String id;
  final String name;
  final String category;
  final double price;
  final int totalSold;
  final double totalRevenue;

  TopProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.totalSold,
    required this.totalRevenue,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      totalSold: json['totalSold'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'category': category,
      'price': price,
      'totalSold': totalSold,
      'totalRevenue': totalRevenue,
    };
  }
}

// Recent Orders Response Model
class RecentOrdersResponse {
  final List<RecentOrder> recentOrders;

  RecentOrdersResponse({
    required this.recentOrders,
  });

  factory RecentOrdersResponse.fromJson(Map<String, dynamic> json) {
    return RecentOrdersResponse(
      recentOrders: (json['recentOrders'] as List<dynamic>? ?? [])
          .map((item) => RecentOrder.fromJson(item))
          .toList(),
    );
  }
}

class RecentOrder {
  final String id;
  final String customerName;
  final String customerEmail;
  final double totalAmount;
  final String status;
  final DateTime createdAt;

  RecentOrder({
    required this.id,
    required this.customerName,
    required this.customerEmail,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  factory RecentOrder.fromJson(Map<String, dynamic> json) {
    return RecentOrder(
      id: json['_id'] ?? '',
      customerName: json['customerName'] ?? '',
      customerEmail: json['customerEmail'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// Sales Chart Response Model
class SalesChartResponse {
  final List<SalesChartData> salesData;
  final String period;

  SalesChartResponse({
    required this.salesData,
    required this.period,
  });

  factory SalesChartResponse.fromJson(Map<String, dynamic> json) {
    return SalesChartResponse(
      salesData: (json['salesData'] as List<dynamic>? ?? [])
          .map((item) => SalesChartData.fromJson(item))
          .toList(),
      period: json['period'] ?? '',
    );
  }
}

class SalesChartData {
  final String date; // This is the _id field from API (date string)
  final double totalSales;
  final int orderCount;

  SalesChartData({
    required this.date,
    required this.totalSales,
    required this.orderCount,
  });

  factory SalesChartData.fromJson(Map<String, dynamic> json) {
    return SalesChartData(
      date: json['_id'] ?? '',
      totalSales: (json['totalSales'] ?? 0).toDouble(),
      orderCount: json['orderCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': date,
      'totalSales': totalSales,
      'orderCount': orderCount,
    };
  }

  // Helper method to get DateTime from date string
  DateTime get dateTime {
    try {
      return DateTime.parse(date);
    } catch (e) {
      return DateTime.now();
    }
  }
}
