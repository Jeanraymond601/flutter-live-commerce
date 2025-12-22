// lib/screens/addeditproductscreen.dart - VERSION CORRIGÉE ET SIMPLIFIÉE
// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

// Import avec alias pour éviter les conflits
import 'package:commerce/models/product.dart';
import 'package:commerce/services/product_service.dart';
import 'package:commerce/services/auth_service.dart';
import 'package:commerce/utils/constants.dart';
import 'package:commerce/widgets/custom_text_field.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  // ignore: library_private_types_in_public_api
  _AddEditProductScreenState createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late ProductService _productService;
  late AuthService _authService;

  // Contrôleurs
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _colorController = TextEditingController();
  final _sizeController = TextEditingController();

  // États
  bool _isActive = true;
  bool _isLoading = false;
  String? _generatedCode;
  String? _errorMessage;

  // Catégories suggestions
  final List<String> _categorySuggestions = Constants.commonCategories;
  List<String> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _filteredCategories = _categorySuggestions;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productService = Provider.of<ProductService>(context, listen: false);
    _authService = Provider.of<AuthService>(context, listen: false);

    _ensureAuthentication();
    _initializeForm();
  }

  Future<void> _ensureAuthentication() async {
    try {
      if (!_authService.isAuthenticated) {
        await _handleSessionExpired();
        return;
      }

      final token = _authService.authToken;
      if (token == null || token.isEmpty) {
        await _handleSessionExpired();
        return;
      }

      if (kDebugMode) {
        print(
          'Token disponible (${token.substring(0, min(token.length, 20))}...)',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur vérification authentification: $e');
      }
      await _handleSessionExpired();
    }
  }

  Future<void> _handleSessionExpired() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session expirée. Veuillez vous reconnecter.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void _initializeForm() {
    if (widget.product != null) {
      // Mode édition
      _nameController.text = widget.product!.name;
      _categoryController.text = widget.product!.categoryName;
      _descriptionController.text = widget.product!.description ?? '';
      _colorController.text = widget.product!.color ?? '';
      _sizeController.text = widget.product!.size ?? '';
      _priceController.text = widget.product!.price.toStringAsFixed(2);
      _stockController.text = widget.product!.stock.toString();
      _isActive = widget.product!.isActive;
      _generatedCode = widget.product!.codeArticle;
    } else {
      // Mode création - générer un code initial
      _categoryController.addListener(_onCategoryChanged);
      _generateInitialCode();
    }
  }

  void _generateInitialCode() {
    // Générer un code basé sur la date/heure
    final now = DateTime.now();
    final code = 'PROD-${now.millisecondsSinceEpoch.toString().substring(7)}';
    setState(() {
      _generatedCode = code;
    });
  }

  void _onCategoryChanged() {
    final category = _categoryController.text;

    // Mettre à jour les suggestions
    if (category.isNotEmpty) {
      setState(() {
        _filteredCategories = _categorySuggestions
            .where((cat) => cat.toLowerCase().contains(category.toLowerCase()))
            .toList();
      });
    } else {
      setState(() {
        _filteredCategories = _categorySuggestions;
      });
    }

    // Générer un code basé sur la catégorie (optionnel)
    if (category.isNotEmpty && widget.product == null) {
      final exampleCode = Constants.generateExampleCode(category);
      setState(() {
        _generatedCode = exampleCode;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_authService.isAuthenticated) {
      await _handleSessionExpired();
      return;
    }

    final price = double.tryParse(_priceController.text) ?? 0;
    final stock = int.tryParse(_stockController.text) ?? 0;

    // Validation basique
    final errors = <String>[];
    if (_nameController.text.isEmpty) errors.add('Le nom est obligatoire');
    if (_categoryController.text.isEmpty) {
      errors.add('La catégorie est obligatoire');
    }
    if (price <= 0) errors.add('Le prix doit être supérieur à 0');
    if (stock < 0) errors.add('Le stock ne peut pas être négatif');

    if (errors.isNotEmpty) {
      _showErrorSnackbar(errors.join('\n'));
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.product == null) {
        // Mode création
        final request = ProductCreateRequest(
          name: _nameController.text,
          categoryName: _categoryController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          color: _colorController.text.isEmpty ? null : _colorController.text,
          size: _sizeController.text.isEmpty ? null : _sizeController.text,
          price: price,
          stock: stock,
          isActive: _isActive,
        );

        final createdProduct = await _productService.createProduct(request);
        _showSuccessSnackbar(Constants.successProductCreated);

        if (mounted) {
          Navigator.pop(context, createdProduct);
        }
      } else {
        // Mode édition
        final request = ProductUpdateRequest(
          name: _nameController.text,
          categoryName: _categoryController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          color: _colorController.text.isEmpty ? null : _colorController.text,
          size: _sizeController.text.isEmpty ? null : _sizeController.text,
          price: price,
          stock: stock,
          isActive: _isActive,
        );

        final productId = widget.product!.id;
        final updatedProduct = await _productService.updateProduct(
          productId!,
          request,
        );

        _showSuccessSnackbar(Constants.successProductUpdated);

        if (mounted) {
          Navigator.pop(context, updatedProduct);
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur: ${e.toString()}';
      });

      if (e.toString().contains('401') || e.toString().contains('Session')) {
        await _handleSessionExpired();
      } else {
        _showErrorSnackbar('Erreur: $e');
      }
    }
  }

  void _showSuccessSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: Constants.snackbarDuration),
        ),
      );
    }
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: Constants.snackbarDuration),
        ),
      );
    }
  }

  Widget _buildCodeSection() {
    if (_generatedCode == null) return Container();

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const Icon(Icons.qr_code, color: Colors.blue, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Code Article',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                  Text(
                    _generatedCode!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  if (widget.product == null)
                    Text(
                      'Le code final sera généré automatiquement',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: _nameController,
            label: 'Nom du produit*',
            icon: Icons.shopping_bag,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return Constants.validationRequired;
              }
              if (value.length < 3) {
                return Constants.validationProductName;
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _categoryController,
                label: 'Catégorie*',
                icon: Icons.category,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return Constants.validationProductCategory;
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                onChanged: (value) => _onCategoryChanged(),
              ),

              if (_filteredCategories.isNotEmpty &&
                  _categoryController.text.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 4),
                    ],
                  ),
                  child: Column(
                    children: _filteredCategories
                        .take(5)
                        .map(
                          (category) => ListTile(
                            title: Text(category),
                            dense: true,
                            onTap: () {
                              setState(() {
                                _categoryController.text = category;
                                _onCategoryChanged();
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: _descriptionController,
            label: 'Description',
            icon: Icons.description,
            maxLines: 3,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _colorController,
                  label: 'Couleur',
                  icon: Icons.color_lens,
                  textInputAction: TextInputAction.next,
                  hintText: 'Ex: Noir, Rouge, Bleu...',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  controller: _sizeController,
                  label: 'Taille',
                  icon: Icons.aspect_ratio,
                  textInputAction: TextInputAction.next,
                  hintText: 'Ex: S, M, L, 42, 64GB...',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _priceController,
                  label: 'Prix*',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return Constants.validationRequired;
                    }
                    final price = double.tryParse(value);
                    if (price == null || price <= 0) {
                      return Constants.validationProductPrice;
                    }
                    return null;
                  },
                  suffixText: Constants.currencySymbol,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  controller: _stockController,
                  label: 'Stock*',
                  icon: Icons.inventory,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return Constants.validationRequired;
                    }
                    final stock = int.tryParse(value);
                    if (stock == null || stock < 0) {
                      return Constants.validationProductStock;
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text('Produit actif'),
            subtitle: const Text('Visible pour les clients'),
            value: _isActive,
            onChanged: (value) {
              setState(() {
                _isActive = value;
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),

          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _submitForm,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Icon(widget.product == null ? Icons.add : Icons.save),
            label: Text(
              _isLoading
                  ? 'Traitement...'
                  : widget.product == null
                  ? 'Créer le produit'
                  : 'Mettre à jour',
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),

        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product == null ? 'Nouveau Produit' : 'Modifier Produit',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Constants.defaultPadding),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCodeSection(),
                const SizedBox(height: 20),
                _buildFormFields(),
                const SizedBox(height: 24),
                _buildActionButtons(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _colorController.dispose();
    _sizeController.dispose();
    super.dispose();
  }
}

// Fonction helper pour min
int min(int a, int b) => a < b ? a : b;
