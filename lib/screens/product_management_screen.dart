// lib/screens/product_management_screen.dart - VERSION CORRIGÉE

// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../screens/addeditproductscreen.dart';
import '../../services/product_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/product.dart';
import '../../widgets/product_stats_card.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  late ProductService _productService;
  late AuthService _authService;
  late ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  List<Product> _products = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  String _searchQuery = '';
  int _currentPage = 1;
  bool _hasMore = true;
  Map<String, dynamic>? _stats;

  // NOUVEAU: États pour la pagination
  bool _showFilterOptions = false;
  bool? _filterActiveOnly;
  String _selectedCategory = 'Toutes';
  List<String> _categories = ['Toutes'];

  @override
  void initState() {
    super.initState();

    print('🚀 ProductManagementScreen initState');
    _scrollController = ScrollController()..addListener(_scrollListener);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productService = Provider.of<ProductService>(context, listen: false);
    _authService = Provider.of<AuthService>(context, listen: false);

    print('📱 ProductManagementScreen didChangeDependencies');

    // Vérifier l'authentification
    if (!_authService.isAuthenticated) {
      _navigateToLogin();
      return;
    }

    _loadInitialData();
  }

  // ============================================
  // AUTHENTIFICATION ET NAVIGATION
  // ============================================

  void _navigateToLogin() {
    Future.microtask(() {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    });
  }

  Future<bool> _checkAuth() async {
    if (!_authService.isAuthenticated) {
      _showSessionExpired();
      return false;
    }
    return true;
  }

  void _showSessionExpired() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session expirée. Veuillez vous reconnecter.'),
        backgroundColor: Colors.red,
      ),
    );
    _navigateToLogin();
  }

  // ============================================
  // CHARGEMENT DES DONNÉES (CORRIGÉ)
  // ============================================

  Future<void> _loadInitialData() async {
    print('🔄 Début _loadInitialData');

    if (!await _checkAuth()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Future.wait([
        _loadMyProducts(refresh: true),
        _loadCategories(),
        _loadStats(),
      ]);
    } catch (e) {
      print('💥 Erreur chargement initial: $e');
      setState(() {
        _error = e.toString();
      });
      _showError('Erreur lors du chargement: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMyProducts({bool refresh = false}) async {
    print('📦 Début _loadMyProducts');

    if (!await _checkAuth()) return;

    try {
      if (refresh) {
        _currentPage = 1;
        _hasMore = true;
      }

      // Utiliser la NOUVELLE méthode du service corrigé
      await _productService.loadMyProducts(
        isActive: _filterActiveOnly,
        page: _currentPage,
        size: 20,
      );

      setState(() {
        if (refresh) {
          _products = List.from(_productService.products);
        } else {
          _products.addAll(_productService.products);
        }

        _hasMore = _productService.products.isNotEmpty;
        if (!refresh) _currentPage++;

        print('✅ ${_products.length} produits chargés (page $_currentPage)');
      });
    } catch (e) {
      print('💥 Erreur _loadMyProducts: $e');
      if (e.toString().contains('401') || e.toString().contains('Session')) {
        _showSessionExpired();
      } else {
        rethrow;
      }
    }
  }

  Future<void> _loadMore() async {
    if (!await _checkAuth() ||
        _isLoadingMore ||
        !_hasMore ||
        _searchQuery.isNotEmpty) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      await _loadMyProducts(refresh: false);
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadStats() async {
    if (!await _checkAuth()) return;

    try {
      final stats = await _productService.getSellerStats();
      setState(() {
        _stats = stats;
        print('📊 Stats chargées: $stats');
      });
    } catch (e) {
      print('⚠️ Erreur statistiques: $e');
    }
  }

  Future<void> _loadCategories() async {
    if (!await _checkAuth()) return;

    try {
      final categories = await _productService.getSellerCategories();
      setState(() {
        _categories = ['Toutes', ...categories];
        print('🗂️ Catégories chargées: $_categories');
      });
    } catch (e) {
      print('⚠️ Erreur catégories: $e');
    }
  }

  // ============================================
  // RECHERCHE ET FILTRAGE
  // ============================================

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text;
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (!await _checkAuth()) return;

    setState(() {
      _searchQuery = query;
      _isLoading = true;
    });

    try {
      if (query.isEmpty) {
        await _loadMyProducts(refresh: true);
      } else {
        final results = await _productService.searchProducts(
          query: query,
          limit: 20,
        );
        setState(() {
          _products = results;
          _hasMore = false;
        });
      }
    } catch (e) {
      _showError('Erreur recherche: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
    _loadMyProducts(refresh: true);
  }

  void _applyFilter() {
    setState(() {
      _showFilterOptions = false;
    });
    _loadMyProducts(refresh: true);
  }

  void _clearFilters() {
    setState(() {
      _filterActiveOnly = null;
      _selectedCategory = 'Toutes';
    });
    _loadMyProducts(refresh: true);
  }

  // ============================================
  // CRUD PRODUITS
  // ============================================

  Future<void> _addProduct() async {
    print('➕ Début _addProduct');

    if (!await _checkAuth()) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const AddEditProductScreen(), // Pas besoin de sellerId
      ),
    );

    if (result != null && result is Product) {
      print('🎉 Produit créé: ${result.id}');
      setState(() {
        _products.insert(0, result);
      });
      _showSuccess('Produit créé avec succès!');
      await _loadStats();
      await _loadCategories();
    }
  }

  Future<void> _editProduct(Product product) async {
    if (!await _checkAuth()) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditProductScreen(product: product),
      ),
    );

    if (result != null) {
      if (result is Product) {
        final index = _products.indexWhere((p) => p.id == result.id);
        if (index != -1) {
          setState(() {
            _products[index] = result;
          });
        }
        _showSuccess('Produit mis à jour!');
      } else if (result == 'deleted') {
        setState(() {
          _products.removeWhere((p) => p.id == product.id);
        });
        _showSuccess('Produit supprimé!');
        await _loadStats();
        await _loadCategories();
      }
    }
  }

  Future<void> _deleteProduct(Product product) async {
    if (!await _checkAuth()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Voulez-vous vraiment supprimer ce produit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _productService.deleteProduct(product.id!);
        setState(() {
          _products.removeWhere((p) => p.id == product.id);
        });
        _showSuccess('Produit supprimé!');
        await _loadStats();
        await _loadCategories();
      } catch (e) {
        _showError('Erreur suppression: $e');
      }
    }
  }

  // ============================================
  // WIDGET BUILDERS
  // ============================================

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher un produit...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  setState(() {
                    _showFilterOptions = !_showFilterOptions;
                  });
                },
                tooltip: 'Filtrer',
              ),
              if (_filterActiveOnly != null || _selectedCategory != 'Toutes')
                Chip(
                  label: const Text('Filtres actifs'),
                  onDeleted: _clearFilters,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOptions() {
    if (!_showFilterOptions) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtrer par:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Filtre statut
          Row(
            children: [
              const Text('Statut:'),
              const SizedBox(width: 16),
              ChoiceChip(
                label: const Text('Tous'),
                selected: _filterActiveOnly == null,
                onSelected: (_) => setState(() => _filterActiveOnly = null),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Actifs'),
                selected: _filterActiveOnly == true,
                onSelected: (_) => setState(() => _filterActiveOnly = true),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Inactifs'),
                selected: _filterActiveOnly == false,
                onSelected: (_) => setState(() => _filterActiveOnly = false),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Filtre catégorie
          const Text('Catégorie:'),
          Wrap(
            spacing: 8,
            children: _categories.map((category) {
              return ChoiceChip(
                label: Text(category),
                selected: _selectedCategory == category,
                onSelected: (_) => setState(() => _selectedCategory = category),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          // Boutons d'action
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _showFilterOptions = false;
                  });
                },
                child: const Text('Annuler'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _applyFilter,
                child: const Text('Appliquer'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    // Appliquer les filtres locaux si nécessaire
    List<Product> filteredProducts = _products;

    if (_selectedCategory != 'Toutes') {
      filteredProducts = filteredProducts
          .where((p) => p.categoryName == _selectedCategory)
          .toList();
    }

    if (_filterActiveOnly != null) {
      filteredProducts = filteredProducts
          .where((p) => p.isActive == _filterActiveOnly)
          .toList();
    }

    if (filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Aucun résultat pour "$_searchQuery"'
                  : 'Aucun produit',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addProduct,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un produit'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount:
          filteredProducts.length + (_hasMore && _searchQuery.isEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= filteredProducts.length) {
          return _buildLoadMore();
        }

        final product = filteredProducts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ProductCard(
            product: product,
            onTap: () => _editProduct(product),
            onEdit: () => _editProduct(product),
            onDelete: () => _deleteProduct(product),
          ),
        );
      },
    );
  }

  Widget _buildLoadMore() {
    if (!_hasMore || _searchQuery.isNotEmpty) return Container();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: _isLoadingMore
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _loadMore,
                child: const Text('Charger plus'),
              ),
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text('Erreur', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadInitialData,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_isLoading && _products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement...'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _loadMyProducts(refresh: true);
        await _loadStats();
        await _loadCategories();
      },
      child: Column(
        children: [
          _buildFilterOptions(),
          Expanded(child: _buildProductList()),
        ],
      ),
    );
  }

  // ============================================
  // UTILITAIRES
  // ============================================

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMore();
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Produits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addProduct,
            tooltip: 'Ajouter un produit',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            if (_stats != null && _searchQuery.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ProductStatsCard(
                  stats: ProductStats(
                    totalProducts: _stats!['total_products']?.toInt() ?? 0,
                    activeProducts: _stats!['active_products']?.toInt() ?? 0,
                    categoriesCount: _stats!['categories_count']?.toInt() ?? 0,
                    totalStock: _stats!['total_stock']?.toInt() ?? 0,
                    totalValue: _stats!['total_value']?.toDouble() ?? 0.0,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct,
        tooltip: 'Ajouter un produit',
        child: const Icon(Icons.add),
      ),
    );
  }
}
