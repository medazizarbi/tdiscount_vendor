import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/product.dart';
import 'auth_services.dart';

class ProductService {
  final AuthService _authService = AuthService();

  // API Endpoints from environment with null safety
  static String get baseUrl {
    final url = dotenv.env['BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('BASE_URL not found in environment variables');
    }
    return url;
  }

  static String get productsEndpoint {
    final endpoint = dotenv.env['PRODUCTS_ENDPOINT'];
    if (endpoint == null || endpoint.isEmpty) {
      throw Exception('PRODUCTS_ENDPOINT not found in environment variables');
    }
    return endpoint;
  }

  // Get authorization headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Get all products with pagination and filters
  Future<Map<String, dynamic>> getAllProducts({
    int page = 1,
    int limit = 10,
    String? category,
    String? status,
    String? search,
  }) async {
    try {
      final headers = await _getHeaders();

      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse('$baseUrl$productsEndpoint')
          .replace(queryParameters: queryParams);

      debugPrint('Fetching products: $uri');

      final response = await http.get(uri, headers: headers);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Handle the actual API response format
        final List<dynamic> productsJson = data['products'] ?? [];
        final pagination = data['pagination'] ?? {};

        final List<Product> products =
            productsJson.map((json) => Product.fromJson(json)).toList();

        final currentPage = pagination['page'] ?? page;
        final totalPages = pagination['pages'] ?? 1;
        final totalProducts = pagination['total'] ?? 0;

        return {
          'success': true,
          'products': products,
          'currentPage': currentPage,
          'totalPages': totalPages,
          'totalProducts': totalProducts,
          'hasMore': currentPage < totalPages,
        };
      } else if (response.statusCode == 401) {
        await _authService.logout();
        return {
          'success': false,
          'error': 'Unauthorized. Please login again.',
          'requiresAuth': true,
        };
      } else {
        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'error': errorData['message'] ?? 'Failed to fetch products',
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'Server error: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');

      // Check if it's an environment variable error
      if (e.toString().contains('not found in environment variables')) {
        return {
          'success': false,
          'error': 'Configuration error: ${e.toString()}',
        };
      }

      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Get a single product by ID
  Future<Map<String, dynamic>> getProduct(String productId) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$productsEndpoint/$productId');

      debugPrint('Fetching product: $uri');

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Assuming single product response is just the product object
        // Adjust based on your actual API response format
        final product = Product.fromJson(data);
        return {
          'success': true,
          'product': product,
        };
      } else if (response.statusCode == 401) {
        await _authService.logout();
        return {
          'success': false,
          'error': 'Unauthorized. Please login again.',
          'requiresAuth': true,
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'error': 'Product not found',
        };
      } else {
        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'error': errorData['message'] ?? 'Failed to fetch product',
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'Server error: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      debugPrint('Error fetching product: $e');
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Add a new product
  Future<Map<String, dynamic>> addProduct({
    required String name,
    required double price,
    required int stock,
    String? description,
    String? category,
    List<String>? images,
    String status = 'active', // Default to 'active', but can be overridden
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$productsEndpoint');

      final body = json.encode({
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'category': category,
        'images': images ?? [],
        'status': status, // This will be 'active' or 'inactive'
      });

      debugPrint('Adding product: $body');

      final response = await http.post(uri, headers: headers, body: body);

      print('Add product response status: ${response.statusCode}');
      print('Add product response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);

        // Handle the response structure - the product is nested under 'product' key
        final productData = data['product'] ??
            data; // Fallback to data if 'product' key doesn't exist
        final product = Product.fromJson(productData);

        return {
          'success': true,
          'product': product,
          'message': data['message'] ?? 'Product added successfully',
        };
      } else if (response.statusCode == 401) {
        await _authService.logout();
        return {
          'success': false,
          'error': 'Unauthorized. Please login again.',
          'requiresAuth': true,
        };
      } else if (response.statusCode == 400) {
        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'error': errorData['message'] ?? 'Invalid product data',
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'Invalid product data',
          };
        }
      } else {
        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'error': errorData['message'] ?? 'Failed to add product',
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'Server error: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      debugPrint('Error adding product: $e');
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Update an existing product
  Future<Map<String, dynamic>> updateProduct({
    required String productId,
    String? name,
    double? price,
    int? stock,
    String? description,
    String? category,
    List<String>? images,
    String? status,
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$productsEndpoint/$productId');

      // Only include non-null values in the update
      final Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (price != null) updateData['price'] = price;
      if (stock != null) updateData['stock'] = stock;
      if (description != null) updateData['description'] = description;
      if (category != null) updateData['category'] = category;
      if (images != null) updateData['images'] = images;
      if (status != null) updateData['status'] = status;

      final body = json.encode(updateData);

      debugPrint('Updating product $productId: $body');

      final response = await http.put(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Adjust based on your actual API response format for PUT
        final product = Product.fromJson(data);
        return {
          'success': true,
          'product': product,
        };
      } else if (response.statusCode == 401) {
        await _authService.logout();
        return {
          'success': false,
          'error': 'Unauthorized. Please login again.',
          'requiresAuth': true,
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'error': 'Product not found',
        };
      } else {
        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'error': errorData['message'] ?? 'Failed to update product',
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'Server error: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      debugPrint('Error updating product: $e');
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Delete a product
  Future<Map<String, dynamic>> deleteProduct(String productId) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$productsEndpoint/$productId');

      debugPrint('Deleting product: $productId');

      final response = await http.delete(uri, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': 'Product deleted successfully',
        };
      } else if (response.statusCode == 401) {
        await _authService.logout();
        return {
          'success': false,
          'error': 'Unauthorized. Please login again.',
          'requiresAuth': true,
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'error': 'Product not found',
        };
      } else {
        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'error': errorData['message'] ?? 'Failed to delete product',
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'Server error: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      debugPrint('Error deleting product: $e');
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Search/Filter products using the main products endpoint
  Future<Map<String, dynamic>> searchProducts({
    required String query,
    int page = 1,
    int limit = 10,
    String? category,
    String? status,
  }) async {
    // Use the same getAllProducts method with search parameter
    return await getAllProducts(
      page: page,
      limit: limit,
      category: category,
      status: status,
      search: query,
    );
  }
}
