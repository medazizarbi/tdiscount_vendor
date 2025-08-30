import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/order.dart';
import 'package:tdiscount_vendor/services/auth_services.dart';

class OrderService {
  // API Endpoints from environment with null safety
  static String get baseUrl {
    final url = dotenv.env['BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('BASE_URL not found in environment variables');
    }
    return url;
  }

  static String get ordersEndpoint {
    final endpoint = dotenv.env['ORDERS_ENDPOINT'];
    if (endpoint == null || endpoint.isEmpty) {
      throw Exception('ORDERS_ENDPOINT not found in environment variables');
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

  /// Get all orders with pagination and optional status filter
  Future<Map<String, dynamic>> getOrders({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final headers = await _getHeaders();

      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final uri = Uri.parse('$baseUrl$ordersEndpoint').replace(
        queryParameters: queryParams,
      );

      debugPrint('Fetching orders: $uri');

      final response = await http.get(uri, headers: headers);

      debugPrint('Get orders response status: ${response.statusCode}');
      debugPrint('Get orders response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Parse orders from server response
        final ordersData = data['orders'] as List;
        final orders =
            ordersData.map((orderJson) => Order.fromJson(orderJson)).toList();

        // Parse pagination info
        final pagination = data['pagination'] ?? {};

        return {
          'success': true,
          'orders': orders,
          'pagination': {
            'page': pagination['page'] ?? page,
            'limit': pagination['limit'] ?? limit,
            'total': pagination['total'] ?? orders.length,
            'pages': pagination['pages'] ?? 1,
          },
          'totalOrders': pagination['total'] ?? orders.length,
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
                'Erreur lors du chargement des commandes',
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'Erreur serveur: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      return {
        'success': false,
        'error': 'Erreur réseau: ${e.toString()}',
      };
    }
  }

  /// Get order details by ID
  Future<Map<String, dynamic>> getOrderById(String orderId) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$ordersEndpoint/$orderId');

      debugPrint('Fetching order details: $uri');

      final response = await http.get(uri, headers: headers);

      debugPrint('Get order details response status: ${response.statusCode}');
      debugPrint('Get order details response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final orderData = data['order'] ?? data;
        final order = Order.fromJson(orderData);

        return {
          'success': true,
          'order': order,
        };
      } else if (response.statusCode == 401) {
        await _authService.logout();
        return {
          'success': false,
          'error': 'Non autorisé. Veuillez vous reconnecter.',
          'requiresAuth': true,
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'error': 'Commande introuvable',
        };
      } else {
        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'error': errorData['message'] ??
                'Erreur lors du chargement de la commande',
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'Erreur serveur: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      debugPrint('Error fetching order details: $e');
      return {
        'success': false,
        'error': 'Erreur réseau: ${e.toString()}',
      };
    }
  }

  /// Update order status
  Future<Map<String, dynamic>> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$ordersEndpoint/$orderId/status');

      final body = json.encode({
        'status': status,
      });

      debugPrint('Updating order status: $uri');
      debugPrint('Request body: $body');

      final response = await http.put(uri, headers: headers, body: body);

      debugPrint('Update order status response status: ${response.statusCode}');
      debugPrint('Update order status response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final orderData = data['order'] ?? data;
        final order = Order.fromJson(orderData);

        return {
          'success': true,
          'order': order,
          'message': data['message'] ?? 'Statut de la commande mis à jour',
        };
      } else if (response.statusCode == 401) {
        await _authService.logout();
        return {
          'success': false,
          'error': 'Non autorisé. Veuillez vous reconnecter.',
          'requiresAuth': true,
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'error': 'Commande introuvable',
        };
      } else {
        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'error': errorData['message'] ??
                'Erreur lors de la mise à jour du statut',
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'Erreur serveur: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      debugPrint('Error updating order status: $e');
      return {
        'success': false,
        'error': 'Erreur réseau: ${e.toString()}',
      };
    }
  }

  /// Get order notes
  Future<Map<String, dynamic>> getOrderNotes(String orderId) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$ordersEndpoint/$orderId/notes');

      debugPrint('Fetching order notes: $uri');

      final response = await http.get(uri, headers: headers);

      debugPrint('Get order notes response status: ${response.statusCode}');
      debugPrint('Get order notes response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final notes = data['notes'] ?? [];

        return {
          'success': true,
          'notes': notes,
        };
      } else if (response.statusCode == 401) {
        await _authService.logout();
        return {
          'success': false,
          'error': 'Non autorisé. Veuillez vous reconnecter.',
          'requiresAuth': true,
        };
      } else {
        return {
          'success': false,
          'error': 'Erreur lors du chargement des notes',
        };
      }
    } catch (e) {
      debugPrint('Error fetching order notes: $e');
      return {
        'success': false,
        'error': 'Erreur réseau: ${e.toString()}',
      };
    }
  }

  /// Add order note
  Future<Map<String, dynamic>> addOrderNote({
    required String orderId,
    required String content,
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$ordersEndpoint/$orderId/notes');

      final body = json.encode({
        'content': content,
      });

      debugPrint('Adding order note: $uri');
      debugPrint('Request body: $body');

      final response = await http.post(uri, headers: headers, body: body);

      debugPrint('Add order note response status: ${response.statusCode}');
      debugPrint('Add order note response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);

        return {
          'success': true,
          'note': data['note'] ?? data,
          'message': data['message'] ?? 'Note ajoutée avec succès',
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
            'error':
                errorData['message'] ?? 'Erreur lors de l\'ajout de la note',
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'Erreur serveur: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      debugPrint('Error adding order note: $e');
      return {
        'success': false,
        'error': 'Erreur réseau: ${e.toString()}',
      };
    }
  }
}
