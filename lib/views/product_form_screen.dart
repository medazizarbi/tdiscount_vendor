import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../utils/constants/colors.dart';
import '../utils/widgets/custom_app_bar.dart';
import '../utils/widgets/screen_container.dart';
import '../viewmodels/product_viewmodel.dart';
import '../models/product.dart';

class ProductFormScreen extends StatefulWidget {
  final String title;
  final Product? product; // null for create, Product for update
  final bool isEdit;

  const ProductFormScreen({
    super.key,
    required this.title,
    this.product,
    this.isEdit = false,
  });

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late ProductViewModel _productViewModel;

  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  // Images list (File)
  List<File> _images = [];

  // Existing image URLs (for edit mode)
  List<String> _existingImageUrls = [];

  // Status selection
  String _selectedStatus = 'active';

  // Category selection
  String? _selectedCategory;

  // Updated categories list
  final List<String> _categories = [
    'Électronique',
    'Vêtements',
    'Livres',
    'Maison & Jardin',
    'Sports',
    'Beauté',
    'Jouets',
    'Automobile',
    'Alimentation & Boissons',
    'Santé',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    _productViewModel = Provider.of<ProductViewModel>(context, listen: false);

    // If editing, populate fields with existing product data
    if (widget.isEdit && widget.product != null) {
      _populateFields(widget.product!);
    }
  }

  void _populateFields(Product product) {
    _nameController.text = product.name;
    _descriptionController.text = product.description ?? '';
    _priceController.text = product.price.toString();
    _stockController.text = product.stock.toString();

    // Handle category mapping - if existing category doesn't match, set to 'Autre'
    if (product.category != null && _categories.contains(product.category)) {
      _selectedCategory = product.category;
    } else {
      _selectedCategory = 'Autre'; // Default fallback
    }

    _selectedStatus = product.status;

    // Populate existing image URLs if available
    _existingImageUrls = product.images;
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catégorie',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: themedColor(context, TColors.textPrimary, TColors.textWhite),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: InputDecoration(
            hintText: 'Sélectionner une catégorie',
            prefixIcon: const Icon(Icons.category, color: TColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: TColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: themedColor(
                context, Colors.grey[50] ?? Colors.white, TColors.darkerGrey),
          ),
          items: _categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(
                category,
                style: TextStyle(
                  color: themedColor(context, Colors.black, Colors.white),
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedCategory = newValue;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez sélectionner une catégorie';
            }
            return null;
          },
          dropdownColor: themedColor(context, Colors.white, TColors.carddark),
          icon: Icon(
            Icons.arrow_drop_down,
            color: themedColor(context, Colors.grey[600] ?? Colors.grey,
                Colors.grey[400] ?? Colors.grey),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(
            title: widget.title,
            showBackButton: true,
            showThemeToggle: true,
            pinned: false,
            floating: true,
            snap: false,
          ),
          SliverToBoxAdapter(
            child: ScreenContainer(
              title: widget.title,
              child: Consumer<ProductViewModel>(
                builder: (context, productVM, child) {
                  return Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // Product Name
                        _buildTextField(
                          controller: _nameController,
                          label: 'Nom du Produit',
                          hint: 'Entrez le nom du produit',
                          icon: Icons.inventory,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Le nom du produit est requis';
                            }
                            if (value.trim().length < 2) {
                              return 'Le nom du produit doit contenir au moins 2 caractères';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Description
                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Description',
                          hint: 'Entrez la description du produit',
                          icon: Icons.description,
                          maxLines: 4,
                          validator: (value) {
                            // Optional field
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Price and Stock Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _priceController,
                                label: 'Prix (TND)',
                                hint: '0.00',
                                icon: Icons.attach_money,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Le prix est requis';
                                  }
                                  final price = double.tryParse(value.trim());
                                  if (price == null || price < 0) {
                                    return 'Entrez un prix valide';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                controller: _stockController,
                                label: 'Quantité en Stock',
                                hint: '0',
                                icon: Icons.inventory_2,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Le stock est requis';
                                  }
                                  final stock = int.tryParse(value.trim());
                                  if (stock == null || stock < 0) {
                                    return 'Entrez un stock valide';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Category Dropdown
                        _buildCategoryDropdown(),
                        const SizedBox(height: 16),

                        // Status Selection
                        _buildStatusSelection(),
                        const SizedBox(height: 20),

                        // Image Picker Section
                        _buildImageSection(),
                        const SizedBox(height: 24),

                        // Submit Button
                        _buildSubmitButton(productVM),
                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: TColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: themedColor(
            context, Colors.grey[50] ?? Colors.white, TColors.darkerGrey),
      ),
    );
  }

  Widget _buildStatusSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statut du Produit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: themedColor(context, TColors.textPrimary, TColors.textWhite),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: themedColor(
                context, Colors.grey[50] ?? Colors.white, TColors.darkerGrey),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedStatus = 'active';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedStatus == 'active'
                          ? TColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: _selectedStatus == 'active'
                              ? Colors.black
                              : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Actif',
                          style: TextStyle(
                            color: _selectedStatus == 'active'
                                ? Colors.black
                                : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedStatus = 'inactive';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedStatus == 'inactive'
                          ? Colors.grey[600]
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pause_circle,
                          color: _selectedStatus == 'inactive'
                              ? Colors.white
                              : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Inactif',
                          style: TextStyle(
                            color: _selectedStatus == 'inactive'
                                ? Colors.white
                                : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Images du Produit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: themedColor(context, TColors.textPrimary, TColors.textWhite),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.photo_library),
              label: const Text('Choisir des images'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(width: 8),
            Text(
                '${_images.length + _existingImageUrls.length} sélectionnée(s)'),
          ],
        ),
        const SizedBox(height: 12),
        if (_images.isNotEmpty || _existingImageUrls.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Existing images from URLs
                ..._existingImageUrls.map((url) => Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          url,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )),
                // Newly picked images
                ..._images.asMap().entries.map((entry) {
                  int index = entry.key;
                  File image = entry.value;
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            image,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: themedColor(context, Colors.grey[100] ?? Colors.white,
                  TColors.darkerGrey),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Center(
              child: Text(
                'Aucune image sélectionnée',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images = pickedFiles.map((xfile) => File(xfile.path)).toList();
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Widget _buildSubmitButton(ProductViewModel productVM) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: productVM.isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: TColors.primary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: productVM.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              )
            : Text(
                widget.isEdit ? 'Modifier le Produit' : 'Créer le Produit',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final price = double.parse(_priceController.text.trim());
    final stock = int.parse(_stockController.text.trim());

    bool success = false;

    if (widget.isEdit && widget.product != null) {
      // Update existing product - pass ALL data (current + updated)
      success = await _productViewModel.updateProduct(
        productId: widget.product!.id,
        name: name,
        description:
            description.isNotEmpty ? description : widget.product!.description,
        price: price,
        stock: stock,
        category: _selectedCategory ?? widget.product!.category,
        images: _images.isNotEmpty ? _images : null,
        status: _selectedStatus,
      );
    } else {
      // Create new product
      success = await _productViewModel.addProduct(
        name: name,
        description: description.isNotEmpty ? description : null,
        price: price,
        stock: stock,
        category: _selectedCategory,
        images: _images,
        status: _selectedStatus,
      );
    }

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEdit
                ? 'Produit modifié avec succès!'
                : 'Produit créé avec succès!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Show generic error message instead of server error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEdit
                ? 'Une erreur est survenue lors de la modification du produit'
                : 'Une erreur est survenue lors de la création du produit',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }
}
