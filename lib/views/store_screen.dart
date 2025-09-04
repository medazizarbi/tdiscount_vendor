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
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    child: Column(
                      children: [
                        // Store header info
                        // Store header info
                        if (!storeViewModel.hasStore)
                          Card(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? TColors.dark
                                    : Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.store_outlined,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Aucun Magasin',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Vous n\'avez pas encore de magasin. Créez votre magasin pour commencer à vendre vos produits.',
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: storeViewModel.isLoading
                                        ? null
                                        : () {
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
                              ),
                            ),
                          ),
                        if (storeViewModel.hasStore &&
                            storeViewModel.storeData != null) ...[
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? TColors.dark
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Banner (only if exists)
                                if (storeViewModel.storeData!.banner != null &&
                                    storeViewModel
                                        .storeData!.banner!.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                    child: Image.network(
                                      storeViewModel.storeData!.banner!,
                                      width: double.infinity,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),

                                // Add space if logo exists but banner does not
                                if ((storeViewModel.storeData!.logo != null &&
                                        storeViewModel
                                            .storeData!.logo!.isNotEmpty) &&
                                    (storeViewModel.storeData!.banner == null ||
                                        storeViewModel
                                            .storeData!.banner!.isEmpty))
                                  const SizedBox(height: 32),

                                // Logo (only if exists)
                                if (storeViewModel.storeData!.logo != null &&
                                    storeViewModel.storeData!.logo!.isNotEmpty)
                                  Transform.translate(
                                    offset: (storeViewModel.storeData!.banner !=
                                                null &&
                                            storeViewModel
                                                .storeData!.banner!.isNotEmpty)
                                        ? const Offset(0, -32)
                                        : Offset.zero,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: CircleAvatar(
                                        radius: 40,
                                        backgroundColor: Colors.white,
                                        backgroundImage: NetworkImage(
                                            storeViewModel.storeData!.logo!),
                                      ),
                                    ),
                                  ),

                                const SizedBox(height: 12),
                                // Store Name
                                Text(
                                  storeViewModel.storeData!.name,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: themedColor(context,
                                        TColors.textPrimary, TColors.textWhite),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Store Description
                                Text(
                                  storeViewModel.storeData!.description,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: themedColor(context,
                                        TColors.textPrimary, TColors.textWhite),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ],

                        // Only show store options if user has a store
                        if (storeViewModel.hasStore) ...[
                          // Store options menu
                          Card(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? TColors.dark
                                    : Colors.white,
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

                        const SizedBox(height: 60),
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
