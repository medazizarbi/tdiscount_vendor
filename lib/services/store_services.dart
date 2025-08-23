import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreService {
  // Get base URL from .env
  static String get baseUrl => dotenv.env['BASE_URL']!;
  static String get storeEndpoint => dotenv.env['STORE_ENDPOINT']!;

  // Build full URLs
  static String get storeUrl => '$baseUrl$storeEndpoint';

  // Get token from SharedPreferences
  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      return null;
    }
  }

  // Get headers with authorization
  Future<Map<String, String>> get headers async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Create Store
  Future<Map<String, dynamic>> createStore({
    required String name,
    required String description,
    String? logo,
    String? banner,
    Map<String, String>? socialLinks,
  }) async {
    try {
      final requestBody = {
        'name': name,
        'description': description,
        if (logo != null) 'logo': logo,
        if (banner != null) 'banner': banner,
        if (socialLinks != null) 'socialLinks': socialLinks,
      };

      final response = await http.post(
        Uri.parse(storeUrl),
        headers: await headers,
        body: jsonEncode(requestBody),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        return {
          'success': true,
          'data': responseData,
          'message': responseData['message'] ?? 'Store created successfully',
        };
      } else {
        // Error from server
        return {
          'success': false,
          'data': null,
          'message': responseData['message'] ?? 'Failed to create store',
          'errors': responseData['errors'] ?? {},
        };
      }
    } catch (e) {
      // Network or other error
      return {
        'success': false,
        'data': null,
        'message': 'Network error: ${e.toString()}',
        'errors': {},
      };
    }
  }

  /// Get Store
  /// Use this after login/register to check if vendor has a store
  Future<Map<String, dynamic>> getStore() async {
    try {
      print('🏪 Starting get store process...');
      print('🔗 Store URL: $storeUrl');
      
      final requestHeaders = await headers;
      print('📝 Request headers: $requestHeaders');
      
      print('⏳ Sending HTTP GET request to get store...');
      
      final response = await http.get(
        Uri.parse(storeUrl),
        headers: requestHeaders,
      );

      print('📊 Get store response status code: ${response.statusCode}');
      print('📄 Raw get store response body: ${response.body}');
      print('🔍 Get store response headers: ${response.headers}');

      final responseData = jsonDecode(response.body);
      print('🔄 Parsed get store response data: $responseData');

      if (response.statusCode == 200) {
        print('✅ Get store successful!');
        
        // Fix: Check for 'store' key instead of 'data'
        final storeData = responseData['store'];
        final hasStoreData = storeData != null;
        print('🏪 Vendor has store: $hasStoreData');
        print('📦 Store data: $storeData');
        
        // Success
        final result = {
          'success': true,
          'data': responseData, // Keep the full response
          'hasStore': hasStoreData, // Fixed: now correctly detects store
          'message': responseData['message'] ?? 'Store retrieved successfully',
        };
        print('🎉 Final get store success result: $result');
        return result;
      } else if (response.statusCode == 404) {
        print('📭 No store found for this vendor (404)');
        
        // No store found
        final result = {
          'success': true,
          'data': null,
          'hasStore': false,
          'message': 'No store found for this vendor',
        };
        print('📭 Final no store result: $result');
        return result;
      } else {
        print('❌ Get store failed with status: ${response.statusCode}');
        
        // Error from server
        final result = {
          'success': false,
          'data': null,
          'hasStore': false,
          'message': responseData['message'] ?? 'Failed to get store',
          'errors': responseData['errors'] ?? {},
        };
        print('💥 Final get store error result: $result');
        return result;
      }
    } catch (e) {
      print('🚨 Exception occurred during get store: $e');
      print('📍 Get store exception type: ${e.runtimeType}');
      
      // Network or other error
      final result = {
        'success': false,
        'data': null,
        'hasStore': false,
        'message': 'Network error: ${e.toString()}',
        'errors': {},
      };
      print('💥 Final get store exception result: $result');
      return result;
    }
  }

  /// Update Store
  Future<Map<String, dynamic>> updateStore({
    required String storeId,
    String? name,
    String? description,
    String? logo,
    String? banner,
    Map<String, String>? socialLinks,
  }) async {
    try {
      final requestBody = <String, dynamic>{};

      if (name != null) requestBody['name'] = name;
      if (description != null) requestBody['description'] = description;
      if (logo != null) requestBody['logo'] = logo;
      if (banner != null) requestBody['banner'] = banner;
      if (socialLinks != null) requestBody['socialLinks'] = socialLinks;

      final response = await http.put(
        Uri.parse('$storeUrl/$storeId'),
        headers: await headers,
        body: jsonEncode(requestBody),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Success
        return {
          'success': true,
          'data': responseData,
          'message': responseData['message'] ?? 'Store updated successfully',
        };
      } else {
        // Error from server
        return {
          'success': false,
          'data': null,
          'message': responseData['message'] ?? 'Failed to update store',
          'errors': responseData['errors'] ?? {},
        };
      }
    } catch (e) {
      // Network or other error
      return {
        'success': false,
        'data': null,
        'message': 'Network error: ${e.toString()}',
        'errors': {},
      };
    }
  }

  /// Helper method to check if vendor has a store
  Future<bool> hasStore() async {
    try {
      final result = await getStore();
      return result['hasStore'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Helper method to get store data only
  Future<Map<String, dynamic>?> getStoreData() async {
    try {
      final result = await getStore();
      if (result['success'] == true && result['hasStore'] == true) {
        return result['data'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Helper method to get store ID
  Future<String?> getStoreId() async {
    try {
      final storeData = await getStoreData();
      return storeData?['id'] ?? storeData?['_id'];
    } catch (e) {
      return null;
    }
  }
}
