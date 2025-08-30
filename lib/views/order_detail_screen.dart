import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants/colors.dart';
import '../utils/widgets/custom_app_bar.dart';
import '../utils/widgets/screen_container.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../viewmodels/order_viewmodel.dart';
import '../viewmodels/product_viewmodel.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;

  const OrderDetailScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late OrderViewModel _orderViewModel;
  late ProductViewModel _productViewModel;
  final Map<String, Product?> _products = {}; // Cache for loaded products
  bool _isLoadingProducts = false;

  @override
  void initState() {
    super.initState();
    _orderViewModel = Provider.of<OrderViewModel>(context, listen: false);
    _productViewModel = Provider.of<ProductViewModel>(context, listen: false);

    // Use addPostFrameCallback to load products after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrderProducts();
    });
  }

  Future<void> _loadOrderProducts() async {
    if (!mounted) return;

    setState(() {
      _isLoadingProducts = true;
    });

    for (final item in widget.order.items) {
      if (!_products.containsKey(item.productIdString)) {
        try {
          // Only load product if we don't have full product details
          if (!item.hasProductDetails) {
            final product =
                await _productViewModel.getProduct(item.productIdString);
            if (mounted) {
              setState(() {
                _products[item.productIdString] = product;
              });
            }
          }
        } catch (e) {
          debugPrint('Error loading product ${item.productIdString}: $e');
          if (mounted) {
            setState(() {
              _products[item.productIdString] = null;
            });
          }
        }
      }
    }

    if (mounted) {
      setState(() {
        _isLoadingProducts = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'EN ATTENTE';
      case 'processing':
        return 'EN COURS';
      case 'completed':
        return 'TERMINÉ';
      case 'cancelled':
        return 'ANNULÉ';
      default:
        return status.toUpperCase();
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: themedColor(context, Colors.white, TColors.carddark),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themedColor(
                    context, TColors.textPrimary, TColors.textWhite),
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color:
                    themedColor(context, Colors.grey[600]!, Colors.grey[400]!),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: themedColor(
                    context, TColors.textPrimary, TColors.textWhite),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildStatusUpdateDialog(),
    );
  }

  Widget _buildStatusUpdateDialog() {
    // Get allowed statuses based on current status
    List<String> allowedStatuses =
        _getAllowedStatusTransitions(widget.order.status);

    // If no transitions are allowed, show a message
    if (allowedStatuses.isEmpty) {
      return AlertDialog(
        backgroundColor: themedColor(context, Colors.white, TColors.carddark),
        title: Text(
          'Statut de la commande',
          style: TextStyle(
            color: themedColor(context, TColors.textPrimary, TColors.textWhite),
          ),
        ),
        content: Text(
          'Cette commande est terminée et ne peut plus être modifiée.',
          style: TextStyle(
            color: themedColor(context, TColors.textPrimary, TColors.textWhite),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: themedColor(context, Colors.black, Colors.white),
            ),
            child: const Text('Fermer'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }

    String selectedStatus = allowedStatuses.first;

    return StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          backgroundColor: themedColor(context, Colors.white, TColors.carddark),
          title: Text(
            'Mettre à jour le statut',
            style: TextStyle(
              color:
                  themedColor(context, TColors.textPrimary, TColors.textWhite),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Statut actuel: ${_getStatusText(widget.order.status)}',
                style: TextStyle(
                  color: themedColor(
                      context, Colors.grey[600]!, Colors.grey[400]!),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              ...allowedStatuses.map((status) {
                return RadioListTile<String>(
                  title: Text(
                    _getStatusText(status),
                    style: TextStyle(
                      color: themedColor(
                          context, TColors.textPrimary, TColors.textWhite),
                    ),
                  ),
                  value: status,
                  groupValue: selectedStatus,
                  onChanged: (value) {
                    setDialogState(() {
                      selectedStatus = value!;
                    });
                  },
                  activeColor: TColors.primary,
                );
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor:
                    themedColor(context, Colors.black, Colors.white),
              ),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _updateOrderStatus(selectedStatus);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: Colors.black,
              ),
              child: const Text('Mettre à jour'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }

  // Add this new method to determine allowed status transitions
  List<String> _getAllowedStatusTransitions(String currentStatus) {
    switch (currentStatus.toLowerCase()) {
      case 'pending':
        return ['processing', 'cancelled'];
      case 'processing':
        return ['completed', 'cancelled'];
      case 'completed':
        return []; // No transitions allowed from completed
      case 'cancelled':
        return []; // No transitions allowed from cancelled
      default:
        return ['processing', 'cancelled']; // Default to pending behavior
    }
  }

  Future<void> _updateOrderStatus(String newStatus) async {
    if (newStatus == widget.order.status) return;

    final success =
        await _orderViewModel.updateOrderStatus(widget.order.id, newStatus);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Statut mis à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Show user-friendly error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Impossible de mettre à jour le statut. Veuillez réessayer.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildOrderItemCard(OrderItem item) {
    final product = _products[item.productIdString];

    // Get product name - prioritize ProductInfo, then cached Product, then fallback
    String productName;
    if (item.hasProductDetails) {
      productName = item.productName;
    } else if (product != null) {
      productName = product.name;
    } else {
      productName =
          'Produit #${item.productIdString.substring(item.productIdString.length - 8)}';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: themedColor(context, Colors.grey[50]!, Colors.grey[800]!),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image Placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: product?.images.isNotEmpty == true
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product!.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image, color: Colors.grey);
                        },
                      ),
                    )
                  : const Icon(Icons.image, color: Colors.grey),
            ),
            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: themedColor(
                          context, TColors.textPrimary, TColors.textWhite),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Prix unitaire: ',
                        style: TextStyle(
                          fontSize: 12,
                          color: themedColor(
                              context, Colors.grey[600]!, Colors.grey[400]!),
                        ),
                      ),
                      Text(
                        item.formattedPrice,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: themedColor(
                              context, TColors.textPrimary, TColors.textWhite),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Quantité: ',
                        style: TextStyle(
                          fontSize: 12,
                          color: themedColor(
                              context, Colors.grey[600]!, Colors.grey[400]!),
                        ),
                      ),
                      Text(
                        '${item.quantity}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: themedColor(
                              context, TColors.textPrimary, TColors.textWhite),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Subtotal
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Sous-total',
                  style: TextStyle(
                    fontSize: 11,
                    color: themedColor(
                        context, Colors.grey[600]!, Colors.grey[400]!),
                  ),
                ),
                Text(
                  item.formattedSubtotal,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        themedColor(context, TColors.primary, TColors.primary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: TColors.black),
                onPressed: _showStatusUpdateDialog,
                tooltip: 'Mettre à jour le statut',
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
              title: 'Détails de la Commande',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Header
                  _buildSectionCard(
                    title: 'Informations de la Commande',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Commande #${order.id.substring(order.id.length - 8)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order.status),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                _getStatusText(order.status),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow('Date de création:',
                            _formatDateTime(order.createdAt)),
                        _buildInfoRow('Dernière mise à jour:',
                            _formatDateTime(order.updatedAt)),
                        _buildInfoRow('Total:', order.formattedTotal),
                        _buildInfoRow(
                            'Nombre d\'articles:', '${order.totalItems}'),
                        if (order.notes != null && order.notes!.isNotEmpty)
                          _buildInfoRow('Notes:', order.notes!),
                      ],
                    ),
                  ),

                  // Customer Information
                  _buildSectionCard(
                    title: 'Informations Client',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Nom:', order.customerName),
                        _buildInfoRow('Email:', order.customerEmail),
                      ],
                    ),
                  ),

                  // Products Section
                  _buildSectionCard(
                    title: 'Produits Commandés',
                    child: _isLoadingProducts
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 8),
                                  Text(
                                      'Chargement des détails des produits...'),
                                ],
                              ),
                            ),
                          )
                        : Column(
                            children: order.items.map((item) {
                              return _buildOrderItemCard(item);
                            }).toList(),
                          ),
                  ),

                  // Order Summary
                  _buildSectionCard(
                    title: 'Résumé de la Commande',
                    child: Column(
                      children: [
                        ...order.items.map((item) {
                          String productName;
                          if (item.hasProductDetails) {
                            productName = item.productName;
                          } else {
                            final product = _products[item.productIdString];
                            productName = product?.name ??
                                'Produit #${item.productIdString.substring(item.productIdString.length - 8)}';
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '$productName (x${item.quantity})',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: themedColor(
                                          context,
                                          TColors.textSecondary,
                                          TColors.textWhite),
                                    ),
                                  ),
                                ),
                                Text(
                                  item.formattedSubtotal,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: themedColor(context,
                                        TColors.textPrimary, TColors.textWhite),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: themedColor(context, TColors.textPrimary,
                                    TColors.textWhite),
                              ),
                            ),
                            Text(
                              order.formattedTotal,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: TColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100), // Extra space for scrolling
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
