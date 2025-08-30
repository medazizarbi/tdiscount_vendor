import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/constants/colors.dart';
import '../utils/widgets/custom_app_bar.dart';
import '../utils/widgets/screen_container.dart';
import '../viewmodels/dashboard_viewmodel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize dashboard data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DashboardViewModel>(
        builder: (context, viewModel, child) {
          return CustomScrollView(
            slivers: [
              CustomSliverAppBar(
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: TColors.black),
                    onPressed: () => viewModel.refreshDashboard(),
                  ),
                ],
                showThemeToggle: true,
                pinned: true,
                floating: false,
                snap: false,
              ),
              SliverToBoxAdapter(
                child: ScreenContainer(
                  title: 'Tableau de Bord',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Error handling
                      if (viewModel.hasError) _buildErrorWidget(viewModel),

                      // Period Selector
                      _buildPeriodSelector(viewModel),
                      const SizedBox(height: 20),

                      // Sales Analytics Section
                      _buildSectionTitle('Analyses des Ventes'),
                      const SizedBox(height: 12),
                      _buildSalesAnalytics(viewModel),
                      const SizedBox(height: 20),

                      // Sales Chart Section
                      _buildSectionTitle('Tendance des Ventes'),
                      const SizedBox(height: 12),
                      _buildSalesChart(viewModel),
                      const SizedBox(height: 20),

                      // Orders Section
                      _buildSectionTitle('Aperçu des Commandes'),
                      const SizedBox(height: 12),
                      _buildOrdersSection(viewModel),
                      const SizedBox(height: 20),

                      // Products Section
                      _buildSectionTitle('Performance des Produits'),
                      const SizedBox(height: 12),
                      _buildProductsSection(viewModel),

                      const SizedBox(height: 50), // Bottom spacing
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(DashboardViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Erreur',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                Text(
                  _getUserFriendlyErrorMessage(viewModel.error),
                  style: TextStyle(color: Colors.red.shade600),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => viewModel.clearError(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  // Add this helper method
  String _getUserFriendlyErrorMessage(String? error) {
    if (error == null) return 'Une erreur inattendue est survenue';

    // Convert technical errors to user-friendly messages
    final lowerError = error.toLowerCase();

    if (lowerError.contains('network') ||
        lowerError.contains('connection') ||
        lowerError.contains('timeout') ||
        lowerError.contains('unreachable')) {
      return 'Problème de connexion réseau. Vérifiez votre connexion internet.';
    }

    if (lowerError.contains('unauthorized') ||
        lowerError.contains('401') ||
        lowerError.contains('forbidden') ||
        lowerError.contains('403')) {
      return 'Session expirée. Veuillez vous reconnecter.';
    }

    if (lowerError.contains('not found') || lowerError.contains('404')) {
      return 'Ressource non trouvée. Veuillez réessayer.';
    }

    if (lowerError.contains('server') ||
        lowerError.contains('500') ||
        lowerError.contains('502') ||
        lowerError.contains('503') ||
        lowerError.contains('504')) {
      return 'Problème technique temporaire. Veuillez réessayer dans quelques instants.';
    }

    if (lowerError.contains('bad request') || lowerError.contains('400')) {
      return 'Requête invalide. Veuillez rafraîchir la page.';
    }

    if (lowerError.contains('format') ||
        lowerError.contains('parse') ||
        lowerError.contains('json')) {
      return 'Erreur de format des données. Veuillez réessayer.';
    }

    if (lowerError.contains('permission') || lowerError.contains('access')) {
      return 'Vous n\'avez pas les permissions nécessaires pour cette action.';
    }

    if (lowerError.contains('rate limit') ||
        lowerError.contains('too many requests')) {
      return 'Trop de requêtes. Veuillez patienter avant de réessayer.';
    }

    // For any other error, return a generic message
    return 'Une erreur est survenue. Veuillez réessayer ou contacter le support si le problème persiste.';
  }

  Widget _buildPeriodSelector(DashboardViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.date_range, color: TColors.primary),
            const SizedBox(width: 12),
            const Text(
              'Période:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: viewModel.availablePeriods.map((period) {
                    final isSelected = viewModel.selectedPeriod == period;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(viewModel.getPeriodDisplayText(period)),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            viewModel.changePeriod(period);
                          }
                        },
                        selectedColor: TColors.primary.withOpacity(0.2),
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[800]
                                : Colors.grey[100],
                        labelStyle: TextStyle(
                          color: isSelected
                              ? TColors.primary
                              : Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).brightness == Brightness.dark
            ? TColors.primary
            : Colors.black,
      ),
    );
  }

  Widget _buildSalesAnalytics(DashboardViewModel viewModel) {
    if (viewModel.isStatsLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Column(
      children: [
        // Top row - Main metrics
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.monetization_on,
                title: 'Ventes Totales',
                value: '${viewModel.totalSales.toStringAsFixed(2)} TND',
                subtitle:
                    '+${viewModel.getGrowthPercentage()}% vs dernière ${viewModel.selectedPeriod}',
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.shopping_cart,
                title: 'Commandes Totales',
                value: '${viewModel.totalOrders}',
                subtitle: '${viewModel.completedOrders} terminées',
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Bottom row - Additional metrics
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.trending_up,
                title: 'Valeur Moy. Commande',
                value: '${viewModel.averageOrderValue.toStringAsFixed(2)} TND',
                subtitle: 'Par commande',
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.percent,
                title: 'Taux de Réussite',
                value:
                    '${viewModel.getOrderCompletionRate().toStringAsFixed(1)}%',
                subtitle: 'Taux de succès',
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesChart(DashboardViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.show_chart, color: TColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Ventes pour ${viewModel.getPeriodDisplayText(viewModel.selectedPeriod)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                if (viewModel.isSalesChartLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[900]
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? TColors.primary.withOpacity(0.5)
                      : TColors.primary.withOpacity(0.3),
                ),
              ),
              child: viewModel.isSalesChartLoading
                  ? const Center(child: CircularProgressIndicator())
                  : viewModel.hasSalesChart
                      ? _buildLineChart(viewModel)
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.bar_chart,
                                size: 60,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[600]
                                    : Colors.grey,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Aucune Donnée de Vente Disponible',
                                style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[400]
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
            if (viewModel.hasSalesChart) ...[
              const SizedBox(height: 12),
              _buildChartLegend(viewModel),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(DashboardViewModel viewModel) {
    final salesData = viewModel.salesChart?.salesData ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (salesData.isEmpty) {
      return Center(
        child: Text(
          'Aucune donnée à afficher',
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey,
          ),
        ),
      );
    }

    // Prepare data points
    List<FlSpot> spots = [];
    double maxY = 0;
    double minY = double.infinity;

    for (int i = 0; i < salesData.length; i++) {
      final sales = salesData[i].totalSales;
      spots.add(FlSpot(i.toDouble(), sales));
      if (sales > maxY) maxY = sales;
      if (sales < minY) minY = sales;
    }

    // Add padding to values
    final padding = (maxY - minY) * 0.1;
    maxY = maxY + padding;
    minY = (minY - padding).clamp(0.0, double.infinity);

    if (maxY == minY) {
      maxY = minY + 100;
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: (maxY - minY) / 4,
          verticalInterval: salesData.length > 10 ? 2 : 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: isDark
                  ? Colors.grey.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: isDark
                  ? Colors.grey.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
              dashArray: [3, 3],
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              interval: salesData.length > 15 ? 3 : 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                final index = value.toInt();
                if (index >= 0 && index < salesData.length) {
                  final date = DateTime.parse(salesData[index].date);
                  String displayText =
                      _getChartLabelText(date, viewModel.selectedPeriod);

                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Transform.rotate(
                      angle: salesData.length > 10 ? -0.5 : 0,
                      child: Text(
                        displayText,
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                          fontSize: salesData.length > 15 ? 8 : 10,
                        ),
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (maxY - minY) / 4,
              reservedSize: 50,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  _formatCurrency(value),
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: isDark
                ? Colors.grey.withOpacity(0.3)
                : Colors.grey.withOpacity(0.4),
            width: 1,
          ),
        ),
        minX: 0,
        maxX: (salesData.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            gradient: LinearGradient(
              colors: [
                TColors.primary,
                TColors.primary.withOpacity(0.7),
                TColors.primary.withOpacity(0.5),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: TColors.primary,
                  strokeWidth: 3,
                  strokeColor: isDark ? Colors.grey[900]! : Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  TColors.primary.withOpacity(0.4),
                  TColors.primary.withOpacity(0.2),
                  TColors.primary.withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            shadow: Shadow(
              color: TColors.primary.withOpacity(0.3),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) =>
                isDark ? Colors.grey[800]! : TColors.primary.withOpacity(0.9),
            tooltipRoundedRadius: 12,
            tooltipPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            tooltipMargin: 8,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final index = barSpot.x.toInt();
                if (index >= 0 && index < salesData.length) {
                  final data = salesData[index];
                  final date = DateTime.parse(data.date);
                  return LineTooltipItem(
                    '📅 ${_formatTooltipDate(date, viewModel.selectedPeriod)}\n',
                    TextStyle(
                      color: isDark ? Colors.white : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(
                        text: '💰 ${data.totalSales.toStringAsFixed(0)} TND\n',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text:
                            '📦 ${data.orderCount} commande${data.orderCount > 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  );
                }
                return null;
              }).toList();
            },
          ),
          touchCallback:
              (FlTouchEvent event, LineTouchResponse? touchResponse) {
            // Add haptic feedback on touch
            if (event is FlTapUpEvent &&
                touchResponse?.lineBarSpots?.isNotEmpty == true) {
              // You can add HapticFeedback.lightImpact(); here if needed
            }
          },
          handleBuiltInTouches: true,
        ),
      ),
    );
  }

  // Helper methods for better formatting
  String _getChartLabelText(DateTime date, String period) {
    switch (period) {
      case 'day':
        return '${date.hour}h';
      case 'week':
        return _getDayName(date.weekday);
      case 'month':
        return '${date.day}';
      case 'year':
        return _getMonthName(date.month);
      default:
        return '${date.day}';
    }
  }

  String _formatTooltipDate(DateTime date, String period) {
    switch (period) {
      case 'day':
        return '${date.hour}:00';
      case 'week':
        return '${_getDayName(date.weekday)} ${date.day}/${date.month}';
      case 'month':
        return '${date.day}/${date.month}/${date.year}';
      case 'year':
        return '${_getMonthName(date.month)} ${date.year}';
      default:
        return _formatDate(date);
    }
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }

  Widget _buildChartLegend(DashboardViewModel viewModel) {
    final salesData = viewModel.salesChart?.salesData ?? [];
    final totalSales =
        salesData.fold<double>(0, (sum, data) => sum + data.totalSales);
    final totalOrders =
        salesData.fold<int>(0, (sum, data) => sum + data.orderCount);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem(
            icon: Icons.trending_up,
            label: 'Ventes Totales',
            value: '${totalSales.toStringAsFixed(0)} TND',
            color: TColors.primary,
          ),
          _buildLegendItem(
            icon: Icons.shopping_cart,
            label: 'Commandes Totales',
            value: totalOrders.toString(),
            color: Colors.blue,
          ),
          if (salesData.isNotEmpty)
            _buildLegendItem(
              icon: Icons.calendar_today,
              label: 'Période',
              value:
                  '${salesData.length} ${_getPeriodUnit(viewModel.selectedPeriod)}',
              color: Colors.orange,
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersSection(DashboardViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Column(
      children: [
        // Order status distribution
        Row(
          children: [
            Expanded(
              child: _buildOrderStatusCard(
                  'En Attente', viewModel.pendingOrders, Colors.orange),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildOrderStatusCard(
                  'En Cours', viewModel.processingOrders, Colors.blue),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildOrderStatusCard(
                  'Terminées', viewModel.completedOrders, Colors.green),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildOrderStatusCard(
                  'Annulées', viewModel.cancelledOrders, Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Recent orders
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long, color: TColors.primary),
                    const SizedBox(width: 8),
                    const Text(
                      'Commandes Récentes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    if (viewModel.isRecentOrdersLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (viewModel.hasRecentOrders)
                  ...viewModel.recentOrders!.recentOrders
                      .take(5)
                      .map((order) => _buildOrderItem(order))
                      .toList()
                else
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'Aucune commande récente',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // Navigate to orders screen
                    },
                    child: const Text('Voir Toutes les Commandes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderStatusCard(String status, int count, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getOrderStatusIcon(status),
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              status,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getOrderStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'en attente':
        return Icons.pending;
      case 'en cours':
        return Icons.sync;
      case 'terminées':
        return Icons.check_circle;
      case 'annulées':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Widget _buildOrderItem(dynamic order) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.customerName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  order.id.substring(0, 8),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text('${order.totalAmount.toStringAsFixed(2)} TND'),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getStatusColor(order.status).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              order.status,
              style: TextStyle(
                fontSize: 10,
                color: _getStatusColor(order.status),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'terminée':
      case 'completed':
        return Colors.green;
      case 'en cours':
      case 'processing':
        return Colors.blue;
      case 'en attente':
      case 'pending':
        return Colors.orange;
      case 'annulée':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildProductsSection(DashboardViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Column(
      children: [
        // Product stats
        Row(
          children: [
            Expanded(
              child: _buildProductStatCard(
                'Produits Totaux',
                '${viewModel.totalProducts}',
                Icons.inventory,
                TColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildProductStatCard(
                'Actifs',
                '${viewModel.activeProducts}',
                Icons.check_circle,
                Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildProductStatCard(
                'Inactifs',
                '${viewModel.inactiveProducts}',
                Icons.pause_circle,
                Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Top products
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: TColors.primary),
                    const SizedBox(width: 8),
                    const Text(
                      'Meilleurs Produits',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    if (viewModel.isTopProductsLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (viewModel.hasTopProducts)
                  ...viewModel.topProducts!.topProducts
                      .asMap()
                      .entries
                      .map((entry) =>
                          _buildTopProductItem(entry.key, entry.value))
                      .toList()
                else
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'Aucune donnée de produits populaires',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // Navigate to products screen
                    },
                    child: const Text('Voir Tous les Produits'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductItem(int index, dynamic product) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: TColors.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: TColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${product.totalSold} vendus • ${product.totalRevenue.toStringAsFixed(0)} TND',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getDayName(int weekday) {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Juin',
      'Juil',
      'Août',
      'Sep',
      'Oct',
      'Nov',
      'Déc'
    ];
    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getPeriodUnit(String period) {
    switch (period) {
      case 'day':
        return 'heures';
      case 'week':
        return 'jours';
      case 'month':
        return 'jours';
      case 'year':
        return 'mois';
      default:
        return 'points';
    }
  }
}
