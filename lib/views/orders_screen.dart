import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants/colors.dart';
import '../utils/widgets/custom_app_bar.dart';
import '../utils/widgets/screen_container.dart';
import '../utils/widgets/order_card.dart';
import '../viewmodels/order_viewmodel.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final ScrollController _scrollController = ScrollController();
  late OrderViewModel _orderViewModel;

  @override
  void initState() {
    super.initState();
    _orderViewModel = Provider.of<OrderViewModel>(context, listen: false);
    _scrollController.addListener(_onScroll);

    // Initialize orders when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _orderViewModel.initializeOrders();
    });
  }

  void _onScroll() {
    if (_orderViewModel.shouldLoadMore(
      _scrollController.position.pixels,
      _scrollController.position.maxScrollExtent,
    )) {
      _orderViewModel.loadMoreOrders();
    }
  }

  Future<void> _onRefresh() async {
    await _orderViewModel.refreshOrders();
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
    return Consumer<OrderViewModel>(
      builder: (context, orderVM, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filtrer les Commandes',
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
                  _buildFilterChip(
                      'Tous', null, orderVM.selectedStatus, orderVM),
                  _buildFilterChip(
                      'En Attente', 'pending', orderVM.selectedStatus, orderVM),
                  _buildFilterChip('En Cours', 'processing',
                      orderVM.selectedStatus, orderVM),
                  _buildFilterChip(
                      'Terminé', 'completed', orderVM.selectedStatus, orderVM),
                  _buildFilterChip(
                      'Annulé', 'cancelled', orderVM.selectedStatus, orderVM),
                ],
              ),

              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        orderVM.clearFilters();
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
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Fermer'),
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

  Widget _buildFilterChip(String label, String? value, String? selectedValue,
      OrderViewModel orderVM) {
    final isSelected = selectedValue == value;
    return GestureDetector(
      onTap: () {
        orderVM.applyFilters(status: value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? TColors.primary
              : themedColor(context, Colors.grey[200]!, Colors.grey[700]!),
          borderRadius: BorderRadius.circular(16),
          border:
              isSelected ? Border.all(color: TColors.primary, width: 2) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.black
                : themedColor(context, Colors.black, Colors.white),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Helper method to convert technical errors to user-friendly messages
  String _getUserFriendlyError(String? error) {
    if (error == null) return 'Une erreur inattendue s\'est produite';

    final lowerError = error.toLowerCase();

    // Network related errors
    if (lowerError.contains('network') ||
        lowerError.contains('connection') ||
        lowerError.contains('socket') ||
        lowerError.contains('timeout')) {
      return 'Problème de connexion internet. Vérifiez votre connexion et réessayez.';
    }

    // Authentication errors
    if (lowerError.contains('unauthorized') ||
        lowerError.contains('401') ||
        lowerError.contains('token') ||
        lowerError.contains('auth')) {
      return 'Session expirée. Veuillez vous reconnecter.';
    }

    // Server errors
    if (lowerError.contains('500') ||
        lowerError.contains('server') ||
        lowerError.contains('internal')) {
      return 'Problème temporaire du serveur. Veuillez réessayer dans quelques instants.';
    }

    // Not found errors
    if (lowerError.contains('404') || lowerError.contains('not found')) {
      return 'Les données demandées n\'ont pas été trouvées.';
    }

    // Rate limiting
    if (lowerError.contains('rate limit') ||
        lowerError.contains('too many requests')) {
      return 'Trop de requêtes. Veuillez patienter avant de réessayer.';
    }

    // Default generic message for any other error
    return 'Une erreur s\'est produite lors du chargement des commandes. Veuillez réessayer.';
  }

  // Helper method to format currency in TND
  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(3)} TND';
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
            ],
            showThemeToggle: true,
            pinned: false,
            floating: true,
            snap: false,
          ),
          SliverToBoxAdapter(
            child: ScreenContainer(
              title: 'Commandes',
              child: Column(
                children: [
                  Consumer<OrderViewModel>(
                    builder: (context, orderVM, child) {
                      if (orderVM.isLoading && orderVM.orders.isEmpty) {
                        return _buildLoadingState();
                      }

                      if (orderVM.error != null && orderVM.orders.isEmpty) {
                        return _buildErrorState(
                            _getUserFriendlyError(orderVM.error), orderVM);
                      }

                      if (orderVM.orders.isEmpty) {
                        return _buildEmptyState();
                      }

                      return _buildOrdersList(orderVM);
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
          Text('Chargement des commandes...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, OrderViewModel orderVM) {
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
          Text(
            error, // Now shows user-friendly error
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              orderVM.refreshOrders();
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
        // Order management header
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(Icons.shopping_bag, size: 60, color: TColors.primary),
                SizedBox(height: 16),
                Text(
                  'Gestion des Commandes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Suivez et gérez les commandes des clients, traitez les expéditions et gérez les retours.',
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
                  Icons.receipt_long_outlined,
                  size: 100,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 24),
                Text(
                  'Aucune Commande',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Vous n\'avez pas encore reçu de commandes.\nUne fois que les clients commenceront à acheter vos produits, leurs commandes apparaîtront ici.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[500],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: () {
                    _orderViewModel.refreshOrders();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Actualiser les Commandes'),
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

        // Order status info card
        _buildOrderStatusGuide(),
      ],
    );
  }

  Widget _buildOrdersList(OrderViewModel orderVM) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Column(
        children: [
          // Orders Stats
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${orderVM.totalOrders}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: TColors.primary,
                              ),
                            ),
                            const Text('Total'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${orderVM.pendingCount}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const Text('En Attente'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${orderVM.processingCount}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const Text('En Cours'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${orderVM.completedCount}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const Text('Terminé'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            // Updated to use TND formatting
                            _formatCurrency(orderVM.totalRevenue),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const Text('Revenus Totaux'),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            // Updated to use TND formatting
                            _formatCurrency(orderVM.todaysRevenue),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: TColors.primary,
                            ),
                          ),
                          const Text('Aujourd\'hui'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Filter indicator
          if (orderVM.selectedStatus != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black.withOpacity(0.05)
                    : TColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : TColors.primary,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : TColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Filtré par: ${_getStatusText(orderVM.selectedStatus!)}',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : TColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => orderVM.clearFilters(),
                    child: Icon(
                      Icons.close,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : TColors.primary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Orders List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orderVM.orders.length,
            itemBuilder: (context, index) {
              final order = orderVM.orders[index];
              return OrderCard(
                order: order,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailScreen(order: order),
                    ),
                  );
                },
              );
            },
          ),

          // Loading more indicator
          if (orderVM.isLoadingMore) ...[
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
                  Text('Chargement de plus de commandes...'),
                ],
              ),
            ),
          ],

          // Load more button
          if (orderVM.hasMoreOrders && !orderVM.isLoadingMore) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: orderVM.loadMoreOrders,
              child: const Text('Charger Plus de Commandes'),
            ),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildOrderStatusGuide() {
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
                  Icons.info_outline,
                  color: TColors.primary,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Guide des Statuts de Commande',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatusInfo('En Attente',
                'Nouvelle commande en attente de traitement', Colors.orange),
            _buildStatusInfo(
                'En Cours', 'Commande en cours de préparation', Colors.blue),
            _buildStatusInfo(
                'Terminé', 'Commande livrée avec succès', Colors.green),
            _buildStatusInfo('Annulé', 'Commande annulée', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusInfo(String status, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 4, right: 12),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'En Attente';
      case 'processing':
        return 'En Cours';
      case 'completed':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
