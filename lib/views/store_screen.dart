import 'package:flutter/material.dart';
import '../utils/constants/colors.dart';
import '../utils/widgets/custom_app_bar.dart';
import '../utils/widgets/screen_container.dart';
import 'store_product_screen.dart'; // Add this import

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: TColors.black),
                onPressed: () {
                  // Handle settings
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
              title: 'Store',
              child: Column(
                children: [
                  // Store header info
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(Icons.store, size: 60, color: TColors.primary),
                          SizedBox(height: 16),
                          Text(
                            'Store Management',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Manage your products, inventory, and store settings.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Store options menu
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.inventory,
                              color: TColors.primary),
                          title: const Text('Products'),
                          subtitle: const Text('Manage your product catalog'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const StoreProductScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.category,
                              color: TColors.primary),
                          title: const Text('Categories'),
                          subtitle: const Text('Organize your products'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // Navigate to categories page
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.analytics,
                              color: TColors.primary),
                          title: const Text('Analytics'),
                          subtitle: const Text('View store performance'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // Navigate to analytics page
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.inventory_2,
                              color: TColors.primary),
                          title: const Text('Inventory'),
                          subtitle: const Text('Track stock levels'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // Navigate to inventory page
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.storefront,
                              color: TColors.primary),
                          title: const Text('Store Settings'),
                          subtitle: const Text('Configure store details'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // Navigate to store settings page
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quick stats
                  const Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Icon(Icons.shopping_bag,
                                    color: TColors.primary),
                                SizedBox(height: 8),
                                Text('Products'),
                                Text(
                                  '127',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Icon(Icons.visibility, color: TColors.primary),
                                SizedBox(height: 8),
                                Text('Views'),
                                Text(
                                  '1,532',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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
