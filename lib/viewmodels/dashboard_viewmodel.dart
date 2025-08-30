import 'package:flutter/foundation.dart';
import '../models/dashboard.dart';
import '../services/dashboard_services.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardService _dashboardService = DashboardService();

  // Loading states
  bool _isLoading = false;
  bool _isStatsLoading = false;
  bool _isTopProductsLoading = false;
  bool _isRecentOrdersLoading = false;
  bool _isSalesChartLoading = false;

  // Data
  DashboardStats? _stats;
  TopProductsResponse? _topProducts;
  RecentOrdersResponse? _recentOrders;
  SalesChartResponse? _salesChart;
  DashboardData? _dashboardData;

  // Error handling
  String? _error;
  bool _hasError = false;
  bool _requiresAuth = false;

  // Period selection
  String _selectedPeriod = 'month';
  final List<String> _availablePeriods = ['day', 'week', 'month', 'year'];

  // Limits for data fetching
  int _topProductsLimit = 5;
  int _recentOrdersLimit = 10;

  // Getters
  bool get isLoading => _isLoading;
  bool get isStatsLoading => _isStatsLoading;
  bool get isTopProductsLoading => _isTopProductsLoading;
  bool get isRecentOrdersLoading => _isRecentOrdersLoading;
  bool get isSalesChartLoading => _isSalesChartLoading;

  DashboardStats? get stats => _stats;
  TopProductsResponse? get topProducts => _topProducts;
  RecentOrdersResponse? get recentOrders => _recentOrders;
  SalesChartResponse? get salesChart => _salesChart;
  DashboardData? get dashboardData => _dashboardData;

  String? get error => _error;
  bool get hasError => _hasError;
  bool get requiresAuth => _requiresAuth;

  String get selectedPeriod => _selectedPeriod;
  List<String> get availablePeriods => _availablePeriods;

  int get topProductsLimit => _topProductsLimit;
  int get recentOrdersLimit => _recentOrdersLimit;

  // Computed properties
  bool get hasData => _stats != null;
  bool get hasTopProducts => _topProducts?.topProducts.isNotEmpty ?? false;
  bool get hasRecentOrders => _recentOrders?.recentOrders.isNotEmpty ?? false;
  bool get hasSalesChart => _salesChart?.salesData.isNotEmpty ?? false;

  // Stats computed properties
  double get totalSales => _stats?.sales.totalSales ?? 0.0;
  int get totalOrders => _stats?.sales.totalOrders ?? 0;
  double get averageOrderValue => _stats?.sales.averageOrderValue ?? 0.0;
  int get totalProducts => _stats?.products.total ?? 0;
  int get activeProducts => _stats?.products.active ?? 0;
  int get inactiveProducts => _stats?.products.inactive ?? 0;

  // Order status counts
  int get pendingOrders => _stats?.orders.byStatus.pending ?? 0;
  int get processingOrders => _stats?.orders.byStatus.processing ?? 0;
  int get completedOrders => _stats?.orders.byStatus.completed ?? 0;
  int get cancelledOrders => _stats?.orders.byStatus.cancelled ?? 0;

  /// Clear error state
  void clearError() {
    _error = null;
    _hasError = false;
    _requiresAuth = false;
    notifyListeners();
  }

  /// Set error state
  void _setError(String error, {bool requiresAuth = false}) {
    _error = error;
    _hasError = true;
    _requiresAuth = requiresAuth;
    notifyListeners();
  }

  /// Change selected period
  void changePeriod(String period) {
    if (_availablePeriods.contains(period) && period != _selectedPeriod) {
      _selectedPeriod = period;
      notifyListeners();
      // Automatically refresh data with new period
      refreshDashboard();
    }
  }

  /// Set limits for data fetching
  void setLimits({int? topProducts, int? recentOrders}) {
    bool changed = false;

    if (topProducts != null && topProducts != _topProductsLimit) {
      _topProductsLimit = topProducts;
      changed = true;
    }

    if (recentOrders != null && recentOrders != _recentOrdersLimit) {
      _recentOrdersLimit = recentOrders;
      changed = true;
    }

    if (changed) {
      notifyListeners();
    }
  }

  /// Load all dashboard data
  Future<void> loadDashboardData() async {
    if (_isLoading) return;

    _isLoading = true;
    clearError();
    notifyListeners();

    try {
      final result = await _dashboardService.getAllDashboardData(
        period: _selectedPeriod,
        topProductsLimit: _topProductsLimit,
        recentOrdersLimit: _recentOrdersLimit,
      );

      if (result['success'] == true) {
        _dashboardData = result['data'] as DashboardData;
        _stats = _dashboardData!.stats;
        _topProducts = _dashboardData!.topProducts;
        _recentOrders = _dashboardData!.recentOrders;
        _salesChart = _dashboardData!.salesChart;
      } else {
        _setError(
          result['error'] ?? 'Erreur lors du chargement des données',
          requiresAuth: result['requiresAuth'] ?? false,
        );
      }
    } catch (e) {
      _setError('Erreur réseau: ${e.toString()}');
      debugPrint('Error loading dashboard data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load dashboard stats only
  Future<void> loadStats() async {
    if (_isStatsLoading) return;

    _isStatsLoading = true;
    clearError();
    notifyListeners();

    try {
      final result = await _dashboardService.getDashboardStats(
        period: _selectedPeriod,
      );

      if (result['success'] == true) {
        _stats = result['stats'] as DashboardStats;
      } else {
        _setError(
          result['error'] ?? 'Erreur lors du chargement des statistiques',
          requiresAuth: result['requiresAuth'] ?? false,
        );
      }
    } catch (e) {
      _setError('Erreur réseau: ${e.toString()}');
      debugPrint('Error loading stats: $e');
    } finally {
      _isStatsLoading = false;
      notifyListeners();
    }
  }

  /// Load top products only
  Future<void> loadTopProducts() async {
    if (_isTopProductsLoading) return;

    _isTopProductsLoading = true;
    clearError();
    notifyListeners();

    try {
      final result = await _dashboardService.getTopProducts(
        limit: _topProductsLimit,
      );

      if (result['success'] == true) {
        _topProducts = result['topProducts'] as TopProductsResponse;
      } else {
        _setError(
          result['error'] ??
              'Erreur lors du chargement des produits populaires',
          requiresAuth: result['requiresAuth'] ?? false,
        );
      }
    } catch (e) {
      _setError('Erreur réseau: ${e.toString()}');
      debugPrint('Error loading top products: $e');
    } finally {
      _isTopProductsLoading = false;
      notifyListeners();
    }
  }

  /// Load recent orders only
  Future<void> loadRecentOrders() async {
    if (_isRecentOrdersLoading) return;

    _isRecentOrdersLoading = true;
    clearError();
    notifyListeners();

    try {
      final result = await _dashboardService.getRecentOrders(
        limit: _recentOrdersLimit,
      );

      if (result['success'] == true) {
        _recentOrders = result['recentOrders'] as RecentOrdersResponse;
      } else {
        _setError(
          result['error'] ?? 'Erreur lors du chargement des commandes récentes',
          requiresAuth: result['requiresAuth'] ?? false,
        );
      }
    } catch (e) {
      _setError('Erreur réseau: ${e.toString()}');
      debugPrint('Error loading recent orders: $e');
    } finally {
      _isRecentOrdersLoading = false;
      notifyListeners();
    }
  }

  /// Load sales chart only
  Future<void> loadSalesChart() async {
    if (_isSalesChartLoading) return;

    _isSalesChartLoading = true;
    clearError();
    notifyListeners();

    try {
      final result = await _dashboardService.getSalesChart(
        period: _selectedPeriod,
      );

      if (result['success'] == true) {
        _salesChart = result['salesChart'] as SalesChartResponse;
      } else {
        _setError(
          result['error'] ??
              'Erreur lors du chargement du graphique des ventes',
          requiresAuth: result['requiresAuth'] ?? false,
        );
      }
    } catch (e) {
      _setError('Erreur réseau: ${e.toString()}');
      debugPrint('Error loading sales chart: $e');
    } finally {
      _isSalesChartLoading = false;
      notifyListeners();
    }
  }

  /// Refresh all dashboard data
  Future<void> refreshDashboard() async {
    clearError();
    await loadDashboardData();
  }

  /// Refresh specific sections
  Future<void> refreshStats() async {
    clearError();
    await loadStats();
  }

  Future<void> refreshTopProducts() async {
    clearError();
    await loadTopProducts();
  }

  Future<void> refreshRecentOrders() async {
    clearError();
    await loadRecentOrders();
  }

  Future<void> refreshSalesChart() async {
    clearError();
    await loadSalesChart();
  }

  /// Test API connection
  Future<bool> testConnection() async {
    try {
      final result = await _dashboardService.testConnection();
      return result['success'] == true;
    } catch (e) {
      debugPrint('Connection test failed: $e');
      return false;
    }
  }

  /// Initialize dashboard (call this when screen loads)
  Future<void> initialize() async {
    debugPrint('Initializing dashboard...');

    // Check if service is configured
    if (!DashboardService.isConfigured()) {
      _setError('Configuration du service dashboard manquante');
      return;
    }

    // Load all data
    await loadDashboardData();
  }

  /// Dispose method to clean up resources
  @override
  void dispose() {
    debugPrint('Disposing DashboardViewModel');
    super.dispose();
  }

  /// Get formatted period display text
  String getPeriodDisplayText(String period) {
    switch (period.toLowerCase()) {
      case 'day':
        return 'Aujourd\'hui';
      case 'week':
        return 'Cette semaine';
      case 'month':
        return 'Ce mois';
      case 'year':
        return 'Cette année';
      default:
        return period.toUpperCase();
    }
  }

  /// Get growth percentage (placeholder - you can implement based on historical data)
  double getGrowthPercentage() {
    // This would typically compare current period with previous period
    // For now, returning a placeholder value
    return 12.5;
  }

  /// Get order completion rate
  double getOrderCompletionRate() {
    final total = totalOrders;
    if (total == 0) return 0.0;
    return (completedOrders / total) * 100;
  }

  /// Get product activity rate
  double getProductActivityRate() {
    final total = totalProducts;
    if (total == 0) return 0.0;
    return (activeProducts / total) * 100;
  }
}
