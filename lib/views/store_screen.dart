import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Add this import
import 'package:tdiscount_vendor/views/create_store.dart';
import 'package:tdiscount_vendor/views/update_store.dart';
import '../viewmodels/store_viewmodel.dart'; // Add this import
import '../utils/constants/colors.dart';
import '../utils/widgets/custom_app_bar.dart';
import '../utils/widgets/screen_container.dart';
import '../utils/widgets/show_logout_dialog.dart';
import 'store_product_screen.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const CustomSliverAppBar(
            showThemeToggle: true,
            pinned: true,
            floating: false,
            snap: false,
          ),
          SliverToBoxAdapter(
            child: Consumer<StoreViewModel>(
              builder: (context, storeViewModel, child) {
                final storeTitle = storeViewModel.storeData?.name ?? 'Store';

                return ScreenContainer(
                  title: storeTitle,
                  child: Column(
                    children: [
                      // Store header info
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Icon(
                                  storeViewModel.hasStore
                                      ? Icons.store
                                      : Icons.store_outlined,
                                  size: 60,
                                  color: storeViewModel.hasStore
                                      ? TColors.primary
                                      : Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                storeViewModel.hasStore
                                    ? 'Gestion du Magasin'
                                    : 'Aucun Magasin',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                storeViewModel.hasStore
                                    ? 'Gérez vos produits, inventaire et paramètres du magasin.'
                                    : 'Vous n\'avez pas encore de magasin. Créez votre magasin pour commencer à vendre vos produits.',
                                textAlign: TextAlign.center,
                              ),

                              // Show Create Store button if no store
                              if (!storeViewModel.hasStore) ...[
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: storeViewModel.isLoading
                                      ? null
                                      : () {
                                          // Navigate to create store screen
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const CreateStoreScreen(),
                                            ),
                                          );
                                        },
                                  icon: const Icon(Icons.add_business),
                                  label: const Text('Créer un Magasin'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: TColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Only show store options if user has a store
                      if (storeViewModel.hasStore) ...[
                        // Store options menu
                        Card(
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.inventory,
                                    color: TColors.primary),
                                title: const Text('Produits'),
                                subtitle: const Text(
                                    'Gérer votre catalogue de produits'),
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
                                leading: const Icon(Icons.storefront,
                                    color: TColors.primary),
                                title: const Text('Paramètres du Magasin'),
                                subtitle: const Text(
                                    'Modifier les détails du magasin'),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const UpdateStoreScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Quick stats - only show if user has a store
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
                                      Text('Produits'),
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
                                      Icon(Icons.visibility,
                                          color: TColors.primary),
                                      SizedBox(height: 8),
                                      Text('Vues'),
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
                      ] else ...[
                        // Show a placeholder card when no store exists
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Commencez votre voyage',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Créez votre magasin pour débloquer toutes les fonctionnalités et commencer à vendre vos produits.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),
                      TextButton.icon(
                        onPressed: () {
                          showLogoutDialog(
                              context); // Use the imported function
                        },
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text(
                          'Déconnexion',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
