import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_services.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

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

  /// Logout method - handles clearing local data only
  Future<bool> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Clear all data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove('token');
      await prefs.remove('vendor_id');
      await prefs.remove('vendor_name');
      await prefs.remove('vendor_email');
      await prefs.remove('vendor_status');
      await prefs.setBool('is_authenticated', false);

      // Clear ViewModel state
      _isAuthenticated = false;
      _errorMessage = null;

      notifyListeners();
      return true;
    } catch (e) {
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
      
      _isAuthenticated = prefs.getBool('is_authenticated') ?? false;
      
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
