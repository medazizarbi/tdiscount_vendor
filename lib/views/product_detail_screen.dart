import 'package:flutter/material.dart';
import '../utils/constants/colors.dart';
import '../utils/widgets/custom_app_bar.dart';
import '../utils/widgets/screen_container.dart';
import '../utils/widgets/product_images_viewer.dart';
import '../models/product.dart';

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
  bool descriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    String? formattedShortDescription;
    if (product.shortDescription != null &&
        product.shortDescription!.isNotEmpty) {
      formattedShortDescription = product.shortDescription!
          .split('-')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .join('\n');
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: TColors.black),
                onPressed: () {
                  // Handle edit product
                },
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: TColors.black),
                onPressed: () {
                  // Handle more options
                },
              ),
            ],
            showThemeToggle: true,
            pinned: false,
            floating: true,
            snap: false,
          ),
          SliverToBoxAdapter(
            child: ScreenContainer(
              title: 'Product Details',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Product Images Viewer
                  product.imageUrls.isNotEmpty
                      ? ProductImagesViewer(imageUrls: product.imageUrls)
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
                  Row(
                    children: [
                      Text(
                        product.price,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: themedColor(
                              context, TColors.textPrimary, TColors.primary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (product.regularPrice != null)
                        Text(
                          product.regularPrice!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Colors.red,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // SKU
                  if (product.sku != null && product.sku!.isNotEmpty)
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'SKU: ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: product.sku,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Stock Status
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: product.inStock ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      product.inStock ? 'In Stock' : 'Out of Stock',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Divider(thickness: 1, color: Colors.grey),
                  const SizedBox(height: 16),

                  // Short Description
                  if (formattedShortDescription != null &&
                      formattedShortDescription.isNotEmpty) ...[
                    Text(
                      'Features:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themedColor(context, TColors.textPrimary,
                            TColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      formattedShortDescription,
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Description
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
                                child: const Text('See More'),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],

                  // No description message
                  if ((formattedShortDescription == null ||
                          formattedShortDescription.isEmpty) &&
                      (product.description == null ||
                          product.description!.isEmpty))
                    const Text(
                      'No description available.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
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
