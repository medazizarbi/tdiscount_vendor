import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../viewmodels/store_viewmodel.dart';
import '../utils/constants/colors.dart';
import '../utils/widgets/custom_app_bar.dart';

class CreateStoreScreen extends StatefulWidget {
  const CreateStoreScreen({super.key});

  @override
  State<CreateStoreScreen> createState() => _CreateStoreScreenState();
}

class _CreateStoreScreenState extends State<CreateStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _websiteController = TextEditingController();

  File? _logoFile;
  File? _bannerFile;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Color themedColor(BuildContext context, Color lightColor, Color darkColor) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkColor
        : lightColor;
  }

  Future<void> _pickLogoImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _logoFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickBannerImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _bannerFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _createStore() async {
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

    final success = await storeViewModel.createStore(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      logoFile: _logoFile,
      bannerFile: _bannerFile,
      socialLinks: socialLinks,
    );

    if (success && mounted) {
      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Magasin créé avec succès!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(storeViewModel.errorMessage ??
              'Erreur lors de la création du magasin'),
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
        minLines: maxLines > 1 ? 3 : 1,
        maxLines: maxLines > 1 ? null : maxLines,
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

  Widget _buildImagePicker({
    required String label,
    required File? imageFile,
    required VoidCallback onPick,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color:
                  themedColor(context, TColors.textPrimary, TColors.textWhite),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: ElevatedButton.icon(
            onPressed: onPick,
            icon: Icon(icon),
            label: const Text('Choisir une image'),
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            imageFile != null ? '1 sélectionnée' : 'Aucune sélectionnée',
          ),
        ),
        if (imageFile != null) ...[
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: themedColor(context, Colors.grey[100] ?? Colors.white,
                    TColors.darkerGrey),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  imageFile,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const CustomSliverAppBar(
            showBackButton: true,
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
                            'Créer un Magasin',
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
                            'Configurez votre magasin pour commencer à vendre',
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

                          // Logo Image Picker
                          _buildImagePicker(
                            label: 'Logo du magasin',
                            imageFile: _logoFile,
                            onPick: _pickLogoImage,
                            icon: Icons.image,
                          ),

                          const SizedBox(height: 20),

                          // Banner Image Picker
                          _buildImagePicker(
                            label: 'Bannière du magasin',
                            imageFile: _bannerFile,
                            onPick: _pickBannerImage,
                            icon: Icons.panorama,
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

                          // Create Store Button
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
                                      : _createStore,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: storeViewModel.isLoading
                                        ? TColors.buttonDisabled
                                        : TColors.primary,
                                    foregroundColor: Colors.black,
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
                                            Text('Création en cours...'),
                                          ],
                                        )
                                      : const Text('Créer le Magasin'),
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
                                foregroundColor: Colors.black,
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
