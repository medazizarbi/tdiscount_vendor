import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
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
    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        return {
          'success': true,
          'data': responseData,
          'message': responseData['message'] ?? 'Login successful',
        };
      } else {
        // Error from server
        return {
          'success': false,
          'data': null,
          'message': responseData['message'] ?? 'Login failed',
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

  // Register method
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
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

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        await _storeRegistrationData(
            responseData); // Store data on successful registration
        return {
          'success': true,
          'data': responseData,
          'message': responseData['message'] ?? 'Registration successful',
        };
      } else {
        // Error from server
        return {
          'success': false,
          'data': null,
          'message': responseData['message'] ?? 'Registration failed',
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

  // Helper method to store registration data in SharedPreferences
  Future<void> _storeRegistrationData(Map<String, dynamic> responseData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print('📂 SharedPreferences instance obtained for registration');

      // The server response has a nested structure: response.data.token and response.data.vendor
      final data = responseData['data'] ??
          responseData; // Handle both nested and flat structures
      print('🔍 Extracted data object: $data');

      // Extract and store token from the data object
      final token = data['token'] ?? '';
      print('🔑 Registration token to store: $token');
      await prefs.setString('token', token);
      print('✅ Registration token stored successfully');

      // Extract and store vendor data from the data object
      final vendor = data['vendor'];
      print('👤 Registration vendor data to store: $vendor');

      if (vendor != null) {
        final vendorId = vendor['id'] ?? '';
        final vendorName = vendor['name'] ?? '';
        final vendorEmail = vendor['email'] ?? '';
        final vendorStatus = vendor['status'] ?? '';

        print('🆔 Registration Vendor ID: $vendorId');
        print('👤 Registration Vendor Name: $vendorName');
        print('📧 Registration Vendor Email: $vendorEmail');
        print('🟢 Registration Vendor Status: $vendorStatus');

        await prefs.setString('vendor_id', vendorId);
        await prefs.setString('vendor_name', vendorName);
        await prefs.setString('vendor_email', vendorEmail);
        await prefs.setString('vendor_status', vendorStatus);
        await prefs.setBool('is_authenticated', true);

        print('✅ All registration vendor data stored successfully');
      } else {
        print('⚠️ No vendor data found in registration response');
      }

      // Verify registration data was stored correctly
      print('🔍 Verifying stored registration data...');
      // await _verifyStoredRegistrationData();
    } catch (e) {
      print('🚨 Error storing registration data: $e');
      print('📍 Registration storage error type: ${e.runtimeType}');
    }
  }

  // Helper method to check if user is authenticated (optional)
  Future<bool> isAuthenticated() async {
    // You can implement token validation logic here
    // For now, just return false
    return false;
  }

  // Logout method (optional)
  Future<Map<String, dynamic>> logout() async {
    try {
      // Clear any stored tokens/user data here
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
