import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../../models/order.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

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
        return Colors.orange; // Default to pending color
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: themedColor(context, Colors.white, TColors.carddark),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Order ID and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Commande #${order.id.substring(order.id.length - 8)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: themedColor(context, TColors.textPrimary,
                                TColors.textWhite),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDateTime(order.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: themedColor(
                                context, Colors.grey[600]!, Colors.grey[400]!),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getStatusText(order.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Customer Information
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      themedColor(context, Colors.grey[50]!, Colors.grey[800]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 20,
                      color: themedColor(
                          context, TColors.primary, TColors.primary),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.customerName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: themedColor(context, TColors.textPrimary,
                                  TColors.textWhite),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            order.customerEmail,
                            style: TextStyle(
                              fontSize: 12,
                              color: themedColor(context, Colors.grey[600]!,
                                  Colors.grey[400]!),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Order Items Summary
              Row(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 18,
                    color: themedColor(
                        context, Colors.grey[600]!, Colors.grey[400]!),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${order.totalItems} article${order.totalItems > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 13,
                        color: themedColor(
                            context, Colors.grey[600]!, Colors.grey[400]!),
                      ),
                    ),
                  ),
                  // Total Amount
                  Text(
                    order.formattedTotal,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themedColor(
                          context, TColors.primary, TColors.primary),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Items Preview (show first few items)
              if (order.items.isNotEmpty) ...[
                const Divider(height: 16),
                Text(
                  'Articles:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: themedColor(
                        context, Colors.grey[700]!, Colors.grey[300]!),
                  ),
                ),
                const SizedBox(height: 4),
                ...order.items.take(2).map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Text(
                            '• ',
                            style: TextStyle(
                              color: themedColor(
                                  context, TColors.primary, TColors.primary),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${item.productName} (x${item.quantity})',
                              style: TextStyle(
                                fontSize: 12,
                                color: themedColor(context, Colors.grey[600]!,
                                    Colors.grey[400]!),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            item.formattedSubtotal,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: themedColor(context, TColors.textPrimary,
                                  TColors.textWhite),
                            ),
                          ),
                        ],
                      ),
                    )),
                if (order.items.length > 2)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '... et ${order.items.length - 2} autre${order.items.length - 2 > 1 ? 's' : ''} article${order.items.length - 2 > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: themedColor(
                            context, Colors.grey[500]!, Colors.grey[500]!),
                      ),
                    ),
                  ),
              ],

              // Action indicator
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Appuyer pour voir les détails',
                    style: TextStyle(
                      fontSize: 11,
                      color: themedColor(
                          context, TColors.primary, TColors.primary),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color:
                        themedColor(context, TColors.primary, TColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
