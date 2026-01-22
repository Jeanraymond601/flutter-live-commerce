// lib/services/product_service.dart - VERSION COMPLÈTE CORRIGÉE
// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../utils/constants.dart';

// ============================================
// EXCEPTIONS
// ============================================

class ProductServiceException implements Exception {
  final String message;
  final int? statusCode;

  ProductServiceException(this.message, {this.statusCode});

  @override
  String toString() => 'ProductServiceException: $message';
}

// ============================================
// SERVICE PRINCIPAL - VERSION CORRIGÉE
// ============================================

class ProductService extends ChangeNotifier {
  // Dépendances
  final String Function() getAuthToken;
  final String Function() getSellerId;
  final String Function() getUserId;

  // État
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  bool _hasSessionExpired = false;
  Map<String, dynamic>? _stats;

  ProductService({
    required this.getAuthToken,
    required this.getSellerId,
    required this.getUserId,
  });

  // ============================================
  // GETTERS
  // ============================================

  List<Product> get products => List.unmodifiable(_products);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get hasSessionExpired => _hasSessionExpired;
  Map<String, dynamic>? get stats => _stats;
  int get productCount => _products.length;
  int get activeProductCount => _products.where((p) => p.isActive).length;

  // ============================================
  // MÉTHODES UTILITAIRES CORRIGÉES
  // ============================================

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void resetState() {
    _products = [];
    _isLoading = false;
    _error = null;
    _hasSessionExpired = false;
    _stats = null;
    notifyListeners();
  }

  /// HEADERS ESSENTIELS POUR NGROK
  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // HEADERS CRITIQUES POUR NGROK
      'ngrok-skip-browser-warning': 'true',
      'Access-Control-Allow-Origin': '*',
      'Origin': 'http://localhost',
    };

    final token = getAuthToken();
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // ignore: unused_element
  String _buildUrl(String endpoint) {
    // CORRECTION: Utilise Constants.baseUrl directement
    return '${Constants.apiBaseUrl}$endpoint';
  }

  /// Détecte si la réponse est la page d'avertissement ngrok
  bool _isHtmlResponse(String body) {
    final trimmed = body.trim();
    return trimmed.startsWith('<!DOCTYPE') ||
        trimmed.startsWith('<html') ||
        trimmed.contains('ngrok.com') ||
        trimmed.contains('You are about to visit');
  }

  /// Log et gestion des erreurs HTTP
  void _handleError(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    print('❌ Erreur HTTP: $statusCode');

    // Vérifie si c'est la page ngrok
    if (_isHtmlResponse(body)) {
      print('❌ NGROK BLOQUE CETTE REQUÊTE !');
      print('📄 Extrait HTML: ${body.substring(0, min(200, body.length))}');
      throw ProductServiceException(
        'Serveur temporairement indisponible. Réessayez dans 1 minute.',
        statusCode: statusCode,
      );
    }

    print(
      '📄 Body: ${body.length > 300 ? "${body.substring(0, 300)}..." : body}',
    );

    try {
      final errorData = json.decode(body) as Map<String, dynamic>;
      final errorMessage =
          errorData['detail'] ??
          errorData['message'] ??
          errorData['error'] ??
          'Erreur serveur ($statusCode)';

      if (statusCode == 401 || statusCode == 403) {
        _hasSessionExpired = true;
        notifyListeners();
        throw ProductServiceException(
          'Session expirée. Veuillez vous reconnecter.',
        );
      }

      throw ProductServiceException(
        errorMessage.toString(),
        statusCode: statusCode,
      );
    } catch (e) {
      switch (statusCode) {
        case 401:
          _hasSessionExpired = true;
          notifyListeners();
          throw ProductServiceException(
            'Session expirée. Veuillez vous reconnecter.',
          );
        case 403:
          throw ProductServiceException('Accès refusé.');
        case 404:
          throw ProductServiceException('Ressource non trouvée.');
        case 422:
          throw ProductServiceException('Données invalides.');
        case 500:
          throw ProductServiceException('Erreur serveur interne.');
        default:
          throw ProductServiceException('Erreur serveur ($statusCode).');
      }
    }
  }

  /// Parse un produit depuis JSON
  Product _parseProduct(Map<String, dynamic> jsonData) {
    try {
      return Product.fromJson(jsonData);
    } catch (e) {
      print('❌ Erreur parsing produit: $e');
      print('❌ Données: $jsonData');
      throw ProductServiceException('Format de données invalide');
    }
  }

  /// Parse une liste de produits
  List<Product> _parseProducts(List<dynamic> jsonList) {
    final products = <Product>[];

    for (var item in jsonList) {
      try {
        final product = Product.fromJson(item as Map<String, dynamic>);
        products.add(product);
      } catch (e) {
        print('⚠️ Produit ignoré (parsing error): $e');
        print('⚠️ Données: $item');
        continue;
      }
    }

    print(
      '✅ ${products.length}/${jsonList.length} produits parsés avec succès',
    );
    return products;
  }

  // ============================================
  // MÉTHODES PRINCIPALES - VERSION CORRIGÉE
  // ============================================

  /// 1. Charger mes produits (avec gestion ngrok intelligente)
  Future<void> loadMyProducts({
    bool? isActive,
    int page = 1,
    int size = 20,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final token = getAuthToken();
      if (token.isEmpty) {
        throw ProductServiceException('Non authentifié.');
      }

      final sellerId = getSellerId();
      print('🔄 Chargement produits pour seller: $sellerId');

      // ESSAI 1: Endpoint /products/my-products
      try {
        final params = {
          if (isActive != null) 'is_active': isActive.toString(),
          'page': page.toString(),
          'size': size.toString(),
        };

        final queryString = Uri(queryParameters: params).query;
        final url = '${Constants.apiBaseUrl}/products/my-products?$queryString';

        print('🌐 ESSAI 1 - URL: $url');

        final response = await http
            .get(Uri.parse(url), headers: _getHeaders())
            .timeout(const Duration(seconds: 15));

        print('📊 Status: ${response.statusCode}');

        // Vérifie si ngrok bloque
        if (_isHtmlResponse(response.body)) {
          print('❌ Ngrok bloque /my-products, essaie méthode alternative');
          throw ProductServiceException('ngrok_block');
        }

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          // Gestion des différents formats de réponse
          List<dynamic> items = [];
          if (data is List) {
            items = data;
          } else if (data is Map && data['items'] is List) {
            items = data['items'];
          } else if (data is Map && data['products'] is List) {
            items = data['products'];
          } else {
            throw ProductServiceException('Format de réponse inattendu');
          }

          _products = _parseProducts(items);
          print('✅ ${_products.length} produits chargés via /my-products');
          return;
        } else {
          _handleError(response);
        }
      } catch (e) {
        if (e.toString().contains('ngrok_block') || sellerId.isEmpty) {
          rethrow;
        }
        print('⚠️ Méthode 1 échouée: $e');
      }

      // ESSAI 2: Fallback vers /products/filter
      if (sellerId.isNotEmpty) {
        print('🔄 ESSAI 2: Fallback avec /products/filter');

        final products = await _getProductsByFilter(
          sellerId: sellerId,
          isActive: isActive,
          page: page,
          size: size,
        );

        _products = products;
        print('✅ ${_products.length} produits chargés via fallback /filter');
      } else {
        throw ProductServiceException('Seller ID non disponible');
      }
    } catch (e) {
      print('💥 Erreur loadMyProducts: $e');
      _error = e.toString();

      // Si ngrok bloque, essaie quand même avec filter
      if (e.toString().contains('ngrok')) {
        final sellerId = getSellerId();
        if (sellerId.isNotEmpty) {
          try {
            final products = await _getProductsByFilter(sellerId: sellerId);
            _products = products;
            print('✅ Récupération partielle: ${_products.length} produits');
          } catch (_) {
            _products = [];
          }
        }
      }

      if (!e.toString().contains('ngrok')) {
        rethrow;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>>? _salesChartData;

  List<Map<String, dynamic>>? get salesChartData => _salesChartData;

  Future<void> loadSalesData() async {
    try {
      // ignore: await_only_futures
      final token = await getAuthToken();
      final sellerId = getSellerId();

      final response = await http.get(
        Uri.parse('${Constants.getApiUrl()}/seller/$sellerId/sales'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _salesChartData = List<Map<String, dynamic>>.from(
          data['sales_data'] ?? [],
        );
        notifyListeners();
      }
    } catch (e) {
      print('Erreur chargement données ventes: $e');
    }
  }

  /// Méthode helper pour /products/filter
  Future<List<Product>> _getProductsByFilter({
    required String sellerId,
    bool? isActive,
    int page = 1,
    int size = 50,
  }) async {
    try {
      final params = {
        'seller_id': sellerId,
        if (isActive != null) 'is_active': isActive.toString(),
        'page': page.toString(),
        'size': size.toString(),
      };

      final queryString = Uri(queryParameters: params).query;
      final url = '${Constants.apiBaseUrl}/products/filter?$queryString';

      print('🌐 Filter URL: $url');
      print('📋 Headers: ${_getHeaders()}');

      final response = await http
          .get(Uri.parse(url), headers: _getHeaders())
          .timeout(const Duration(seconds: 15));

      if (_isHtmlResponse(response.body)) {
        print('❌ Ngrok bloque aussi /filter !');
        throw ProductServiceException('ngrok_block');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final items = data['items'] as List;
        return _parseProducts(items);
      } else {
        _handleError(response);
        return [];
      }
    } catch (e) {
      print('❌ Erreur _getProductsByFilter: $e');
      rethrow;
    }
  }

  /// 2. Charger les statistiques du vendeur
  Future<void> loadSellerStats() async {
    try {
      final sellerId = getSellerId();
      if (sellerId.isEmpty) {
        _stats = _getDefaultStats();
        return;
      }

      print('📈 Chargement stats pour seller: $sellerId');

      // ESSAI: Endpoint stats
      try {
        final url = '${Constants.apiBaseUrl}/products/seller/$sellerId/stats';
        print('🌐 Stats URL: $url');
        print('📋 Headers: ${_getHeaders()}');

        final response = await http
            .get(Uri.parse(url), headers: _getHeaders())
            .timeout(const Duration(seconds: 10));

        if (_isHtmlResponse(response.body)) {
          print('❌ Ngrok bloque /stats, calcul local');
          throw ProductServiceException('ngrok_block');
        }

        if (response.statusCode == 200) {
          _stats = json.decode(response.body) as Map<String, dynamic>;
          print('✅ Stats chargées: $_stats');
          return;
        }
      } catch (e) {
        if (!e.toString().contains('ngrok')) {
          rethrow;
        }
        print('⚠️ Endpoint stats bloqué, calcul local');
      }

      // Fallback: Calcul local basé sur les produits chargés
      _stats = _calculateLocalStats();
      print('✅ Stats calculées localement: $_stats');
    } catch (e) {
      print('❌ Erreur loadSellerStats: $e');
      _stats = _getDefaultStats();
    } finally {
      notifyListeners();
    }
  }

  /// Calcul des stats locales
  Map<String, dynamic> _calculateLocalStats() {
    final total = _products.length;
    final active = _products.where((p) => p.isActive).length;
    final totalValue = _products.fold(
      0.0,
      (sum, p) => sum + (p.price * p.stock),
    );
    final avgPrice = total > 0
        ? _products.fold(0.0, (sum, p) => sum + p.price) / total
        : 0;

    return {
      'total_products': total,
      'active_products': active,
      'inactive_products': total - active,
      'total_stock': _products.fold(0, (sum, p) => sum + p.stock),
      'total_value': totalValue,
      'average_price': avgPrice,
      'min_price': _products.isNotEmpty
          ? _products.map((p) => p.price).reduce(min)
          : 0,
      'max_price': _products.isNotEmpty
          ? _products.map((p) => p.price).reduce(max)
          : 0,
    };
  }

  /// Stats par défaut
  Map<String, dynamic> _getDefaultStats() {
    return {
      'total_products': 0,
      'active_products': 0,
      'inactive_products': 0,
      'total_stock': 0,
      'total_value': 0.0,
      'average_price': 0.0,
      'min_price': 0.0,
      'max_price': 0.0,
    };
  }

  /// 3. Créer un produit
  Future<Product> createProduct(ProductCreateRequest request) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final url = '${Constants.apiBaseUrl}/products/';
      print('➕ Création produit: $url');
      print('📝 Données: ${json.encode(request.toJson())}');

      final response = await http
          .post(
            Uri.parse(url),
            headers: _getHeaders(),
            body: json.encode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      print('📊 Status: ${response.statusCode}');

      if (_isHtmlResponse(response.body)) {
        throw ProductServiceException('ngrok_block');
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final newProduct = _parseProduct(data);

        // Ajouter au début de la liste
        _products.insert(0, newProduct);

        // Recalculer les stats
        await loadSellerStats();

        print('✅ Produit créé: ${newProduct.id} - ${newProduct.name}');
        notifyListeners();
        return newProduct;
      } else {
        _handleError(response);
        throw ProductServiceException('Échec de la création');
      }
    } catch (e) {
      print('💥 Erreur création produit: $e');
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 4. Mettre à jour un produit
  Future<Product> updateProduct(
    String productId,
    ProductUpdateRequest request,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      final url = '${Constants.apiBaseUrl}/products/$productId';
      print('✏️ Mise à jour produit $productId: $url');

      final response = await http
          .patch(
            Uri.parse(url),
            headers: _getHeaders(),
            body: json.encode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      print('📊 Status: ${response.statusCode}');

      if (_isHtmlResponse(response.body)) {
        throw ProductServiceException('ngrok_block');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final updatedProduct = _parseProduct(data);

        // Mettre à jour localement
        final index = _products.indexWhere((p) => p.id == productId);
        if (index != -1) {
          _products[index] = updatedProduct;
        }

        // Recalculer les stats
        await loadSellerStats();

        print('✅ Produit mis à jour: $productId');
        notifyListeners();
        return updatedProduct;
      } else {
        _handleError(response);
        throw ProductServiceException('Échec de la mise à jour');
      }
    } catch (e) {
      print('💥 Erreur mise à jour: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 5. Supprimer un produit
  Future<void> deleteProduct(String productId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final url = '${Constants.apiBaseUrl}/products/$productId';
      print('🗑️ Suppression produit $productId: $url');

      final response = await http
          .delete(Uri.parse(url), headers: _getHeaders())
          .timeout(const Duration(seconds: 30));

      print('📊 Status: ${response.statusCode}');

      if (_isHtmlResponse(response.body)) {
        throw ProductServiceException('ngrok_block');
      }

      if (response.statusCode == 204 || response.statusCode == 200) {
        // Supprimer localement
        _products.removeWhere((p) => p.id == productId);

        // Recalculer les stats
        await loadSellerStats();

        print('✅ Produit supprimé: $productId');
        notifyListeners();
      } else {
        _handleError(response);
        throw ProductServiceException('Échec de la suppression');
      }
    } catch (e) {
      print('💥 Erreur suppression: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 6. Récupérer un produit par ID
  Future<Product> getProductById(String productId) async {
    try {
      print('🔍 Détail produit: $productId');

      final url = '${Constants.apiBaseUrl}/products/$productId';
      print('🌐 URL: $url');

      final response = await http
          .get(Uri.parse(url), headers: _getHeaders())
          .timeout(const Duration(seconds: 30));

      print('📊 Status: ${response.statusCode}');

      if (_isHtmlResponse(response.body)) {
        throw ProductServiceException('ngrok_block');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return _parseProduct(data);
      } else {
        _handleError(response);
        throw ProductServiceException('Produit non trouvé');
      }
    } catch (e) {
      print('💥 Erreur détail produit: $e');
      rethrow;
    }
  }

  /// 7. Rechercher des produits
  Future<List<Product>> searchProducts(String query, {int limit = 20}) async {
    try {
      if (query.length < 2) return [];

      print('🔎 Recherche: "$query"');

      final encodedQuery = Uri.encodeComponent(query);
      final url =
          '${Constants.apiBaseUrl}/products/search?q=$encodedQuery&limit=$limit';
      print('🌐 URL: $url');

      final response = await http
          .get(Uri.parse(url), headers: _getHeaders())
          .timeout(const Duration(seconds: 15));

      if (_isHtmlResponse(response.body)) {
        // Fallback à la recherche locale
        return _searchLocally(query);
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data is List ? data : (data['items'] as List? ?? []);
        return _parseProducts(items);
      } else {
        return _searchLocally(query);
      }
    } catch (e) {
      print('⚠️ Recherche API échouée, fallback local: $e');
      return _searchLocally(query);
    }
  }

  /// Recherche locale
  List<Product> _searchLocally(String query) {
    if (query.isEmpty) return _products;

    final lowercaseQuery = query.toLowerCase();
    return _products.where((product) {
      return product.name.toLowerCase().contains(lowercaseQuery) ||
          product.codeArticle.toLowerCase().contains(lowercaseQuery) ||
          (product.description?.toLowerCase().contains(lowercaseQuery) ??
              false) ||
          product.categoryName.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// 8. Obtenir les catégories
  Future<List<String>> getCategories() async {
    try {
      final sellerId = getSellerId();
      if (sellerId.isEmpty) return _getLocalCategories();

      final url =
          '${Constants.apiBaseUrl}/products/seller/$sellerId/categories';
      print('🗂️ Catégories pour: $sellerId');

      final response = await http
          .get(Uri.parse(url), headers: _getHeaders())
          .timeout(const Duration(seconds: 10));

      if (_isHtmlResponse(response.body)) {
        return _getLocalCategories();
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.cast<String>();
      } else {
        return _getLocalCategories();
      }
    } catch (e) {
      print('⚠️ Catégories API échouées, fallback local: $e');
      return _getLocalCategories();
    }
  }

  /// Catégories locales
  List<String> _getLocalCategories() {
    return _products
        .map((p) => p.categoryName)
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  /// 9. Tester la connexion API
  Future<bool> testConnection() async {
    try {
      print('🧪 Test connexion API...');

      final url = '${Constants.apiBaseUrl}/products/filter?limit=1';
      final response = await http
          .get(Uri.parse(url), headers: _getHeaders())
          .timeout(const Duration(seconds: 10));

      if (_isHtmlResponse(response.body)) {
        print('❌ NGROK BLOQUE LA CONNEXION');
        return false;
      }

      print('✅ Connexion API OK - HTTP ${response.statusCode}');
      return true;
    } catch (e) {
      print('❌ Test connexion échoué: $e');
      return false;
    }
  }

  // ============================================
  // MÉTHODES UTILITAIRES POUR L'UI
  // ============================================

  /// Filtrer par catégorie
  List<Product> filterByCategory(String category) {
    if (category.isEmpty) return _products;
    return _products.where((p) => p.categoryName == category).toList();
  }

  /// Filtrer par statut
  List<Product> filterByStatus(bool isActive) {
    return _products.where((p) => p.isActive == isActive).toList();
  }

  /// Trier les produits
  List<Product> sortProducts(String sortBy, {bool descending = true}) {
    final sorted = List<Product>.from(_products);

    switch (sortBy) {
      case 'name':
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'price':
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'stock':
        sorted.sort((a, b) => a.stock.compareTo(b.stock));
        break;
      case 'created_at':
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      default:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    return descending ? sorted.reversed.toList() : sorted;
  }

  /// Mettre à jour le statut localement
  void updateProductStatus(String productId, bool isActive) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _products[index] = _products[index].copyWith(isActive: isActive);
      notifyListeners();

      // Recalculer les stats
      loadSellerStats();
    }
  }

  /// Vider les produits
  void clearProducts() {
    _products.clear();
    _stats = null;
    notifyListeners();
  }

  /// Rafraîchir toutes les données
  Future<void> refresh() async {
    await loadMyProducts();
    await loadSellerStats();
  }

  /// Valider les données d'un produit
  static List<String> validateProduct({
    required String name,
    required String categoryName,
    required double price,
    required int stock,
  }) {
    final errors = <String>[];

    if (name.isEmpty) errors.add('Le nom est obligatoire');
    if (name.length < 2) errors.add('Le nom doit faire au moins 2 caractères');
    if (categoryName.isEmpty) errors.add('La catégorie est obligatoire');
    if (price <= 0) errors.add('Le prix doit être supérieur à 0');
    if (stock < 0) errors.add('Le stock ne peut pas être négatif');

    return errors;
  }
}
