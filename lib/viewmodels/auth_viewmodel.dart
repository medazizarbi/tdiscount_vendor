import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdiscount_vendor/models/store.dart';
import '../services/auth_services.dart';
import '../viewmodels/store_viewmodel.dart'; // Add this import

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StoreViewModel _storeViewModel = StoreViewModel(); // Add this

  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  // Add getter for store view model
  StoreViewModel get storeViewModel => _storeViewModel;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Login method
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _authService.login(email: email, password: password);

      if (result['success'] == true) {
        _isAuthenticated = true;

        // Handle store information
        final storeInfo = result['storeInfo'];
        print('🔍 Store info from auth service: $storeInfo');

        if (storeInfo != null) {
          final hasStore = storeInfo['hasStore'] ?? false;
          final storeResponseData = storeInfo['data'];

          print('🏪 Has store from auth service: $hasStore');
          print('📦 Store response data: $storeResponseData');

          if (hasStore && storeResponseData != null) {
            // Extract store data from the response structure
            final storeJson =
                storeResponseData['store']; // Get the store object
            print('🏪 Store JSON to parse: $storeJson');

            if (storeJson != null) {
              final store = StoreModel.fromJson(storeJson);
              await _storeViewModel.setStoreState(
                  hasStore: true, storeData: store);
              print('✅ Store data saved: ${store.name}');
            } else {
              await _storeViewModel.setStoreState(
                  hasStore: false, storeData: null);
              print('⚠️ No store data found in response');
            }
          } else {
            await _storeViewModel.setStoreState(
                hasStore: false, storeData: null);
            print('📭 Vendor has no store');
          }
        } else {
          // If no storeInfo, set hasStore to false
          await _storeViewModel.setStoreState(hasStore: false, storeData: null);
          print('📭 No store info in auth response');
        }

        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Login failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register method
  Future<bool> register(String name, String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _authService.register(
          name: name, email: email, password: password);

      if (result['success'] == true) {
        _isAuthenticated = true;

        // Handle store information
        final storeInfo = result['storeInfo'];
        if (storeInfo != null) {
          final hasStore = storeInfo['hasStore'] ?? false;
          final storeData = storeInfo['data'];

          if (hasStore && storeData != null) {
            // Parse store data if exists
            final storeJson = storeData['store'] ?? storeData;
            final store = StoreModel.fromJson(storeJson);
            await _storeViewModel.setStoreState(
                hasStore: true, storeData: store);
          } else {
            await _storeViewModel.setStoreState(
                hasStore: false, storeData: null);
          }
        }

        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Registration failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout method - clear both auth and store state
  Future<bool> logout() async {
    try {
      print('🚪 Starting logout process...');
      _isLoading = true;
      notifyListeners();

      // Clear auth data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      print('🗑️ Clearing authentication data...');
      await prefs.remove('token');
      await prefs.remove('vendor_id');
      await prefs.remove('vendor_name');
      await prefs.remove('vendor_email');
      await prefs.remove('vendor_status');
      await prefs.setBool('is_authenticated', false);

      print('✅ Authentication data cleared from SharedPreferences');

      // Clear store state through StoreViewModel
      print('🏪 Clearing store state...');
      await _storeViewModel.clearStoreState();
      print('✅ Store state cleared');

      // Clear ViewModel state
      _isAuthenticated = false;
      _errorMessage = null;

      print('✅ Logout completed successfully');
      notifyListeners();
      return true;
    } catch (e) {
      print('🚨 Logout failed: $e');
      _errorMessage = 'Logout failed: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check authentication status on app start
  Future<void> checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('token');
      final isAuthenticated = prefs.getBool('is_authenticated') ?? false;

      // Check if both token exists and authenticated flag is true
      if (token != null && token.isNotEmpty && isAuthenticated) {
        _isAuthenticated = true;
      } else {
        _isAuthenticated = false;
      }

      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  /// Get vendor data from SharedPreferences
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

  /// Get stored token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      return null;
    }
  }

  /// Convenient getters for vendor info
  Future<String?> get vendorName async {
    final vendorData = await getVendorData();
    return vendorData?['name'];
  }

  Future<String?> get vendorEmail async {
    final vendorData = await getVendorData();
    return vendorData?['email'];
  }

  Future<String?> get vendorId async {
    final vendorData = await getVendorData();
    return vendorData?['id'];
  }
}
