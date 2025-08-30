import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../services/order_services.dart';

class OrderViewModel extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  // State variables
  List<Order> _orders = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  // Pagination
  int _currentPage = 1;
  bool _hasMoreOrders = true;
  int _totalOrders = 0;
  Map<String, dynamic> _pagination = {};

  // Filters
  String? _selectedStatus;

  // Getters
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  int get currentPage => _currentPage;
  bool get hasMoreOrders => _hasMoreOrders;
  int get totalOrders => _totalOrders;
  Map<String, dynamic> get pagination => _pagination;
  String? get selectedStatus => _selectedStatus;

  // Filter getters
  List<Order> get pendingOrders =>
      _orders.where((order) => order.isPending).toList();
  List<Order> get processingOrders =>
      _orders.where((order) => order.isProcessing).toList();
  List<Order> get completedOrders =>
      _orders.where((order) => order.isCompleted).toList();
  List<Order> get cancelledOrders =>
      _orders.where((order) => order.isCancelled).toList();

  // Statistics with TND formatting
  int get pendingCount => pendingOrders.length;
  int get processingCount => processingOrders.length;
  int get completedCount => completedOrders.length;
  int get cancelledCount => cancelledOrders.length;

  // Revenue calculations
  double get totalRevenue =>
      completedOrders.fold(0.0, (sum, order) => sum + order.totalAmount);

  double get pendingRevenue =>
      pendingOrders.fold(0.0, (sum, order) => sum + order.totalAmount);

  double get processingRevenue =>
      processingOrders.fold(0.0, (sum, order) => sum + order.totalAmount);

  double get cancelledRevenue =>
      cancelledOrders.fold(0.0, (sum, order) => sum + order.totalAmount);

  // Formatted revenue strings with TND
  String get formattedTotalRevenue => '${totalRevenue.toStringAsFixed(3)} TND';
  String get formattedPendingRevenue =>
      '${pendingRevenue.toStringAsFixed(3)} TND';
  String get formattedProcessingRevenue =>
      '${processingRevenue.toStringAsFixed(3)} TND';
  String get formattedCancelledRevenue =>
      '${cancelledRevenue.toStringAsFixed(3)} TND';

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setLoadingMore(bool loading) {
    _isLoadingMore = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Initialize orders - call this when screen loads
  Future<void> initializeOrders() async {
    if (_orders.isEmpty) {
      await loadOrders(refresh: true);
    }
  }

  /// Load orders with pagination
  Future<void> loadOrders({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _orders.clear();
      _hasMoreOrders = true;
      setError(null);
    }

    if (_isLoading || _isLoadingMore || !_hasMoreOrders) return;

    if (_currentPage == 1) {
      setLoading(true);
    } else {
      setLoadingMore(true);
    }

    try {
      final result = await _orderService.getOrders(
        page: _currentPage,
        limit: 10,
        status: _selectedStatus,
      );

      if (result['success'] == true) {
        final newOrders = result['orders'] as List<Order>;

        if (refresh) {
          _orders = newOrders;
        } else {
          _orders.addAll(newOrders);
        }

        _totalOrders = result['totalOrders'] ?? _orders.length;
        _pagination = result['pagination'] ?? {};

        // Check if there are more orders to load
        final currentPage = _pagination['page'] ?? _currentPage;
        final totalPages = _pagination['pages'] ?? 1;
        _hasMoreOrders = currentPage < totalPages;

        _currentPage++;

        setError(null);
      } else {
        setError(result['error'] ?? 'Erreur lors du chargement des commandes');
      }
    } catch (e) {
      setError('Erreur: ${e.toString()}');
    } finally {
      setLoading(false);
      setLoadingMore(false);
    }
  }

  /// Refresh orders
  Future<void> refreshOrders() async {
    await loadOrders(refresh: true);
  }

  /// Load more orders
  Future<void> loadMoreOrders() async {
    await loadOrders(refresh: false);
  }

  /// Apply filters
  Future<void> applyFilters({String? status}) async {
    _selectedStatus = status;
    await loadOrders(refresh: true);
  }

  /// Clear filters
  Future<void> clearFilters() async {
    _selectedStatus = null;
    await loadOrders(refresh: true);
  }

  /// Update order status
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final result = await _orderService.updateOrderStatus(
        orderId: orderId,
        status: newStatus,
      );

      if (result['success'] == true) {
        // Update the order in the list
        final updatedOrder = result['order'] as Order;
        final index = _orders.indexWhere((order) => order.id == orderId);
        if (index != -1) {
          _orders[index] = updatedOrder;
          notifyListeners();
        }
        return true;
      } else {
        setError(result['error'] ?? 'Erreur lors de la mise à jour du statut');
        return false;
      }
    } catch (e) {
      setError('Erreur: ${e.toString()}');
      return false;
    }
  }

  /// Get order by ID from current list
  Order? getOrderFromList(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  /// Get order by ID (from API if not in current list)
  Future<Order?> getOrderById(String orderId) async {
    // First check if order exists in current list
    final existingOrder = getOrderFromList(orderId);
    if (existingOrder != null) {
      return existingOrder;
    }

    // If not in current list, fetch from API
    try {
      final result = await _orderService.getOrderById(orderId);

      if (result['success'] == true) {
        return result['order'] as Order;
      } else {
        setError(result['error'] ?? 'Erreur lors du chargement de la commande');
        return null;
      }
    } catch (e) {
      setError('Erreur: ${e.toString()}');
      return null;
    }
  }

  /// Get order notes by ID
  Future<Map<String, dynamic>> getOrderNotes(String orderId) async {
    try {
      final result = await _orderService.getOrderNotes(orderId);

      if (result['success'] == true) {
        return {
          'success': true,
          'notes': result['notes'],
        };
      } else {
        setError(result['error'] ?? 'Erreur lors du chargement des notes');
        return {
          'success': false,
          'error': result['error'] ?? 'Erreur lors du chargement des notes',
          'requiresAuth': result['requiresAuth'] ?? false,
        };
      }
    } catch (e) {
      setError('Erreur: ${e.toString()}');
      return {
        'success': false,
        'error': 'Erreur: ${e.toString()}',
      };
    }
  }

  /// Check if should load more (for infinite scroll)
  bool shouldLoadMore(double currentScrollPosition, double maxScrollExtent) {
    const threshold = 200.0; // pixels from bottom
    return !_isLoading &&
        !_isLoadingMore &&
        _hasMoreOrders &&
        currentScrollPosition >= maxScrollExtent - threshold;
  }

  /// Get orders by status
  List<Order> getOrdersByStatus(String status) {
    return _orders.where((order) => order.status == status).toList();
  }

  /// Get recent orders (last 7 days)
  List<Order> get recentOrders {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return _orders.where((order) => order.createdAt.isAfter(weekAgo)).toList();
  }

  /// Get today's orders
  List<Order> get todaysOrders {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _orders
        .where((order) =>
            order.createdAt.isAfter(today) &&
            order.createdAt.isBefore(tomorrow))
        .toList();
  }

  /// Get today's revenue
  double get todaysRevenue {
    return todaysOrders.fold(0.0, (sum, order) => sum + order.totalAmount);
  }

  // Updated to use TND formatting
  String get formattedTodaysRevenue =>
      '${todaysRevenue.toStringAsFixed(3)} TND';

  /// Get this week's revenue
  double get weeklyRevenue {
    return recentOrders.fold(0.0, (sum, order) => sum + order.totalAmount);
  }

  String get formattedWeeklyRevenue =>
      '${weeklyRevenue.toStringAsFixed(3)} TND';

  /// Get this month's revenue
  double get monthlyRevenue {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

    return _orders
        .where((order) =>
            order.createdAt.isAfter(firstDayOfMonth) &&
            order.status == 'completed')
        .fold(0.0, (sum, order) => sum + order.totalAmount);
  }

  String get formattedMonthlyRevenue =>
      '${monthlyRevenue.toStringAsFixed(3)} TND';

  /// Get average order value
  double get averageOrderValue {
    if (completedOrders.isEmpty) return 0.0;
    return totalRevenue / completedOrders.length;
  }

  String get formattedAverageOrderValue =>
      '${averageOrderValue.toStringAsFixed(3)} TND';

  /// Search orders by customer name or email
  List<Order> searchOrders(String query) {
    if (query.isEmpty) return _orders;

    final lowerQuery = query.toLowerCase();
    return _orders
        .where((order) =>
            order.customerName.toLowerCase().contains(lowerQuery) ||
            order.customerEmail.toLowerCase().contains(lowerQuery) ||
            order.id.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Sort orders
  void sortOrders(String sortBy, {bool ascending = true}) {
    switch (sortBy) {
      case 'date':
        _orders.sort((a, b) => ascending
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt));
        break;
      case 'total':
        _orders.sort((a, b) => ascending
            ? a.totalAmount.compareTo(b.totalAmount)
            : b.totalAmount.compareTo(a.totalAmount));
        break;
      case 'customer':
        _orders.sort((a, b) => ascending
            ? a.customerName.compareTo(b.customerName)
            : b.customerName.compareTo(a.customerName));
        break;
      case 'status':
        _orders.sort((a, b) => ascending
            ? a.status.compareTo(b.status)
            : b.status.compareTo(a.status));
        break;
    }
    notifyListeners();
  }

  /// Get order count by status
  Map<String, int> get orderCountByStatus {
    return {
      'pending': pendingCount,
      'processing': processingCount,
      'completed': completedCount,
      'cancelled': cancelledCount,
    };
  }

  /// Get revenue by status with TND formatting
  Map<String, double> get revenueByStatus {
    return {
      'pending': pendingRevenue,
      'processing': processingRevenue,
      'completed': totalRevenue,
      'cancelled': cancelledRevenue,
    };
  }

  /// Get formatted revenue by status
  Map<String, String> get formattedRevenueByStatus {
    return {
      'pending': formattedPendingRevenue,
      'processing': formattedProcessingRevenue,
      'completed': formattedTotalRevenue,
      'cancelled': formattedCancelledRevenue,
    };
  }

  /// Get top customers by order count
  Map<String, int> get topCustomersByOrderCount {
    final customerOrderCount = <String, int>{};

    for (final order in _orders) {
      customerOrderCount[order.customerName] =
          (customerOrderCount[order.customerName] ?? 0) + 1;
    }

    // Sort by order count and return top 5
    final sortedCustomers = customerOrderCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedCustomers.take(5));
  }

  /// Get top customers by revenue
  Map<String, double> get topCustomersByRevenue {
    final customerRevenue = <String, double>{};

    for (final order in completedOrders) {
      customerRevenue[order.customerName] =
          (customerRevenue[order.customerName] ?? 0.0) + order.totalAmount;
    }

    // Sort by revenue and return top 5
    final sortedCustomers = customerRevenue.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedCustomers.take(5));
  }

  /// Get formatted top customers by revenue
  Map<String, String> get formattedTopCustomersByRevenue {
    final topCustomers = topCustomersByRevenue;
    return topCustomers.map(
        (name, revenue) => MapEntry(name, '${revenue.toStringAsFixed(3)} TND'));
  }

  /// Get daily revenue for the last 7 days
  Map<DateTime, double> get dailyRevenueLastWeek {
    final now = DateTime.now();
    final dailyRevenue = <DateTime, double>{};

    for (int i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day - i);
      final nextDay = day.add(const Duration(days: 1));

      final dayRevenue = completedOrders
          .where((order) =>
              order.createdAt.isAfter(day) && order.createdAt.isBefore(nextDay))
          .fold(0.0, (sum, order) => sum + order.totalAmount);

      dailyRevenue[day] = dayRevenue;
    }

    return dailyRevenue;
  }

  /// Format currency amount
  String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(3)} TND';
  }

  /// Clear orders (useful for logout)
  void clearOrders() {
    _orders.clear();
    _currentPage = 1;
    _hasMoreOrders = true;
    _totalOrders = 0;
    _pagination = {};
    _selectedStatus = null;
    setError(null);
    notifyListeners();
  }

  /// Dispose resources
  @override
  void dispose() {
    clearOrders();
    super.dispose();
  }
}
