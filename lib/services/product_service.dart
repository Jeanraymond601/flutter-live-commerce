// lib/services/product_service.dart - VERSION CORRIGÉE
// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../utils/constants.dart';

// ============================================
// EXCEPTIONS SIMPLIFIÉES
// ============================================

class ProductException implements Exception {
  final String message;
  final int? statusCode;

  ProductException(this.message, {this.statusCode});

  @override
  String toString() => 'ProductException: $message';
}

// ============================================
// SERVICE PRINCIPAL
// ============================================

class ProductService extends ChangeNotifier {
  // Dépendances
  final String Function() getAuthToken;
  final String Function() getSellerId;
  final String Function() getUserId; // Ajouté pour résolution d'identifiant

  // État
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  bool _hasSessionExpired = false;

  ProductService({
    required this.getAuthToken,
    required this.getSellerId,
    required this.getUserId, // Nouveau paramètre
  });

  // ============================================
  // GETTERS
  // ============================================

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get hasSessionExpired => _hasSessionExpired;

  // ============================================
  // MÉTHODES UTILITAIRES
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
    notifyListeners();
  }

  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = getAuthToken();
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  String _buildUrl(String endpoint) {
    return '${Constants.apiBaseUrl}$endpoint';
  }

  void _handleError(http.Response response) {
    final statusCode = response.statusCode;

    print('❌ Erreur HTTP: $statusCode');
    print('Response: ${response.body}');

    switch (statusCode) {
      case 401:
        _hasSessionExpired = true;
        notifyListeners();
        throw ProductException('Session expirée. Veuillez vous reconnecter.');

      case 403:
        throw ProductException(
          'Vous n\'êtes pas autorisé à effectuer cette action.',
        );

      case 404:
        throw ProductException('Ressource non trouvée.');

      case 405:
        throw ProductException('Méthode HTTP non autorisée.');

      case 422:
        try {
          final errorData = json.decode(response.body);
          if (errorData is Map && errorData['detail'] != null) {
            throw ProductException(errorData['detail'].toString());
          }
          throw ProductException('Données invalides.');
        } catch (e) {
          throw ProductException('Erreur de validation.');
        }

      case 500:
        try {
          final errorData = json.decode(response.body);
          if (errorData is Map && errorData['detail'] != null) {
            throw ProductException(errorData['detail'].toString());
          }
          throw ProductException('Erreur serveur interne.');
        } catch (e) {
          throw ProductException('Erreur serveur (500).');
        }

      default:
        throw ProductException('Erreur serveur ($statusCode).');
    }
  }

  Product _parseProduct(Map<String, dynamic> jsonData) {
    return Product.fromJson(jsonData);
  }

  List<Product> _parseProducts(List<dynamic> jsonList) {
    print('🔄 Parsing ${jsonList.length} produits');

    final result = jsonList
        .map((item) {
          try {
            return Product.fromJson(item as Map<String, dynamic>);
          } catch (e) {
            print('❌ Erreur parsing produit: $e');
            print('❌ Données problématiques: $item');
            return null;
          }
        })
        .where((product) => product != null)
        .cast<Product>()
        .toList();

    print('✅ ${result.length} produits parsés avec succès');
    return result;
  }

  // ============================================
  // ENDPOINTS CORRIGÉS (selon ton backend FastAPI)
  // ============================================

  /// 1) Mes produits (vendeur connecté)
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
        throw ProductException('Non authentifié.');
      }

      // Construire l'URL avec query params
      final params = {
        if (isActive != null) 'is_active': isActive.toString(),
        'page': page.toString(),
        'size': size.toString(),
      };

      final queryString = Uri(queryParameters: params).query;
      final url = _buildUrl('/products/my-products?$queryString');
      print('🌐 URL: $url');

      final response = await http
          .get(Uri.parse(url), headers: _getHeaders())
          .timeout(const Duration(seconds: 30));

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        _products = _parseProducts(data);
        print('✅ ${_products.length} produits chargés (mes produits)');
      } else {
        _handleError(response);
      }
    } catch (e) {
      print('💥 Exception dans loadMyProducts: $e');
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 2) Produits d'un vendeur spécifique (par seller_id OU user_id)
  Future<List<Product>> loadSellerProducts({
    required String identifier, // Accepte seller_id OU user_id
    bool? isActive,
    int page = 1,
    int size = 20,
    String sortBy = 'created_at',
    bool sortDesc = true,
  }) async {
    try {
      print('🔍 Chargement produits pour identifiant: $identifier');

      // Construire les query params
      final params = {
        if (isActive != null) 'is_active': isActive.toString(),
        'page': page.toString(),
        'size': size.toString(),
        'sort_by': sortBy,
        'sort_desc': sortDesc.toString(),
      };

      final queryString = Uri(queryParameters: params).query;
      final url = _buildUrl('/products/seller/$identifier?$queryString');
      print('🌐 URL: $url');

      final response = await http
          .get(Uri.parse(url), headers: _getHeaders())
          .timeout(const Duration(seconds: 30));

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return _parseProducts(data);
      } else {
        _handleError(response);
        return [];
      }
    } catch (e) {
      print('💥 Erreur dans loadSellerProducts: $e');
      return [];
    }
  }

  /// 3) Recherche texte
  Future<List<Product>> searchProducts({
    required String query,
    int limit = 20,
  }) async {
    try {
      print('🔎 Recherche: "$query" (limite: $limit)');

      final url = _buildUrl(
        '/products/search?q=${Uri.encodeComponent(query)}&limit=$limit',
      );
      print('🌐 URL: $url');

      final response = await http
          .get(Uri.parse(url), headers: _getHeaders())
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return _parseProducts(data);
      } else {
        _handleError(response);
        return [];
      }
    } catch (e) {
      print('💥 Erreur recherche: $e');
      return [];
    }
  }

  /// 4) Filtrage avancé
  Future<Map<String, dynamic>> filterProducts({
    String? sellerId,
    String? categoryName,
    bool? isActive,
    double? priceMin,
    double? priceMax,
    String? search,
    int page = 1,
    int size = 20,
    String sortBy = 'created_at',
    bool sortDesc = true,
  }) async {
    try {
      print('⚙️ Filtrage avancé');

      // Construire les query params
      final params = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
        'sort_by': sortBy,
        'sort_desc': sortDesc.toString(),
      };

      if (sellerId != null) params['seller_id'] = sellerId;
      if (categoryName != null) params['category_name'] = categoryName;
      if (isActive != null) params['is_active'] = isActive.toString();
      if (priceMin != null) params['price_min'] = priceMin.toString();
      if (priceMax != null) params['price_max'] = priceMax.toString();
      if (search != null && search.isNotEmpty) {
        params['search'] = search;
      }

      final queryString = Uri(queryParameters: params).query;
      final url = _buildUrl('/products/filter?$queryString');
      print('🌐 URL: $url');

      final response = await http
          .get(Uri.parse(url), headers: _getHeaders())
          .timeout(const Duration(seconds: 30));

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        // Structure de retour du backend
        final items = (data['items'] as List).map((item) {
          return Product.fromJson(item as Map<String, dynamic>);
        }).toList();

        return {
          'items': items,
          'total': data['total'] as int,
          'page': data['page'] as int,
          'size': data['size'] as int,
          'pages': data['pages'] as int,
        };
      } else {
        _handleError(response);
        return {'items': [], 'total': 0, 'page': 1, 'pages': 1};
      }
    } catch (e) {
      print('💥 Erreur filtrage: $e');
      return {'items': [], 'total': 0, 'page': 1, 'pages': 1};
    }
  }

  /// 5) Créer un produit (CORRIGÉ - seller_id géré par le backend)
  Future<Product> createProduct(ProductCreateRequest request) async {
    try {
      print('➕ Création produit');
      _isLoading = true;
      notifyListeners();

      // NE PAS ajouter seller_id ici, le backend le récupère du token
      final url = _buildUrl('/products/');
      print('🌐 URL: $url');
      print('📝 Données: ${request.toJson()}');

      final response = await http
          .post(
            Uri.parse(url),
            headers: _getHeaders(),
            body: json.encode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final newProduct = _parseProduct(data);

        // Ajouter à la liste locale
        _products.insert(0, newProduct);
        print('✅ Produit créé: ${newProduct.id}');

        notifyListeners();
        return newProduct;
      } else {
        _handleError(response);
        throw ProductException('Échec de la création');
      }
    } catch (e) {
      print('💥 Exception création: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 6) Récupérer un produit par ID
  Future<Product> getProduct(String productId) async {
    try {
      print('🔍 Détail produit: $productId');

      final url = _buildUrl('/products/$productId');
      print('🌐 URL: $url');

      final response = await http
          .get(Uri.parse(url), headers: _getHeaders())
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return _parseProduct(data);
      } else {
        _handleError(response);
        throw ProductException('Produit non trouvé');
      }
    } catch (e) {
      print('💥 Erreur détail: $e');
      rethrow;
    }
  }

  /// 7) Mettre à jour un produit (PATCH)
  Future<Product> updateProduct(
    String productId,
    ProductUpdateRequest request,
  ) async {
    try {
      print('✏️ Mise à jour produit: $productId');

      final url = _buildUrl('/products/$productId');
      print('🌐 URL: $url');

      final response = await http
          .patch(
            Uri.parse(url),
            headers: _getHeaders(),
            body: json.encode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final updatedProduct = _parseProduct(data);

        // Mettre à jour localement
        final index = _products.indexWhere((p) => p.id == productId);
        if (index != -1) {
          _products[index] = updatedProduct;
        }

        notifyListeners();
        return updatedProduct;
      } else {
        _handleError(response);
        throw ProductException('Échec de la mise à jour');
      }
    } catch (e) {
      print('💥 Erreur mise à jour: $e');
      rethrow;
    }
  }

  /// 8) Supprimer un produit
  Future<void> deleteProduct(String productId) async {
    try {
      print('🗑️ Suppression produit: $productId');

      final url = _buildUrl('/products/$productId');
      print('🌐 URL: $url');

      final response = await http
          .delete(Uri.parse(url), headers: _getHeaders())
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 204) {
        _products.removeWhere((p) => p.id == productId);
        print('✅ Produit supprimé');
        notifyListeners();
      } else {
        _handleError(response);
        throw ProductException('Échec de la suppression');
      }
    } catch (e) {
      print('💥 Erreur suppression: $e');
      rethrow;
    }
  }

  /// 9) Générer un code article
  Future<Map<String, dynamic>> generateProductCode({
    required String categoryName,
    required String sellerId,
  }) async {
    try {
      print('🔢 Génération code pour catégorie: $categoryName');

      final url = _buildUrl('/products/generate-code');
      print('🌐 URL: $url');

      final requestData = {
        'category_name': categoryName,
        'seller_id': sellerId,
      };

      final response = await http
          .post(
            Uri.parse(url),
            headers: _getHeaders(),
            body: json.encode(requestData),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        print('✅ Code généré: $data');
        return data;
      } else {
        _handleError(response);
        return {};
      }
    } catch (e) {
      print('💥 Erreur génération code: $e');
      return {};
    }
  }

  /// 10) Statistiques du vendeur
  Future<Map<String, dynamic>> getSellerStats({
    String? identifier, // optionnel, sinon utilise getSellerId()
  }) async {
    try {
      final id = identifier ?? getSellerId();
      if (id.isEmpty) {
        throw ProductException('Vendeur non identifié.');
      }

      final url = _buildUrl('/products/seller/$id/stats');
      print('📈 Stats pour: $id');
      print('🌐 URL: $url');

      final response = await http
          .get(Uri.parse(url), headers: _getHeaders())
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        _handleError(response);
        return {};
      }
    } catch (e) {
      print('💥 Erreur stats: $e');
      return {};
    }
  }

  /// 11) Catégories du vendeur
  Future<List<String>> getSellerCategories({
    String? identifier, // optionnel, sinon utilise getSellerId()
  }) async {
    try {
      final id = identifier ?? getSellerId();
      if (id.isEmpty) {
        throw ProductException('Vendeur non identifié.');
      }

      final url = _buildUrl('/products/seller/$id/categories');
      print('🗂️ Catégories pour: $id');
      print('🌐 URL: $url');

      final response = await http
          .get(Uri.parse(url), headers: _getHeaders())
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.cast<String>();
      } else {
        _handleError(response);
        return [];
      }
    } catch (e) {
      print('💥 Erreur catégories: $e');
      return [];
    }
  }

  // ============================================
  // MÉTHODES UTILITAIRES SIMPLES
  // ============================================

  /// Valider les données d'un produit
  static List<String> validateProduct({
    required String name,
    required String category,
    required double price,
    required int stock,
  }) {
    final errors = <String>[];

    if (name.isEmpty) errors.add('Le nom est obligatoire');
    if (name.length < 2) errors.add('Le nom doit faire au moins 2 caractères');
    if (category.isEmpty) errors.add('La catégorie est obligatoire');
    if (price <= 0) errors.add('Le prix doit être supérieur à 0');
    if (stock < 0) errors.add('Le stock ne peut pas être négatif');

    return errors;
  }

  /// Filtrer par catégorie (local)
  List<Product> filterByCategory(String category) {
    if (category.isEmpty) return _products;
    return _products.where((p) => p.categoryName == category).toList();
  }

  /// Rechercher localement
  List<Product> searchLocally(String query) {
    if (query.isEmpty) return _products;

    final lowercaseQuery = query.toLowerCase();
    return _products.where((product) {
      return product.name.toLowerCase().contains(lowercaseQuery) ||
          product.codeArticle.toLowerCase().contains(lowercaseQuery) ||
          (product.description?.toLowerCase().contains(lowercaseQuery) ??
              false);
    }).toList();
  }

  /// Obtenir les catégories uniques (local)
  List<String> getUniqueCategories() {
    return _products
        .map((p) => p.categoryName)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
  }

  /// Mettre à jour le statut d'un produit localement
  void updateProductStatus(String productId, bool isActive) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _products[index] = _products[index].copyWith(isActive: isActive);
      notifyListeners();
    }
  }

  /// Vider les produits (pour logout)
  void clearProducts() {
    _products = [];
    notifyListeners();
  }
}
