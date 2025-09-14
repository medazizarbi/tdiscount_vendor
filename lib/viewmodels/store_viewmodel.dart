import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/store.dart';
import '../services/store_services.dart';

class StoreViewModel extends ChangeNotifier {
  final StoreService _storeService = StoreService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _hasStore = false;
  StoreModel? _storeData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasStore => _hasStore;
  StoreModel? get storeData => _storeData;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Initialize store state from SharedPreferences
  Future<void> initializeStoreState() async {
    try {
      print('🏪 Initializing store state from SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();

      _hasStore = prefs.getBool('has_store') ?? false;
      print('🏪 Stored hasStore: $_hasStore');

      // Load store data if exists
      final storeJsonString = prefs.getString('store_data');
      if (storeJsonString != null && _hasStore) {
        try {
          final storeMap = jsonDecode(storeJsonString);
          _storeData = StoreModel.fromJson(storeMap);
          print('✅ Store data loaded: ${_storeData?.name}');
        } catch (e) {
          print('🚨 Error parsing stored store data: $e');
          _storeData = null;
          _hasStore = false;
        }
      } else {
        _storeData = null;
        print('📭 No store data found in storage');
      }

      notifyListeners();
    } catch (e) {
      print('🚨 Error initializing store state: $e');
      _hasStore = false;
      _storeData = null;
      notifyListeners();
    }
  }

  /// Set store state (called after login/register)
  Future<void> setStoreState({
    required bool hasStore,
    StoreModel? storeData,
  }) async {
    try {
      print('💾 Setting store state...');
      print('💾 Input hasStore: $hasStore');
      print('💾 Input storeData: ${storeData?.name}');

      final prefs = await SharedPreferences.getInstance();

      _hasStore = hasStore;
      _storeData = storeData;

      // Save to SharedPreferences
      await prefs.setBool('has_store', hasStore);
      print('💾 Saved hasStore to prefs: $hasStore');

      if (storeData != null) {
        final storeJsonString = jsonEncode(storeData.toJson());
        await prefs.setString('store_data', storeJsonString);
        print('💾 Saved store data: ${storeData.name}');
        print('💾 Store JSON saved: $storeJsonString');
      } else {
        await prefs.remove('store_data');
        print('🗑️ Removed store data (storeData was null)');
      }

      print('💾 Final _hasStore state: $_hasStore');
      print('💾 Final _storeData state: ${_storeData?.name}');

      notifyListeners();
    } catch (e) {
      print('🚨 Error setting store state: $e');
    }
  }

  /// Create new store (logo and banner as File)
  Future<bool> createStore({
    required String name,
    required String description,
    File? logoFile,
    File? bannerFile,
    Map<String, String>? socialLinks,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _storeService.createStore(
        name: name,
        description: description,
        logo: logoFile,
        banner: bannerFile,
        socialLinks: socialLinks,
      );

      if (result['success'] == true) {
        final storeJson = result['data']['store'] ?? result['data'];
        final newStore = StoreModel.fromJson(storeJson);

        await setStoreState(hasStore: true, storeData: newStore);

        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to create store';
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

  /// Refresh store data
  Future<bool> refreshStoreData() async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _storeService.getStore();

      if (result['success'] == true) {
        if (result['hasStore'] == true && result['data'] != null) {
          final storeJson = result['data']['store'] ?? result['data'];
          final store = StoreModel.fromJson(storeJson);

          await setStoreState(hasStore: true, storeData: store);
        } else {
          await setStoreState(hasStore: false, storeData: null);
        }

        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to refresh store data';
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

  /// Update existing store (logo and banner as File)
  Future<bool> updateStore({
    String? name,
    String? description,
    File? logoFile,
    File? bannerFile,
    Map<String, String>? socialLinks,
  }) async {
    if (_storeData == null) {
      _errorMessage = 'No store to update';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _storeService.updateStore(
        storeId: _storeData!.id,
        name: name,
        description: description,
        logoFile: logoFile,
        bannerFile: bannerFile,
        socialLinks: socialLinks,
      );

      if (result['success'] == true) {
        final storeJson = result['data']['store'] ?? result['data'];
        final updatedStore = StoreModel.fromJson(storeJson);

        await setStoreState(hasStore: true, storeData: updatedStore);

        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to update store';
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

  /// Clear store state (called on logout)
  Future<void> clearStoreState() async {
    try {
      print('🏪 Clearing store state from SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();

      _hasStore = false;
      _storeData = null;
      _errorMessage = null;

      await prefs.remove('has_store');
      await prefs.remove('store_data');

      print('✅ Store state cleared successfully');
      notifyListeners();
    } catch (e) {
      print('🚨 Error clearing store state: $e');
    }
  }
}
