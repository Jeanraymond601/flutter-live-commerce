// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../models/product.dart';
import '../../screens/addeditproductscreen.dart';
import '../../services/product_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/product.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final RefreshController _refreshController = RefreshController();
  final TextEditingController _searchController = TextEditingController();

  late ProductService _productService;
  late AuthService _authService;

  List<Product> _products = [];
  List<Product> _filteredProducts = [];

  final Map<String, int> _categoryCounts = {};
  Map<String, int> _statusCounts = {};

  bool _isLoading = true;

  String? _selectedCategory;
  String? _selectedStatus;
  String _searchQuery = '';

  Timer? _searchDebounce;
  bool _initialized = false;

  // ====================== LIFECYCLE ======================

  @override
  void initState() {
    super.initState();
    // Initialiser après le premier frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // CORRECTION: Récupérer les services ici, pas dans didChangeDependencies
    if (!_initialized) {
      _productService = context.read<ProductService>();
      _authService = context.read<AuthService>();
    }
  }

  Future<void> _init() async {
    if (_initialized) return;

    // Attendre que le widget soit monté
    if (!mounted) return;

    _initialized = true;

    if (!_authService.isAuthenticated) {
      _navigateToLogin();
      return;
    }

    await _loadProducts();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  // ====================== DATA ======================

  Future<void> _loadProducts({bool refresh = false}) async {
    try {
      await _productService.loadMyProducts();

      if (mounted) {
        _syncFromProvider();
        if (refresh) {
          _refreshController.refreshCompleted();
        }
      }
    } catch (e) {
      print('❌ Erreur chargement produits: $e');

      if (mounted) {
        if (refresh) {
          _refreshController.refreshFailed();
        }
        _showError('Erreur de chargement: $e');
      }
    }
  }

  void _syncFromProvider() {
    if (!mounted) return;

    setState(() {
      _products = List.from(_productService.products);
      _computeStats();
      _filteredProducts = _applyFilters();
    });
  }

  void _computeStats() {
    _categoryCounts.clear();
    _statusCounts = {'all': _products.length, 'actif': 0, 'inactif': 0};

    for (final p in _products) {
      p.isActive
          ? _statusCounts['actif'] = (_statusCounts['actif'] ?? 0) + 1
          : _statusCounts['inactif'] = (_statusCounts['inactif'] ?? 0) + 1;

      final cat = p.categoryName.isNotEmpty ? p.categoryName : 'Sans catégorie';
      _categoryCounts[cat] = (_categoryCounts[cat] ?? 0) + 1;
    }
  }

  List<Product> _applyFilters() {
    return _products.where((p) {
      if (_selectedStatus != null) {
        if (_selectedStatus == 'actif' && !p.isActive) return false;
        if (_selectedStatus == 'inactif' && p.isActive) return false;
      }

      if (_selectedCategory != null) {
        final cat = p.categoryName.isNotEmpty
            ? p.categoryName
            : 'Sans catégorie';
        if (cat != _selectedCategory) return false;
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return p.name.toLowerCase().contains(q) ||
            p.codeArticle.toLowerCase().contains(q) ||
            (p.description?.toLowerCase().contains(q) ?? false);
      }

      return true;
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // ====================== UI ======================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produits'), elevation: 1),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateProduct,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            if (_products.isNotEmpty) _buildStatusSection(),
            if (_products.isNotEmpty) _buildCategorySection(),
            _buildHeaderCount(),
            Expanded(child: _buildProductsList()),
          ],
        ),
      ),
    );
  }

  // ====================== WIDGETS ======================

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          _searchDebounce?.cancel();
          _searchDebounce = Timer(const Duration(milliseconds: 350), () {
            if (mounted) {
              setState(() {
                _searchQuery = value;
                _filteredProducts = _applyFilters();
              });
            }
          });
        },
        decoration: InputDecoration(
          hintText: 'Rechercher...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _statusChip(null, 'Tous', _statusCounts['all'] ?? 0),
          _statusChip('actif', 'Actifs', _statusCounts['actif'] ?? 0),
          _statusChip('inactif', 'Inactifs', _statusCounts['inactif'] ?? 0),
        ],
      ),
    );
  }

  Widget _statusChip(String? value, String label, int count) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text('$label ($count)'),
        selected: _selectedStatus == value,
        onSelected: (_) {
          if (mounted) {
            setState(() {
              _selectedStatus = _selectedStatus == value ? null : value;
              _filteredProducts = _applyFilters();
            });
          }
        },
      ),
    );
  }

  Widget _buildCategorySection() {
    final categories = _categoryCounts.entries.toList();

    return categories.isNotEmpty
        ? SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: categories.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('${e.key} (${e.value})'),
                    selected: _selectedCategory == e.key,
                    onSelected: (_) {
                      if (mounted) {
                        setState(() {
                          _selectedCategory = _selectedCategory == e.key
                              ? null
                              : e.key;
                          _filteredProducts = _applyFilters();
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildHeaderCount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '${_filteredProducts.length} produit(s)',
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ),
    );
  }

  Widget _buildProductsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun produit',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Commencez par ajouter votre premier produit',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Aucun résultat',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Essayez avec d\'autres filtres',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      onRefresh: () => _loadProducts(refresh: true),
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _filteredProducts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final product = _filteredProducts[i];
          return ProductCard(
            product: product,
            onEdit: () => _editProduct(product),
            onDelete: () => _deleteProduct(product),
          );
        },
      ),
    );
  }

  // ====================== ACTIONS ======================

  Future<void> _navigateToCreateProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
    );

    // Rafraîchir si un produit a été ajouté
    if (result == true && mounted) {
      await _loadProducts();
    }
  }

  Future<void> _editProduct(Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditProductScreen(product: product)),
    );

    // Rafraîchir si un produit a été modifié
    if (result == true && mounted) {
      await _loadProducts();
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le produit'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${product.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _productService.deleteProduct(product.id!);
        if (mounted) {
          await _loadProducts();
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produit supprimé avec succès')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de la suppression: $e')),
          );
        }
      }
    }
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    }
  }
}
