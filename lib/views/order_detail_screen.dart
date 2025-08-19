import 'package:flutter/material.dart';
import 'package:tdiscount_vendor/utils/widgets/horizontal_product_card.dart';
import '../utils/constants/colors.dart';
import '../utils/widgets/custom_app_bar.dart';
import '../utils/widgets/screen_container.dart';
import '../models/order.dart';

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
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'on-hold':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'refunded':
        return Colors.teal;
      case 'failed':
        return Colors.redAccent;
      default:
        return Colors.orange;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                color: themedColor(context, TColors.black, TColors.primary),
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
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: themedColor(context, TColors.black, Colors.white),
              ),
            ),
          ),
        ],
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
                onPressed: () {
                  // Handle edit order
                },
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: TColors.black),
                onPressed: () {
                  // Handle more options
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
              title: 'Order Details',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Header
                  _buildSectionCard(
                    title: 'Order Information',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order.number,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
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
                                order.status.toUpperCase(),
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
                        _buildInfoRow('Date Created:',
                            _formatDateTime(order.dateCreated)),
                        _buildInfoRow('Total:', order.total),
                        if (order.customerNote.isNotEmpty)
                          _buildInfoRow('Customer Note:', order.customerNote),
                      ],
                    ),
                  ),

                  // Line Items section
                  _buildSectionCard(
                    title: 'Products',
                    child: Column(
                      children: order.lineItems.map((orderItem) {
                        return HorizontalProductCard(
                          product: orderItem.product,
                          quantity: orderItem.quantity,
                        );
                      }).toList(),
                    ),
                  ),

                  // Billing Information
                  _buildSectionCard(
                    title: 'Billing Information',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Name:',
                            '${order.billing.firstName} ${order.billing.lastName}'),
                        _buildInfoRow('Address:', order.billing.address1),
                        _buildInfoRow('City:', order.billing.city),
                        _buildInfoRow('Email:', order.billing.email),
                        _buildInfoRow('Phone:', order.billing.phone),
                      ],
                    ),
                  ),

                  // Shipping Information
                  _buildSectionCard(
                    title: 'Shipping Information',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Name:',
                            '${order.shipping.firstName} ${order.shipping.lastName}'),
                        _buildInfoRow('Address:', order.shipping.address1),
                        _buildInfoRow('City:', order.shipping.city),
                        _buildInfoRow('Email:', order.shipping.email),
                        _buildInfoRow('Phone:', order.shipping.phone),
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
