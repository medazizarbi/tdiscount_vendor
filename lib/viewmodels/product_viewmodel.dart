import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/product_services.dart';

class ProductViewModel extends ChangeNotifier {
  final ProductService _productService = ProductService();

  // State variables
  List<Product> _products = [];
  Product? _selectedProduct;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  // Pagination variables
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalProducts = 0;
  bool _hasMoreProducts = true;

  // Filter variables
  String? _currentCategory;
  String? _currentStatus;
  String? _currentSearch;
  final int _limit = 10;

  // Getters
  List<Product> get products => _products;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalProducts => _totalProducts;
  bool get hasMoreProducts => _hasMoreProducts;
  String? get currentCategory => _currentCategory;
  String? get currentStatus => _currentStatus;
  String? get currentSearch => _currentSearch;

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set loading more state
  void _setLoadingMore(bool loading) {
    _isLoadingMore = loading;
    notifyListeners();
  }

  // Set error state
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Initialize products - call this when the screen loads
  Future<void> initializeProducts({
    String? category,
    String? status,
    String? search,
  }) async {
    _currentCategory = category;
    _currentStatus = status;
    _currentSearch = search;
    _currentPage = 1;
    _products.clear();
    _hasMoreProducts = true;

    await _fetchProducts(isRefresh: true);
  }

  /// Fetch products from API
  Future<void> _fetchProducts({
    bool isRefresh = false,
    bool isLoadingMore = false,
  }) async {
    try {
      if (isRefresh) {
        _setLoading(true);
        _currentPage = 1;
        _products.clear();
        _hasMoreProducts = true;
      } else if (isLoadingMore) {
        if (!_hasMoreProducts || _isLoadingMore || _isLoading) return;
        _setLoadingMore(true);
      } else {
        _setLoading(true);
      }

      _setError(null);

      final result = await _productService.getAllProducts(
        page: _currentPage,
        limit: _limit,
        category: _currentCategory,
        status: _currentStatus,
        search: _currentSearch,
      );

      if (result['success'] == true) {
        final List<Product> newProducts = result['products'] ?? [];

        if (isRefresh || _currentPage == 1) {
          _products = newProducts;
        } else {
          // For pagination, add to existing list
          _products.addAll(newProducts);
        }

        _currentPage = result['currentPage'] ?? _currentPage;
        _totalPages = result['totalPages'] ?? 1;
        _totalProducts = result['totalProducts'] ?? 0;
        _hasMoreProducts = result['hasMore'] ?? false;

        debugPrint(
            'Loaded ${newProducts.length} products. Total: ${_products.length}');
      } else {
        _setError(result['error'] ?? 'Failed to fetch products');

        // Handle authentication error
        if (result['requiresAuth'] == true) {
          // The service already handled logout, just show error
          debugPrint('Authentication required - user logged out');
        }
      }
    } catch (e) {
      _setError('Unexpected error: ${e.toString()}');
      debugPrint('Error in _fetchProducts: $e');
    } finally {
      if (isRefresh || (!isLoadingMore && !isRefresh)) {
        _setLoading(false);
      } else {
        _setLoadingMore(false);
      }
    }
  }

  /// Auto-pagination method for scroll detection
  Future<void> loadMoreProducts() async {
    if (!_hasMoreProducts || _isLoadingMore || _isLoading) {
      debugPrint(
          'Cannot load more: hasMore=$_hasMoreProducts, isLoadingMore=$_isLoadingMore, isLoading=$_isLoading');
      return;
    }

    debugPrint('Loading more products - Page: ${_currentPage + 1}');
    _currentPage++;
    await _fetchProducts(isLoadingMore: true);
  }

  /// Check if should load more products based on scroll position
  bool shouldLoadMore(double scrollPosition, double maxScrollExtent) {
    if (!_hasMoreProducts || _isLoadingMore || _isLoading) return false;

    // Load more when user is 80% down the list
    const threshold = 0.8;
    final shouldLoad = scrollPosition >= (maxScrollExtent * threshold);

    if (shouldLoad) {
      debugPrint(
          'Scroll threshold reached: ${scrollPosition.toStringAsFixed(2)}/${maxScrollExtent.toStringAsFixed(2)}');
    }

    return shouldLoad;
  }

  /// Refresh products list
  Future<void> refreshProducts() async {
    debugPrint('Refreshing products...');
    await _fetchProducts(isRefresh: true);
  }

  /// Apply filters and refresh
  Future<void> applyFilters({
    String? category,
    String? status,
    String? search,
  }) async {
    debugPrint(
        'Applying filters: category=$category, status=$status, search=$search');

    _currentCategory = category;
    _currentStatus = status;
    _currentSearch = search;

    await _fetchProducts(isRefresh: true);
  }

  /// Search products
  Future<void> searchProducts(String query) async {
    debugPrint('Searching products: $query');
    _currentSearch = query.trim().isEmpty ? null : query.trim();
    await _fetchProducts(isRefresh: true);
  }

  /// Clear search
  Future<void> clearSearch() async {
    debugPrint('Clearing search');
    _currentSearch = null;
    await _fetchProducts(isRefresh: true);
  }

  /// Get a single product by ID
  Future<Product?> getProduct(String productId) async {
    try {
      _setLoading(true);
      _setError(null);

      final result = await _productService.getProduct(productId);

      if (result['success'] == true) {
        _selectedProduct = result['product'];
        notifyListeners();
        return _selectedProduct;
      } else {
        _setError(result['error'] ?? 'Failed to fetch product');
        return null;
      }
    } catch (e) {
      _setError('Unexpected error: ${e.toString()}');
      debugPrint('Error in getProduct: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Add a new product
  Future<bool> addProduct({
    required String name,
    required double price,
    required int stock,
    String? description,
    String? category,
    List<String>? images,
    String status = 'active',
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final result = await _productService.addProduct(
        name: name,
        price: price,
        stock: stock,
        description: description,
        category: category,
        images: images,
        status: status,
      );

      if (result['success'] == true) {
        // Add the new product to the beginning of the list
        final newProduct = result['product'] as Product;
        _products.insert(0, newProduct);
        _totalProducts++;
        notifyListeners();

        debugPrint('Product added successfully: ${newProduct.name}');
        return true;
      } else {
        _setError(result['error'] ?? 'Failed to add product');
        return false;
      }
    } catch (e) {
      _setError('Unexpected error: ${e.toString()}');
      debugPrint('Error in addProduct: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing product
  Future<bool> updateProduct({
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
      _setLoading(true);
      _setError(null);

      final result = await _productService.updateProduct(
        productId: productId,
        name: name,
        price: price,
        stock: stock,
        description: description,
        category: category,
        images: images,
        status: status,
      );

      if (result['success'] == true) {
        // Update the product in the local list
        final updatedProduct = result['product'] as Product;
        final index = _products.indexWhere((p) => p.id == productId);
        if (index != -1) {
          _products[index] = updatedProduct;
        }

        // Update selected product if it's the same
        if (_selectedProduct?.id == productId) {
          _selectedProduct = updatedProduct;
        }

        notifyListeners();
        debugPrint('Product updated successfully: ${updatedProduct.name}');

        // Refresh the products list from the server
        await _fetchProducts(isRefresh: true);

        return true;
      } else {
        _setError(result['error'] ?? 'Failed to update product');
        return false;
      }
    } catch (e) {
      _setError('Unexpected error: ${e.toString()}');
      debugPrint('Error in updateProduct: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a product
  Future<bool> deleteProduct(String productId) async {
    try {
      _setLoading(true);
      _setError(null);

      final result = await _productService.deleteProduct(productId);

      if (result['success'] == true) {
        // Remove the product from the local list
        _products.removeWhere((p) => p.id == productId);
        _totalProducts--;

        // Clear selected product if it's the deleted one
        if (_selectedProduct?.id == productId) {
          _selectedProduct = null;
        }

        notifyListeners();
        debugPrint('Product deleted successfully');
        return true;
      } else {
        _setError(result['error'] ?? 'Failed to delete product');
        return false;
      }
    } catch (e) {
      _setError('Unexpected error: ${e.toString()}');
      debugPrint('Error in deleteProduct: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get filtered products (local filtering)
  List<Product> getFilteredProducts({
    String? status,
    String? category,
    String? searchQuery,
  }) {
    List<Product> filtered = List.from(_products);

    if (status != null && status.isNotEmpty) {
      filtered = filtered.where((p) => p.status == status).toList();
    }

    if (category != null && category.isNotEmpty) {
      filtered = filtered.where((p) => p.category == category).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered
          .where((p) =>
              p.name.toLowerCase().contains(query) ||
              (p.description?.toLowerCase().contains(query) ?? false) ||
              (p.category?.toLowerCase().contains(query) ?? false))
          .toList();
    }

    return filtered;
  }

  /// Get products by status
  List<Product> getProductsByStatus(String status) {
    return _products.where((product) => product.status == status).toList();
  }

  /// Get products by category
  List<Product> getProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
  }

  /// Get low stock products
  List<Product> getLowStockProducts({int threshold = 10}) {
    return _products.where((product) => product.stock <= threshold).toList();
  }

  /// Get active products
  List<Product> getActiveProducts() {
    return _products.where((product) => product.isActive).toList();
  }

  /// Get in-stock products
  List<Product> getInStockProducts() {
    return _products.where((product) => product.inStock).toList();
  }

  /// Clear all data
  void clear() {
    _products.clear();
    _selectedProduct = null;
    _currentPage = 1;
    _totalPages = 1;
    _totalProducts = 0;
    _hasMoreProducts = true;
    _currentCategory = null;
    _currentStatus = null;
    _currentSearch = null;
    _error = null;
    _isLoading = false;
    _isLoadingMore = false;
    notifyListeners();
  }

  /// Get summary statistics
  Map<String, int> getProductStats() {
    return {
      'total': _products.length,
      'active': getActiveProducts().length,
      'inactive': getProductsByStatus('inactive').length,
      'outOfStock': getProductsByStatus('out_of_stock').length,
      'lowStock': getLowStockProducts().length,
    };
  }
}
