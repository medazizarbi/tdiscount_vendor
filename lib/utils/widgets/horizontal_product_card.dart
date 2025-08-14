import 'package:flutter/material.dart';
import 'package:tdiscount_vendor/utils/constants/colors.dart';
import '../../models/product.dart';
import '../../views/product_detail_screen.dart';

class HorizontalProductCard extends StatelessWidget {
  final Product product;
  final int quantity;

  const HorizontalProductCard({
    super.key,
    required this.product,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: themedColor(context, TColors.cardlight, TColors.dark),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                product.imageUrls.isNotEmpty
                    ? product.imageUrls.first
                    : 'https://tdiscount.tn/wp-content/uploads/2025/03/tv-condor-50-smart-ultra-hd-4k-1-1.webp',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.broken_image,
                    size: 30,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Details Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First Row: Product Name and Quantity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Expanded(
                        child: Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: themedColor(
                                context, TColors.black, Colors.white),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Quantity (aligned to right)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: themedColor(
                              context, TColors.grey, TColors.darkerGrey),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Qty: $quantity',
                          style: TextStyle(
                            color: themedColor(
                                context, TColors.textPrimary, TColors.grey),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Second Row: SKU and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // SKU
                      Text(
                        product.sku != null
                            ? 'SKU: ${product.sku}'
                            : 'SKU: N/A',
                        style: TextStyle(
                          fontSize: 14,
                          color: themedColor(
                              context, Colors.grey[600]!, Colors.grey[400]!),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      // Price (aligned to right)
                      Text(
                        product.price,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: themedColor(
                              context, TColors.black, TColors.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
