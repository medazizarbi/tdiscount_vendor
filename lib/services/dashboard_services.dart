import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/dashboard.dart';
import 'auth_services.dart';

class DashboardService {
  // API Endpoints from environment with null safety
  static String get baseUrl {
    final url = dotenv.env['BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('BASE_URL not found in environment variables');
    }
    return url;
  }

  static String get dashboardStatsEndpoint {
    final endpoint = dotenv.env['DASHBOARD_STATS_ENDPOINT'];
    if (endpoint == null || endpoint.isEmpty) {
      throw Exception(
          'DASHBOARD_STATS_ENDPOINT not found in environment variables');
    }
    return endpoint;
  }

  static String get dashboardProductsEndpoint {
    final endpoint = dotenv.env['DASHBOARD_PRODUCTS_ENDPOINT'];
    if (endpoint == null || endpoint.isEmpty) {
      throw Exception(
          'DASHBOARD_PRODUCTS_ENDPOINT not found in environment variables');
    }
    return endpoint;
  }

  static String get dashboardOrdersEndpoint {
    final endpoint = dotenv.env['DASHBOARD_ORDERS_ENDPOINT'];
    if (endpoint == null || endpoint.isEmpty) {
      throw Exception(
          'DASHBOARD_ORDERS_ENDPOINT not found in environment variables');
    }
    return endpoint;
  }

  static String get dashboardSalesChartEndpoint {
    final endpoint = dotenv.env['DASHBOARD_SALES_CHART_ENDPOINT'];
    if (endpoint == null || endpoint.isEmpty) {
      throw Exception(
          'DASHBOARD_SALES_CHART_ENDPOINT not found in environment variables');
    }
    return endpoint;
  }

  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Get dashboard statistics
  /// [period] can be: 'day', 'week', 'month', 'year'
  Future<Map<String, dynamic>> getDashboardStats(
      {String period = 'month'}) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$dashboardStatsEndpoint').replace(
        queryParameters: {'period': period},
      );

      print('Fetching dashboard stats: $uri');

      final response = await http.get(uri, headers: headers);

      print('Dashboard stats response status: ${response.statusCode}');
      print('Dashboard stats response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final stats = DashboardStats.fromJson(data);

        return {
          'success': true,
          'stats': stats,
        };
      } else if (response.statusCode == 401) {
        await _authService.logout();
        return {
          'success': false,
          'error': 'Non autorisé. Veuillez vous reconnecter.',
          'requiresAuth': true,
        };
      } else {
        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'error': errorData['message'] ??
                'Erreur lors du chargement des statistiques',
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'Erreur serveur: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      return {
        'success': false,
        'error': 'Erreur réseau: ${e.toString()}',
      };
    }
  }

  /// Get top products
  /// [limit] number of top products to fetch (default: 5)
  Future<Map<String, dynamic>> getTopProducts({int limit = 5}) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$dashboardProductsEndpoint').replace(
        queryParameters: {
          'limite': limit.toString()
        }, // Note: API uses 'limite' not 'limit'
      );

      print('Fetching top products: $uri');

      final response = await http.get(uri, headers: headers);

      print('Top products response status: ${response.statusCode}');
      print('Top products response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final topProducts = TopProductsResponse.fromJson(data);

        return {
          'success': true,
          'topProducts': topProducts,
        };
      } else if (response.statusCode == 401) {
        await _authService.logout();
        return {
          'success': false,
          'error': 'Non autorisé. Veuillez vous reconnecter.',
          'requiresAuth': true,
        };
      } else {
        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'error': errorData['message'] ??
                'Erreur lors du chargement des produits populaires',
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'Erreur serveur: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      print('Error fetching top products: $e');
      return {
        'success': false,
        'error': 'Erreur réseau: ${e.toString()}',
      };
    }
  }

  /// Get recent orders
  /// [limit] number of recent orders to fetch (default: 5)
  Future<Map<String, dynamic>> getRecentOrders({int limit = 5}) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$dashboardOrdersEndpoint').replace(
        queryParameters: {
          'limite': limit.toString()
        }, // Note: API uses 'limite' not 'limit'
      );

      print('Fetching recent orders: $uri');

      final response = await http.get(uri, headers: headers);

      print('Recent orders response status: ${response.statusCode}');
      print('Recent orders response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final recentOrders = RecentOrdersResponse.fromJson(data);

        return {
          'success': true,
          'recentOrders': recentOrders,
        };
      } else if (response.statusCode == 401) {
        await _authService.logout();
        return {
          'success': false,
          'error': 'Non autorisé. Veuillez vous reconnecter.',
          'requiresAuth': true,
        };
      } else {
        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'error': errorData['message'] ??
                'Erreur lors du chargement des commandes récentes',
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'Erreur serveur: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      print('Error fetching recent orders: $e');
      return {
        'success': false,
        'error': 'Erreur réseau: ${e.toString()}',
      };
    }
  }

  /// Get sales chart data
  /// [period] can be: 'day', 'week', 'month', 'year'
  Future<Map<String, dynamic>> getSalesChart({String period = 'month'}) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$dashboardSalesChartEndpoint').replace(
        queryParameters: {'period': period},
      );

      print('Fetching sales chart: $uri');

      final response = await http.get(uri, headers: headers);

      print('Sales chart response status: ${response.statusCode}');
      print('Sales chart response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final salesChart = SalesChartResponse.fromJson(data);

        return {
          'success': true,
          'salesChart': salesChart,
        };
      } else if (response.statusCode == 401) {
        await _authService.logout();
        return {
          'success': false,
          'error': 'Non autorisé. Veuillez vous reconnecter.',
          'requiresAuth': true,
        };
      } else {
        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'error': errorData['message'] ??
                'Erreur lors du chargement du graphique des ventes',
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'Erreur serveur: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      print('Error fetching sales chart: $e');
      return {
        'success': false,
        'error': 'Erreur réseau: ${e.toString()}',
      };
    }
  }

  /// Get all dashboard data at once
  /// This method fetches all dashboard data in parallel for better performance
  Future<Map<String, dynamic>> getAllDashboardData({
    String period = 'month',
    int topProductsLimit = 5,
    int recentOrdersLimit = 10,
  }) async {
    try {
      print('Fetching all dashboard data for period: $period');

      // Fetch all data in parallel
      final results = await Future.wait([
        getDashboardStats(period: period),
        getTopProducts(limit: topProductsLimit),
        getRecentOrders(limit: recentOrdersLimit),
        getSalesChart(period: period),
      ]);

      // Check if any request failed
      for (var result in results) {
        if (!(result['success'] ?? false)) {
          return {
            'success': false,
            'error': result['error'] ?? 'Erreur lors du chargement des données',
            'requiresAuth': result['requiresAuth'] ?? false,
          };
        }
      }

      return {
        'success': true,
        'data': DashboardData(
          stats: results[0]['stats'] as DashboardStats,
          topProducts: results[1]['topProducts'] as TopProductsResponse,
          recentOrders: results[2]['recentOrders'] as RecentOrdersResponse,
          salesChart: results[3]['salesChart'] as SalesChartResponse,
        ),
      };
    } catch (e) {
      print('Error in getAllDashboardData: $e');
      return {
        'success': false,
        'error': 'Erreur réseau: ${e.toString()}',
      };
    }
  }

  /// Check if the service is properly configured
  static bool isConfigured() {
    try {
      final url = baseUrl;
      final statsEndpoint = dashboardStatsEndpoint;
      final productsEndpoint = dashboardProductsEndpoint;
      final ordersEndpoint = dashboardOrdersEndpoint;
      final salesChartEndpoint = dashboardSalesChartEndpoint;

      return url.isNotEmpty &&
          statsEndpoint.isNotEmpty &&
          productsEndpoint.isNotEmpty &&
          ordersEndpoint.isNotEmpty &&
          salesChartEndpoint.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Test API connection
  Future<Map<String, dynamic>> testConnection() async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$dashboardStatsEndpoint').replace(
        queryParameters: {'period': 'day'},
      );

      final response = await http.get(uri, headers: headers).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Connexion API réussie',
        };
      } else {
        return {
          'success': false,
          'error': 'Échec de la connexion API: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Connection test failed: $e');
      return {
        'success': false,
        'error': 'Test de connexion échoué: ${e.toString()}',
      };
    }
  }
}

/// Combined dashboard data class for easier state management
class DashboardData {
  final DashboardStats stats;
  final TopProductsResponse topProducts;
  final RecentOrdersResponse recentOrders;
  final SalesChartResponse salesChart;

  DashboardData({
    required this.stats,
    required this.topProducts,
    required this.recentOrders,
    required this.salesChart,
  });
}
