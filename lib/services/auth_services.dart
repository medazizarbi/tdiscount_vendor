import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'store_services.dart'; // Add this import

class AuthService {
  // Add StoreService instance
  final StoreService _storeService = StoreService();

  // Get base URL from .env
  static String get baseUrl => dotenv.env['BASE_URL']!;
  static String get loginEndpoint => dotenv.env['LOGIN_ENDPOINT']!;
  static String get registerEndpoint => dotenv.env['REGISTER_ENDPOINT']!;

  // Build full URLs
  static String get loginUrl => '$baseUrl$loginEndpoint';
  static String get registerUrl => '$baseUrl$registerEndpoint';

  // Common headers
  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Login method
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    print('🔑 Attempting login for email: $email');
    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      print('🔑 Login response status: ${response.statusCode}');
      print('🔑 Login response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Login successful, storing login data...');
        await _storeLoginData(responseData);

        print('🏪 Checking if vendor has a store after login...');
        final storeResult = await _storeService.getStore();
        print('🏪 Store check result: $storeResult');

        return {
          'success': true,
          'data': responseData,
          'message': responseData['message'] ?? 'Login successful',
          'storeInfo': {
            'hasStore': storeResult['hasStore'] ?? false,
            'data': storeResult['data'],
          },
        };
      } else {
        print('❌ Login failed: ${responseData['message']}');
        print('❌ Login errors: ${responseData['errors']}');
        return {
          'success': false,
          'data': null,
          'message': responseData['message'] ?? 'Login failed',
          'errors': responseData['errors'] ?? {},
        };
      }
    } catch (e) {
      print('🚨 Login error: $e');
      return {
        'success': false,
        'data': null,
        'message': 'Network error: ${e.toString()}',
        'errors': {},
      };
    }
  }

  // Register method
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    print('📝 Attempting registration for email: $email');
    try {
      final response = await http.post(
        Uri.parse(registerUrl),
        headers: headers,
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );
      print('📝 Registration response status: ${response.statusCode}');
      print('📝 Registration response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Registration successful, storing registration data...');
        await _storeRegistrationData(responseData);

        print('🏪 Checking if vendor has a store after registration...');
        final storeResult = await _storeService.getStore();
        print('🏪 Store check result: $storeResult');

        return {
          'success': true,
          'data': responseData,
          'message': responseData['message'] ?? 'Registration successful',
          'storeInfo': {
            'hasStore': storeResult['hasStore'] ?? false,
            'storeData': storeResult['data'],
          },
        };
      } else {
        print('❌ Registration failed: ${responseData['message']}');
        print('❌ Registration errors: ${responseData['errors']}');
        return {
          'success': false,
          'data': null,
          'message': responseData['message'] ?? 'Registration failed',
          'errors': responseData['errors'] ?? {},
        };
      }
    } catch (e) {
      print('🚨 Registration error: $e');
      return {
        'success': false,
        'data': null,
        'message': 'Network error: ${e.toString()}',
        'errors': {},
      };
    }
  }

  // Helper method to store login data in SharedPreferences
  Future<void> _storeLoginData(Map<String, dynamic> responseData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Handle nested structure - check if there's a 'data' object
      final data = responseData['data'] ?? responseData;

      // Extract and store token from the data object
      final token = data['token'] ?? '';
      await prefs.setString('token', token);

      // Extract and store vendor data from the data object
      final vendor = data['vendor'];

      if (vendor != null) {
        final vendorId = vendor['id'] ?? '';
        final vendorName = vendor['name'] ?? '';
        final vendorEmail = vendor['email'] ?? '';
        final vendorStatus = vendor['status'] ?? '';

        await prefs.setString('vendor_id', vendorId);
        await prefs.setString('vendor_name', vendorName);
        await prefs.setString('vendor_email', vendorEmail);
        await prefs.setString('vendor_status', vendorStatus);
        await prefs.setBool('is_authenticated', true);
      }
    } catch (e) {
      // Handle storage error silently or log to crash reporting service
    }
  }

  // Helper method to store registration data in SharedPreferences
  Future<void> _storeRegistrationData(Map<String, dynamic> responseData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // The server response has a nested structure: response.data.token and response.data.vendor
      final data = responseData['data'] ?? responseData;

      // Extract and store token from the data object
      final token = data['token'] ?? '';
      await prefs.setString('token', token);

      // Extract and store vendor data from the data object
      final vendor = data['vendor'];

      if (vendor != null) {
        final vendorId = vendor['id'] ?? '';
        final vendorName = vendor['name'] ?? '';
        final vendorEmail = vendor['email'] ?? '';
        final vendorStatus = vendor['status'] ?? '';

        await prefs.setString('vendor_id', vendorId);
        await prefs.setString('vendor_name', vendorName);
        await prefs.setString('vendor_email', vendorEmail);
        await prefs.setString('vendor_status', vendorStatus);
        await prefs.setBool('is_authenticated', true);
      }
    } catch (e) {
      // Handle storage error silently or log to crash reporting service
    }
  }

  // Helper method to check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('is_authenticated') ?? false;
    } catch (e) {
      return false;
    }
  }

  // Get stored vendor data
  Future<Map<String, dynamic>?> getVendorData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final vendorId = prefs.getString('vendor_id');
      final vendorName = prefs.getString('vendor_name');
      final vendorEmail = prefs.getString('vendor_email');
      final vendorStatus = prefs.getString('vendor_status');

      if (vendorId != null && vendorName != null && vendorEmail != null) {
        return {
          'id': vendorId,
          'name': vendorName,
          'email': vendorEmail,
          'status': vendorStatus ?? 'active',
        };
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Get stored token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      return null;
    }
  }

  // Logout method
  Future<Map<String, dynamic>> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove('token');
      await prefs.remove('vendor_id');
      await prefs.remove('vendor_name');
      await prefs.remove('vendor_email');
      await prefs.remove('vendor_status');
      await prefs.setBool('is_authenticated', false);

      return {
        'success': true,
        'message': 'Logged out successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Logout failed: ${e.toString()}',
      };
    }
  }
}
