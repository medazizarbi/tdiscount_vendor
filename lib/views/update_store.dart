import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/store_viewmodel.dart';
import '../utils/constants/colors.dart';
import '../utils/widgets/custom_app_bar.dart';

class UpdateStoreScreen extends StatefulWidget {
  const UpdateStoreScreen({super.key});

  @override
  State<UpdateStoreScreen> createState() => _UpdateStoreScreenState();
}

class _UpdateStoreScreenState extends State<UpdateStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _logoController = TextEditingController();
  final _bannerController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _websiteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStoreData();
  }

  void _loadStoreData() {
    final storeViewModel = Provider.of<StoreViewModel>(context, listen: false);
    final storeData = storeViewModel.storeData;

    if (storeData != null) {
      _nameController.text = storeData.name;
      _descriptionController.text = storeData.description;
      _logoController.text = storeData.logo ?? '';
      _bannerController.text = storeData.banner ?? '';

      // Load social links if they exist
      if (storeData.socialLinks != null) {
        _facebookController.text = storeData.socialLinks?.facebook ?? '';
        _instagramController.text = storeData.socialLinks?.instagram ?? '';
        _websiteController.text = storeData.socialLinks?.website ?? '';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _logoController.dispose();
    _bannerController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  // Helper function for themed colors
  Color themedColor(BuildContext context, Color lightColor, Color darkColor) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkColor
        : lightColor;
  }

  Future<void> _updateStore() async {
    if (!_formKey.currentState!.validate()) return;

    final storeViewModel = Provider.of<StoreViewModel>(context, listen: false);

    // Prepare social links
    Map<String, String>? socialLinks;
    if (_facebookController.text.isNotEmpty ||
        _instagramController.text.isNotEmpty ||
        _websiteController.text.isNotEmpty) {
      socialLinks = {};
      if (_facebookController.text.isNotEmpty) {
        socialLinks['facebook'] = _facebookController.text;
      }
      if (_instagramController.text.isNotEmpty) {
        socialLinks['instagram'] = _instagramController.text;
      }
      if (_websiteController.text.isNotEmpty) {
        socialLinks['website'] = _websiteController.text;
      }
    }

    final success = await storeViewModel.updateStore(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      logo: _logoController.text.trim().isEmpty
          ? null
          : _logoController.text.trim(),
      banner: _bannerController.text.trim().isEmpty
          ? null
          : _bannerController.text.trim(),
      socialLinks: socialLinks,
    );

    if (success && mounted) {
      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Magasin mis à jour avec succès!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(storeViewModel.errorMessage ??
              'Erreur lors de la mise à jour du magasin'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    String? Function(String?)? validator,
    int maxLines = 1,
    String? hintText,
  }) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: themedColor(context, TColors.cardlight, TColors.carddark),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: themedColor(
              context,
              TColors.black.withOpacity(0.05),
              TColors.black.withOpacity(0.2),
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        minLines:
            maxLines > 1 ? 3 : 1, // Start with 3 lines for multi-line fields
        maxLines: maxLines > 1
            ? null
            : maxLines, // Allow unlimited expansion for multi-line
        style: TextStyle(
          color: themedColor(context, TColors.textPrimary, TColors.textWhite),
        ),
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          labelStyle: TextStyle(
            color:
                themedColor(context, TColors.textSecondary, TColors.darkGrey),
          ),
          hintStyle: TextStyle(
            color:
                themedColor(context, TColors.textSecondary, TColors.darkGrey),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: TColors.primary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: maxLines > 1 ? 16 : 16,
          ),
          alignLabelWithHint: maxLines > 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const CustomSliverAppBar(
            showThemeToggle: true,
            pinned: false,
            floating: true,
            snap: true,
          ),
          SliverToBoxAdapter(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 25),

                          // Title
                          Text(
                            'Modifier le Magasin',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: themedColor(context, TColors.textPrimary,
                                  TColors.textWhite),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 10),

                          Text(
                            'Modifiez les informations de votre magasin',
                            style: TextStyle(
                              fontSize: 16,
                              color: themedColor(context, TColors.textSecondary,
                                  TColors.darkGrey),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 35),

                          // Store Name (Required)
                          _buildTextFormField(
                            controller: _nameController,
                            labelText: 'Nom du magasin *',
                            prefixIcon: Icons.store,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer le nom du magasin';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Store Description (Required)
                          _buildTextFormField(
                            controller: _descriptionController,
                            labelText: 'Description *',
                            prefixIcon: Icons.description,
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer une description';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Logo URL (Optional)
                          _buildTextFormField(
                            controller: _logoController,
                            labelText: 'URL du logo',
                            prefixIcon: Icons.image,
                            hintText: 'https://exemple.com/logo.png',
                          ),

                          const SizedBox(height: 20),

                          // Banner URL (Optional)
                          _buildTextFormField(
                            controller: _bannerController,
                            labelText: 'URL de la bannière',
                            prefixIcon: Icons.panorama,
                            hintText: 'https://exemple.com/banniere.png',
                          ),

                          const SizedBox(height: 30),

                          // Social Links Section Title
                          Text(
                            'Liens sociaux',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: themedColor(context, TColors.textPrimary,
                                  TColors.textWhite),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Facebook
                          _buildTextFormField(
                            controller: _facebookController,
                            labelText: 'Facebook',
                            prefixIcon: Icons.facebook,
                            hintText: 'https://facebook.com/votre-page',
                          ),

                          const SizedBox(height: 20),

                          // Instagram
                          _buildTextFormField(
                            controller: _instagramController,
                            labelText: 'Instagram',
                            prefixIcon: Icons.camera_alt,
                            hintText: 'https://instagram.com/votre-compte',
                          ),

                          const SizedBox(height: 20),

                          // Website
                          _buildTextFormField(
                            controller: _websiteController,
                            labelText: 'Site web',
                            prefixIcon: Icons.language,
                            hintText: 'https://votre-site.com',
                          ),

                          const SizedBox(height: 30),

                          // Update Store Button
                          Container(
                            width: 320,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: TColors.primary.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Consumer<StoreViewModel>(
                              builder: (context, storeViewModel, child) {
                                return ElevatedButton(
                                  onPressed: storeViewModel.isLoading
                                      ? null
                                      : _updateStore,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: storeViewModel.isLoading
                                        ? TColors.buttonDisabled
                                        : TColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: storeViewModel.isLoading
                                      ? const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            Text('Mise à jour en cours...'),
                                          ],
                                        )
                                      : const Text('Mettre à jour le Magasin'),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Cancel Button
                          SizedBox(
                            width: 320,
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                backgroundColor: TColors.secondary,
                              ),
                              child: const Text(
                                'Annuler',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
