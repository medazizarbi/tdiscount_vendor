import 'package:flutter/material.dart';
import '../utils/constants/colors.dart';
import '../utils/widgets/custom_app_bar.dart';
import '../utils/widgets/screen_container.dart';
import '../utils/widgets/order_card.dart';
import '../models/order.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // For now, we'll show empty state until API integration
    final orders = <Order>[];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list, color: TColors.black),
                onPressed: () {
                  // Handle filter - show placeholder for now
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Filter feature coming soon!'),
                    ),
                  );
                },
              ),
            ],
            showThemeToggle: true,
            pinned: true,
            floating: false,
            snap: false,
          ),
          SliverToBoxAdapter(
            child: ScreenContainer(
              title: 'Orders',
              child: Column(
                children: [
                  if (orders.isEmpty) ...[
                    // Order management header
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Icon(Icons.shopping_bag,
                                size: 60, color: TColors.primary),
                            SizedBox(height: 16),
                            Text(
                              'Order Management',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Track and manage customer orders, process shipments, and handle returns.',
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
                              'No Orders Yet',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'You haven\'t received any orders yet.\nOnce customers start purchasing your products, their orders will appear here.',
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
                                // Navigate to products screen
                                //  Navigator.pop(context);
                              },
                              icon: const Icon(Icons.inventory),
                              label: const Text('Manage Products'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: TColors.primary,
                                foregroundColor: Colors.white,
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
                                // Handle refresh/check for orders
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Checking for new orders...'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh Orders'),
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
                    Card(
                      color: TColors.primary.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: TColors.primary,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Order Status Guide',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: TColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildStatusInfo('Pending',
                                'New order awaiting processing', Colors.orange),
                            _buildStatusInfo('Processing',
                                'Order is being prepared', Colors.blue),
                            _buildStatusInfo('Shipped', 'Order is on its way',
                                Colors.purple),
                            _buildStatusInfo('Completed',
                                'Order successfully delivered', Colors.green),
                            _buildStatusInfo(
                                'Cancelled', 'Order was cancelled', Colors.red),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // Orders list (for when we have orders)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return OrderCard(
                          orderNumber: order.number,
                          status: order.status,
                          dateTime: order.dateCreated,
                          totalPrice: order.total,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    OrderDetailScreen(order: order),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 300), // Extra space for scrolling
                ],
              ),
            ),
          ),
        ],
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
}
