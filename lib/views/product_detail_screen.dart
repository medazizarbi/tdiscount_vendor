import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants/colors.dart';
import '../utils/widgets/custom_app_bar.dart';
import '../utils/widgets/screen_container.dart';
import '../utils/widgets/product_images_viewer.dart';
import '../models/product.dart';
import 'product_form_screen.dart'; // Add this import
import '../viewmodels/product_viewmodel.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // Add this line to get access to ProductViewModel
  late ProductViewModel _productViewModel;
  bool descriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _productViewModel = Provider.of<ProductViewModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert, color: TColors.black),
                onPressed: () {
                  _showMoreOptions(context);
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
              title: 'Détails du Produit', // Translated to French
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Product Images Viewer
                  product.images.isNotEmpty
                      ? ProductImagesViewer(imageUrls: product.images)
                      : Container(
                          height: 350,
                          width: double.infinity,
                          margin: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[200],
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.image,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),

                  const SizedBox(height: 16),

                  // Product Name
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: themedColor(
                          context, TColors.textPrimary, TColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Price Section
                  Text(
                    product.formattedPrice,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: themedColor(
                          context, TColors.textPrimary, TColors.primary),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Product Info Row
                  Row(
                    children: [
                      // Stock Info - Translated
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: product.inStock
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                product.inStock
                                    ? Icons.check_circle
                                    : Icons.warning,
                                size: 20,
                                color:
                                    product.inStock ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Stock: ${product.stock}',
                                style: TextStyle(
                                  color: product.inStock
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Status Info - Translated
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color:
                              _getStatusColor(product.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(
                              product.status), // Use translated status
                          style: TextStyle(
                            color: _getStatusColor(product.status),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Category - Translated
                  if (product.category != null &&
                      product.category!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: themedColor(context,
                            TColors.grey.withOpacity(0.1), TColors.darkerGrey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Catégorie: ${product.category}',
                        style: TextStyle(
                          fontSize: 14,
                          color: themedColor(
                              context, TColors.textPrimary, TColors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Timestamps - Translated
                  Text(
                    'Créé: ${_formatDate(product.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: themedColor(
                          context, Colors.grey[600]!, Colors.grey[400]!),
                    ),
                  ),
                  Text(
                    'Modifié: ${_formatDate(product.updatedAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: themedColor(
                          context, Colors.grey[600]!, Colors.grey[400]!),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(thickness: 1, color: Colors.grey),
                  const SizedBox(height: 16),

                  // Description - Translated
                  if (product.description != null &&
                      product.description!.isNotEmpty) ...[
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themedColor(context, TColors.textPrimary,
                            TColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.description!,
                          maxLines: descriptionExpanded ? null : 4,
                          overflow: descriptionExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (!descriptionExpanded &&
                            product.description!.length > 200)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    descriptionExpanded = true;
                                  });
                                },
                                child: const Text('Voir Plus'),
                              ),
                            ],
                          ),
                        if (descriptionExpanded)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    descriptionExpanded = false;
                                  });
                                },
                                child: const Text('Voir Moins'),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ] else ...[
                    // No description message - Translated
                    const Text(
                      'Aucune description disponible.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],

                  const SizedBox(height: 100), // Extra space for scrolling
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Add this method for more options
  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: TColors.primary),
              title: const Text('Modifier le Produit'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductFormScreen(
                      title: 'Modifier le Produit',
                      product: widget.product,
                      isEdit: true,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Supprimer le Produit'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
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
          'Êtes-vous sûr de vouloir supprimer "${widget.product.name}" ?',
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
              // Close the dialog first
              Navigator.pop(context);

              // Show loading indicator
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Suppression en cours...'),
                      ],
                    ),
                    duration: Duration(seconds: 1),
                  ),
                );
              }

              // Perform delete operation
              final success =
                  await _productViewModel.deleteProduct(widget.product.id);

              // Check if widget is still mounted before showing results
              if (!mounted) return;

              if (success) {
                // Navigate back to products list first
                Navigator.pop(this.context);

                // Then show success message
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content:
                        Text('${widget.product.name} supprimé avec succès'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                // Show error message (stay on current screen)
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.orange;
      case 'out_of_stock':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Add this method for translated status text
  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'ACTIF';
      case 'inactive':
        return 'INACTIF';
      case 'out_of_stock':
        return 'RUPTURE';
      default:
        return status.toUpperCase();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
