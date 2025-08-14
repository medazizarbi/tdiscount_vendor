import 'package:flutter/material.dart';
import '../constants/colors.dart';

class VendorProductCard extends StatelessWidget {
  final int productId;
  final String imageUrl;
  final String name;
  final String price;
  final String? regularPrice;
  final bool inStock;
  final String sku;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleStatus;

  const VendorProductCard({
    super.key,
    required this.productId,
    required this.imageUrl,
    required this.name,
    required this.price,
    this.regularPrice,
    required this.inStock,
    required this.sku,
    this.onEdit,
    this.onDelete,
    this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 120,
                        height: 120,
                        color: themedColor(
                            context, TColors.lightGrey, TColors.darkerGrey),
                        child: Icon(
                          Icons.broken_image,
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
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: themedColor(
                        context, TColors.textPrimary, TColors.textWhite),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 4),

                // SKU
                Text(
                  'SKU: $sku',
                  style: TextStyle(
                    fontSize: 10,
                    color: themedColor(
                        context, TColors.textSecondary, TColors.darkGrey),
                  ),
                ),
                const SizedBox(height: 4),

                // Price Row
                Row(
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: themedColor(
                            context, TColors.black, TColors.primary),
                      ),
                    ),
                    if (regularPrice != null && regularPrice != price)
                      Expanded(
                        child: Text(
                          ' $regularPrice',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            decoration: TextDecoration.lineThrough,
                            decorationColor:
                                Colors.red, // Makes the line-through red
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),

                // Stock Status
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2,
                      size: 14,
                      color: inStock ? TColors.success : TColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      inStock ? 'In Stock' : 'Out of Stock',
                      style: TextStyle(
                        fontSize: 12,
                        color: inStock ? TColors.success : TColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

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
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          minimumSize: const Size(0, 32),
                        ),
                        child: const Text(
                          'Edit',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onToggleStatus,
                      icon: Icon(
                        inStock ? Icons.visibility : Icons.visibility_off,
                        color: inStock
                            ? TColors.success
                            : themedColor(context, TColors.buttonSecondary,
                                TColors.darkGrey),
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
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
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Discount Badge (if there's a price difference)
          if (regularPrice != null && regularPrice != price)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: TColors.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Sale',
                  style: TextStyle(
                    color: TColors.textWhite,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Stock Status Badge
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: inStock ? TColors.success : TColors.error,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                inStock ? 'Active' : 'Inactive',
                style: const TextStyle(
                  color: TColors.textWhite,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
