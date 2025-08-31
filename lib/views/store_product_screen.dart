import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants/colors.dart';
import '../utils/widgets/custom_app_bar.dart';
import '../utils/widgets/screen_container.dart';
import '../utils/widgets/vendor_product_card.dart';
import '../viewmodels/product_viewmodel.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';

class StoreProductScreen extends StatefulWidget {
  const StoreProductScreen({super.key});

  @override
  State<StoreProductScreen> createState() => _StoreProductScreenState();
}

class _StoreProductScreenState extends State<StoreProductScreen> {
  final ScrollController _scrollController = ScrollController();
  late ProductViewModel _productViewModel;
  String? _selectedStatus;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _productViewModel = Provider.of<ProductViewModel>(context, listen: false);
    _scrollController.addListener(_onScroll);

    // Initialize products when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _productViewModel.initializeProducts();
    });
  }

  void _onScroll() {
    if (_productViewModel.shouldLoadMore(
      _scrollController.position.pixels,
      _scrollController.position.maxScrollExtent,
    )) {
      _productViewModel.loadMoreProducts();
    }
  }

  Future<void> _onRefresh() async {
    await _productViewModel.refreshProducts();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  Widget _buildFilterBottomSheet() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filtrer les Produits',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Status Filter
              const Text('Statut',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  {'label': 'Tous', 'value': null},
                  {'label': 'Actif', 'value': 'active'},
                  {'label': 'Inactif', 'value': 'inactive'},
                  {'label': 'En rupture', 'value': 'out_of_stock'},
                ]
                    .map((option) => GestureDetector(
                          onTap: () {
                            setModalState(() {
                              _selectedStatus = option['label'] == 'Tous'
                                  ? null
                                  : option['value'] as String?;
                            });
                          },
                          child: _buildFilterChip(
                            option['label'] as String,
                            option['value'] as String?,
                            _selectedStatus,
                          ),
                        ))
                    .toList(),
              ),

              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setModalState(() {
                          _selectedStatus = null;
                          _selectedCategory = null;
                        });
                        _productViewModel.applyFilters();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            themedColor(context, Colors.black, Colors.white),
                        side: BorderSide(
                          color:
                              themedColor(context, Colors.black, Colors.white),
                        ),
                      ),
                      child: const Text('Effacer'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _productViewModel.applyFilters(
                          status: _selectedStatus,
                          category: _selectedCategory,
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Appliquer'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String? value, String? selectedValue) {
    final isSelected = selectedValue == value;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey[700] : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        border:
            isSelected ? Border.all(color: Colors.grey[800]!, width: 1) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          CustomSliverAppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list, color: TColors.black),
                onPressed: _showFilterBottomSheet,
              ),
              IconButton(
                icon: const Icon(Icons.add, color: TColors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProductFormScreen(
                        title: 'Créer un produit',
                        isEdit: false,
                      ),
                    ),
                  );
                },
              ),
            ],
            showBackButton: true,
            showThemeToggle: true,
            pinned: false,
            floating: true,
            snap: false,
          ),
          SliverToBoxAdapter(
            child: ScreenContainer(
              title: 'Produits',
              child: Column(
                children: [
                  Consumer<ProductViewModel>(
                    builder: (context, productVM, child) {
                      if (productVM.isLoading && productVM.products.isEmpty) {
                        return _buildLoadingState();
                      }

                      if (productVM.error != null &&
                          productVM.products.isEmpty) {
                        return _buildErrorState(productVM.error!, productVM);
                      }

                      if (productVM.products.isEmpty) {
                        return _buildEmptyState();
                      }

                      return _buildProductsList(productVM);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 600,
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(TColors.primary),
          ),
          SizedBox(height: 16),
          Text('Chargement des produits...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, ProductViewModel productVM) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur de Chargement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Une erreur est survenue lors du chargement des produits',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              productVM.refreshProducts();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: Colors.black,
            ),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        // Product management header
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(Icons.inventory, size: 60, color: TColors.primary),
                SizedBox(height: 16),
                Text(
                  'Gestion des Produits',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Gérez votre catalogue de produits, ajoutez de nouveaux produits et mettez à jour les existants.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Empty State
        Card(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 100,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 24),
                Text(
                  'Aucun Produit Trouvé',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Commencez à construire votre catalogue en ajoutant vos produits.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[500],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProductFormScreen(
                          title: 'Créer un produit',
                          isEdit: false,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter Votre Premier Produit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    _productViewModel.refreshProducts();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Actualiser'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Quick tips card
        _buildQuickTipsCard(),
      ],
    );
  }

  Widget _buildProductsList(ProductViewModel productVM) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Column(
        children: [
          // Products Stats
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${productVM.totalProducts}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: TColors.primary,
                          ),
                        ),
                        const Text('Total Produits'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${productVM.getActiveProducts().length}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const Text('Actifs'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${productVM.getLowStockProducts().length}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const Text('Stock Faible'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Products Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.6,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: productVM.products.length,
            itemBuilder: (context, index) {
              final product = productVM.products[index];
              return VendorProductCard(
                product: product,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailScreen(product: product),
                    ),
                  );
                },
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductFormScreen(
                        title: 'Modifier le produit',
                        product: product,
                        isEdit: true,
                      ),
                    ),
                  );
                },
                onDelete: () {
                  _showDeleteConfirmation(product);
                },
                onToggleStatus: () {
                  _toggleProductStatus(product);
                },
              );
            },
          ),

          // Loading more indicator
          if (productVM.isLoadingMore) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(TColors.primary),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Chargement de plus de produits...'),
                ],
              ),
            ),
          ],

          // Load more button
          if (productVM.hasMoreProducts && !productVM.isLoadingMore) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: productVM.loadMoreProducts,
              child: const Text('Charger Plus de Produits'),
            ),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themedColor(context, Colors.white, TColors.carddark),
        title: Text(
          'Supprimer Produit',
          style: TextStyle(
            color: themedColor(context, TColors.textPrimary, TColors.textWhite),
          ),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${product.name}" ?',
          style: TextStyle(
            color:
                themedColor(context, TColors.textSecondary, TColors.textWhite),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: themedColor(context, Colors.black, Colors.white),
              backgroundColor: themedColor(
                  context,
                  Colors.grey[200] ?? Colors.white,
                  Colors.grey[700] ?? Colors.black),
            ),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _productViewModel.deleteProduct(product.id);
              if (success && mounted) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} supprimé avec succès'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text('Erreur lors de la suppression du produit'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 8,
      ),
    );
  }

  void _toggleProductStatus(Product product) async {
    final newStatus = product.status == 'active' ? 'inactive' : 'active';
    final success = await _productViewModel.updateProduct(
      productId: product.id,
      status: newStatus,
    );

    if (success && mounted) {
      final statusText = newStatus == 'active' ? 'actif' : 'inactif';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Statut du produit mis à jour : $statusText'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la mise à jour du statut'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildQuickTipsCard() {
    return Card(
      color: TColors.primary.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: TColors.primary,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Conseils Rapides',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTip('Ajoutez des images de haute qualité'),
            _buildTip('Rédigez des descriptions détaillées'),
            _buildTip('Définissez des prix compétitifs'),
            _buildTip('Maintenez les niveaux de stock à jour'),
            _buildTip('Organisez les produits par catégories'),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 8, right: 12),
            decoration: const BoxDecoration(
              color: TColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
