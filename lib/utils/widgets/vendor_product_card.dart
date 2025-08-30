import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../../models/product.dart';

class VendorProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onTap;

  const VendorProductCard({
    super.key,
    required this.product,
    this.onEdit,
    this.onDelete,
    this.onToggleStatus,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: themedColor(context, TColors.cardlight, TColors.carddark),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: themedColor(context, TColors.black.withOpacity(0.1),
                  TColors.black.withOpacity(0.3)),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        product.images.isNotEmpty
                            ? product.images.first
                            : 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=150&h=150&fit=crop', // Better placeholder
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 120,
                          height: 120,
                          color: themedColor(
                              context, TColors.lightGrey, TColors.darkerGrey),
                          child: Icon(
                            Icons.inventory,
                            size: 40,
                            color: themedColor(
                                context, TColors.darkGrey, TColors.grey),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Product Name
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: themedColor(
                          context, TColors.textPrimary, TColors.textWhite),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),

                  // Price Row
                  Row(
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(3)} TND',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: themedColor(
                              context, TColors.black, TColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Stock Status - TRANSLATED
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2,
                        size: 14,
                        color:
                            product.inStock ? TColors.success : TColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.inStock
                            ? 'En Stock (${product.stock})'
                            : 'Rupture de Stock',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              product.inStock ? TColors.success : TColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onEdit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.primary,
                            foregroundColor: TColors.black,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            minimumSize: const Size(0, 28),
                          ),
                          child: const Text(
                            'Modifier',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onToggleStatus,
                        icon: Icon(
                          product.isActive
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: product.isActive
                              ? TColors.success
                              : themedColor(context, TColors.buttonSecondary,
                                  TColors.darkGrey),
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                      ),
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(
                          Icons.delete,
                          color: TColors.error,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Stock Status Badge - TRANSLATED
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: product.isActive ? TColors.success : TColors.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  product.isActive ? 'Actif' : 'Inactif',
                  style: const TextStyle(
                    color: TColors.textWhite,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Low Stock Warning Badge - TRANSLATED
            if (product.stock > 0 && product.stock <= 10)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Stock Faible',
                    style: TextStyle(
                      color: TColors.textWhite,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
