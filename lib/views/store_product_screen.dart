import 'package:flutter/material.dart';
import '../utils/constants/colors.dart';
import '../utils/widgets/custom_app_bar.dart';
import '../utils/widgets/screen_container.dart';
import '../utils/widgets/vendor_product_card.dart';
import '../models/product.dart';

class StoreProductScreen extends StatelessWidget {
  const StoreProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the static products from your Product model
    final products = Product.staticProducts;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.add, color: TColors.black),
                onPressed: () {
                  // Handle add product
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
              title: 'Products',
              child: Column(
                children: [
                  // Product management header
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(Icons.inventory,
                              size: 60, color: TColors.primary),
                          SizedBox(height: 16),
                          Text(
                            'Product Management',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Manage your product catalog, add new products, and update existing ones.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Products Grid or Empty State
                  products.isEmpty
                      ? Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.inventory_2_outlined,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No products yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Start by adding your first product to your catalog.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // Handle add first product
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Product'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: TColors.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return VendorProductCard(
                              productId: product.id,
                              imageUrl: product.imageUrls.isNotEmpty
                                  ? product.imageUrls.first
                                  : 'https://via.placeholder.com/150',
                              name: product.name,
                              price: product.price,
                              regularPrice: product.regularPrice,
                              inStock: product.inStock,
                              sku: product.sku ?? '',
                              onEdit: () {
                                // Handle edit product
                                print(
                                    'Edit product ${product.id}: ${product.name}');
                              },
                              onDelete: () {
                                // Handle delete product
                                print(
                                    'Delete product ${product.id}: ${product.name}');
                              },
                              onToggleStatus: () {
                                // Handle toggle product status
                                print(
                                    'Toggle status for product ${product.id}: ${product.name}');
                              },
                            );
                          },
                        ),
                  const SizedBox(height: 300), // Extra space for scrolling
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
