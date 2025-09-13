import 'dart:convert';
import 'dart:io';
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

  /// Add a new product with images (multipart)
  Future<Map<String, dynamic>> addProduct({
    required String name,
    required double price,
    required int stock,
    String? description,
    String? category,
    List<File>? imageFiles, // <-- Use File for images
    String status = 'active',
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$productsEndpoint');

      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      request.fields['name'] = name;
      request.fields['price'] = price.toString();
      request.fields['stock'] = stock.toString();
      if (description != null) request.fields['description'] = description;
      if (category != null) request.fields['category'] = category;
      request.fields['status'] = status;

      // Attach multiple images
      if (imageFiles != null) {
        for (var i = 0; i < imageFiles.length; i++) {
          var image = imageFiles[i];
          request.files
              .add(await http.MultipartFile.fromPath('images', image.path));
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Add product response status: ${response.statusCode}');
      print('Add product response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        final productData = data['product'] ?? data;
        final product = Product.fromJson(productData);

        return {
          'success': true,
          'product': product,
          'message': data['message'] ?? 'Product added successfully',
        };
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

  /// Update an existing product with images (multipart)
  Future<Map<String, dynamic>> updateProduct({
    required String productId,
    String? name,
    double? price,
    int? stock,
    String? description,
    String? category,
    List<File>? imageFiles, // <-- Use File for images
    String? status,
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$productsEndpoint/$productId');

      var request = http.MultipartRequest('PUT', uri);
      request.headers.addAll(headers);

      if (name != null) request.fields['name'] = name;
      if (price != null) request.fields['price'] = price.toString();
      if (stock != null) request.fields['stock'] = stock.toString();
      if (description != null) request.fields['description'] = description;
      if (category != null) request.fields['category'] = category;
      if (status != null) request.fields['status'] = status;

      // Attach multiple images
      if (imageFiles != null) {
        for (var i = 0; i < imageFiles.length; i++) {
          var image = imageFiles[i];
          request.files
              .add(await http.MultipartFile.fromPath('images', image.path));
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Update product response status: ${response.statusCode}');
      debugPrint('Update product response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final product = Product.fromJson(data);
        return {
          'success': true,
          'product': product,
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
