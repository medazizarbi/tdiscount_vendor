import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  // Image URLs list
  List<String> _imageUrls = [];
  final _imageUrlController = TextEditingController();

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

    _imageUrls = List.from(product.images);
    _selectedStatus = product.status;
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

                        // Image URLs Section
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

        // Add Image URL Field
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'URL de l\'Image',
                  hintText: 'https://exemple.com/image.jpg',
                  prefixIcon: const Icon(Icons.image, color: TColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: TColors.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: themedColor(context,
                      Colors.grey[50] ?? Colors.white, TColors.darkerGrey),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addImageUrl,
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: const Text('Ajouter'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Display existing image URLs
        if (_imageUrls.isNotEmpty) ...[
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _imageUrls.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _imageUrls[index],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image,
                              color: Colors.grey),
                        ),
                      ),
                    ),
                    title: Text(
                      _imageUrls[index],
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeImageUrl(index),
                    ),
                  ),
                );
              },
            ),
          ),
        ] else ...[
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
                'Aucune image ajoutée',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ],
    );
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

  void _addImageUrl() {
    final url = _imageUrlController.text.trim();
    if (url.isNotEmpty && !_imageUrls.contains(url)) {
      setState(() {
        _imageUrls.add(url);
        _imageUrlController.clear();
      });
    }
  }

  void _removeImageUrl(int index) {
    setState(() {
      _imageUrls.removeAt(index);
    });
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
        images: _imageUrls.isNotEmpty ? _imageUrls : widget.product!.images,
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
        images: _imageUrls,
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
    _imageUrlController.dispose();
    super.dispose();
  }
}
