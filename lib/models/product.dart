// lib/models/product.dart
// ignore_for_file: unused_import

import 'dart:convert';
import 'package:uuid/uuid.dart';

class Product {
  final String? id;
  final String sellerId;
  final String name;
  final String categoryName;
  final String? description;
  final String codeArticle;
  final String? color;
  final String? size;
  final double price;
  final int stock;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    this.id,
    required this.sellerId,
    required this.name,
    required this.categoryName,
    this.description,
    required this.codeArticle,
    this.color,
    this.size,
    required this.price,
    required this.stock,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor pour créer un nouveau produit (sans ID)
  factory Product.create({
    required String sellerId,
    required String name,
    required String categoryName,
    String? description,
    String? color,
    String? size,
    required double price,
    required int stock,
    bool isActive = true,
  }) {
    return Product(
      id: null, // L'ID sera généré par le serveur
      sellerId: sellerId,
      name: name,
      categoryName: categoryName,
      description: description,
      color: color,
      size: size,
      price: price,
      stock: stock,
      isActive: isActive,
      codeArticle: '', // Généré automatiquement par le serveur
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Factory constructor depuis JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      sellerId: json['seller_id'],
      name: json['name'],
      categoryName: json['category_name'],
      description: json['description'],
      codeArticle: json['code_article'],
      color: json['color'],
      size: json['size'],
      price: json['price'] is int
          ? (json['price'] as int).toDouble()
          : json['price'],
      stock: json['stock'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'seller_id': sellerId,
      'name': name,
      'category_name': categoryName,
      'description': description,
      'code_article': codeArticle,
      'color': color,
      'size': size,
      'price': price,
      'stock': stock,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Pour la création (sans les champs générés automatiquement)
  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'category_name': categoryName,
      'description': description,
      'color': color,
      'size': size,
      'price': price,
      'stock': stock,
      'is_active': isActive,
    };
  }

  // Pour la mise à jour (seulement les champs modifiables)
  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'category_name': categoryName,
      'description': description,
      'color': color,
      'size': size,
      'price': price,
      'stock': stock,
      'is_active': isActive,
    };
  }

  // Copier avec modifications
  Product copyWith({
    String? id,
    String? sellerId,
    String? name,
    String? categoryName,
    String? description,
    String? codeArticle,
    String? color,
    String? size,
    double? price,
    int? stock,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      name: name ?? this.name,
      categoryName: categoryName ?? this.categoryName,
      description: description ?? this.description,
      codeArticle: codeArticle ?? this.codeArticle,
      color: color ?? this.color,
      size: size ?? this.size,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, code: $codeArticle, price: $price, stock: $stock)';
  }

  // Méthodes utilitaires
  bool get isNew => id == null;
  bool get hasLowStock => stock <= 10 && stock > 0;
  bool get isOutOfStock => stock == 0;
  String get stockStatus {
    if (stock == 0) return 'Rupture';
    if (stock <= 10) return 'Stock faible';
    return 'En stock';
  }

  // Méthodes de validation
  static List<String> validate({
    required String name,
    required String categoryName,
    required double price,
    required int stock,
  }) {
    final errors = <String>[];

    if (name.isEmpty) {
      errors.add('Le nom du produit est requis');
    } else if (name.length < 3) {
      errors.add('Le nom doit contenir au moins 3 caractères');
    }

    if (categoryName.isEmpty) {
      errors.add('La catégorie est requise');
    }

    if (price <= 0) {
      errors.add('Le prix doit être supérieur à 0');
    }

    if (stock < 0) {
      errors.add('Le stock ne peut pas être négatif');
    }

    return errors;
  }
}

// ============================================
// SCHÉMAS DE RÉPONSE
// ============================================

class ProductResponse {
  final Product product;

  ProductResponse({required this.product});

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(product: Product.fromJson(json));
  }
}

class ProductListResponse {
  final List<Product> items;
  final int total;
  final int page;
  final int size;
  final int pages;

  ProductListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.size,
    required this.pages,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List)
        .map((item) => Product.fromJson(item))
        .toList();

    return ProductListResponse(
      items: items,
      total: json['total'],
      page: json['page'],
      size: json['size'],
      pages: json['pages'],
    );
  }
}

// ============================================
// SCHÉMAS POUR LES REQUÊTES
// ============================================

class ProductCreateRequest {
  final String name;
  final String categoryName;
  final String? description;
  final String? color;
  final String? size;
  final double price;
  final int stock;
  final bool isActive;

  ProductCreateRequest({
    required this.name,
    required this.categoryName,
    this.description,
    this.color,
    this.size,
    required this.price,
    required this.stock,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category_name': categoryName,
      'description': description,
      'color': color,
      'size': size,
      'price': price,
      'stock': stock,
      'is_active': isActive,
    };
  }

  static ProductCreateRequest fromProduct(Product product) {
    return ProductCreateRequest(
      name: product.name,
      categoryName: product.categoryName,
      description: product.description,
      color: product.color,
      size: product.size,
      price: product.price,
      stock: product.stock,
      isActive: product.isActive,
    );
  }
}

class ProductUpdateRequest {
  final String? name;
  final String? categoryName;
  final String? description;
  final String? color;
  final String? size;
  final double? price;
  final int? stock;
  final bool? isActive;

  ProductUpdateRequest({
    this.name,
    this.categoryName,
    this.description,
    this.color,
    this.size,
    this.price,
    this.stock,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (name != null) json['name'] = name;
    if (categoryName != null) json['category_name'] = categoryName;
    if (description != null) json['description'] = description;
    if (color != null) json['color'] = color;
    if (size != null) json['size'] = size;
    if (price != null) json['price'] = price;
    if (stock != null) json['stock'] = stock;
    if (isActive != null) json['is_active'] = isActive;

    return json;
  }

  static ProductUpdateRequest fromProduct(Product product) {
    return ProductUpdateRequest(
      name: product.name,
      categoryName: product.categoryName,
      description: product.description,
      color: product.color,
      size: product.size,
      price: product.price,
      stock: product.stock,
      isActive: product.isActive,
    );
  }
}

// ============================================
// SCHÉMAS POUR LE FILTRAGE
// ============================================

class ProductFilter {
  final String? sellerId;
  final String? categoryName;
  final bool? isActive;
  final double? priceMin;
  final double? priceMax;
  final String? search;
  final int page;
  final int size;
  final String sortBy;
  final bool sortDesc;

  ProductFilter({
    this.sellerId,
    this.categoryName,
    this.isActive,
    this.priceMin,
    this.priceMax,
    this.search,
    this.page = 1,
    this.size = 20,
    this.sortBy = 'created_at',
    this.sortDesc = true,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'page': page,
      'size': size,
      'sort_by': sortBy,
      'sort_desc': sortDesc,
    };

    if (sellerId != null && sellerId!.isNotEmpty) {
      json['seller_id'] = sellerId;
    }
    if (categoryName != null && categoryName!.isNotEmpty) {
      json['category_name'] = categoryName;
    }
    if (isActive != null) {
      json['is_active'] = isActive;
    }
    if (priceMin != null && priceMin! > 0) {
      json['price_min'] = priceMin;
    }
    if (priceMax != null && priceMax! > 0) {
      json['price_max'] = priceMax;
    }
    if (search != null && search!.isNotEmpty) {
      json['search'] = search;
    }

    return json;
  }

  ProductFilter copyWith({
    String? sellerId,
    String? categoryName,
    bool? isActive,
    double? priceMin,
    double? priceMax,
    String? search,
    int? page,
    int? size,
    String? sortBy,
    bool? sortDesc,
  }) {
    return ProductFilter(
      sellerId: sellerId ?? this.sellerId,
      categoryName: categoryName ?? this.categoryName,
      isActive: isActive ?? this.isActive,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      search: search ?? this.search,
      page: page ?? this.page,
      size: size ?? this.size,
      sortBy: sortBy ?? this.sortBy,
      sortDesc: sortDesc ?? this.sortDesc,
    );
  }
}

// ============================================
// SCHÉMAS POUR LA GÉNÉRATION DE CODE
// ============================================

class CodeGenerationRequest {
  final String categoryName;
  final String sellerId;

  CodeGenerationRequest({required this.categoryName, required this.sellerId});

  Map<String, dynamic> toJson() {
    return {'category_name': categoryName, 'seller_id': sellerId};
  }
}

class CodeGenerationResponse {
  final String categoryName;
  final String sellerId;
  final String generatedCode;
  final int nextNumber;

  CodeGenerationResponse({
    required this.categoryName,
    required this.sellerId,
    required this.generatedCode,
    required this.nextNumber,
  });

  factory CodeGenerationResponse.fromJson(Map<String, dynamic> json) {
    return CodeGenerationResponse(
      categoryName: json['category_name'],
      sellerId: json['seller_id'],
      generatedCode: json['generated_code'],
      nextNumber: json['next_number'],
    );
  }
}

// ============================================
// SCHÉMAS POUR LES STATISTIQUES
// ============================================

class ProductStats {
  final int totalProducts;
  final int activeProducts;
  final int categoriesCount;
  final int totalStock;
  final double totalValue;

  ProductStats({
    required this.totalProducts,
    required this.activeProducts,
    required this.categoriesCount,
    required this.totalStock,
    required this.totalValue,
  });

  factory ProductStats.fromJson(Map<String, dynamic> json) {
    return ProductStats(
      totalProducts: json['total_products'],
      activeProducts: json['active_products'],
      categoriesCount: json['categories_count'],
      totalStock: json['total_stock'],
      totalValue: json['total_value'] is int
          ? (json['total_value'] as int).toDouble()
          : json['total_value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_products': totalProducts,
      'active_products': activeProducts,
      'categories_count': categoriesCount,
      'total_stock': totalStock,
      'total_value': totalValue,
    };
  }

  @override
  String toString() {
    return 'ProductStats(total: $totalProducts, active: $activeProducts, categories: $categoriesCount, stock: $totalStock, value: $totalValue)';
  }
}

// ============================================
// CLASSES POUR LA GESTION D'ÉTAT
// ============================================

class ProductState {
  final List<Product> products;
  final bool isLoading;
  final String? error;
  final int totalProducts;
  final int currentPage;
  final bool hasMore;
  final ProductFilter filter;

  ProductState({
    required this.products,
    this.isLoading = false,
    this.error,
    this.totalProducts = 0,
    this.currentPage = 1,
    this.hasMore = true,
    required this.filter,
  });

  ProductState.initial()
    : products = [],
      isLoading = false,
      error = null,
      totalProducts = 0,
      currentPage = 1,
      hasMore = true,
      filter = ProductFilter();

  ProductState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? error,
    int? totalProducts,
    int? currentPage,
    bool? hasMore,
    ProductFilter? filter,
  }) {
    return ProductState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalProducts: totalProducts ?? this.totalProducts,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      filter: filter ?? this.filter,
    );
  }

  ProductState loading() {
    return copyWith(isLoading: true, error: null);
  }

  ProductState success({
    required List<Product> products,
    required int totalProducts,
    required int currentPage,
    required bool hasMore,
  }) {
    return copyWith(
      products: products,
      isLoading: false,
      error: null,
      totalProducts: totalProducts,
      currentPage: currentPage,
      hasMore: hasMore,
    );
  }

  ProductState failure(String error) {
    return copyWith(isLoading: false, error: error);
  }

  ProductState addProduct(Product product) {
    final newProducts = List<Product>.from(products)..insert(0, product);
    return copyWith(products: newProducts, totalProducts: totalProducts + 1);
  }

  ProductState updateProduct(Product updatedProduct) {
    final newProducts = products.map((product) {
      return product.id == updatedProduct.id ? updatedProduct : product;
    }).toList();

    return copyWith(products: newProducts);
  }

  ProductState removeProduct(String productId) {
    final newProducts = products.where((p) => p.id != productId).toList();
    return copyWith(
      products: newProducts,
      totalProducts: totalProducts > 0 ? totalProducts - 1 : 0,
    );
  }

  bool get isEmpty => products.isEmpty && !isLoading;
  bool get hasError => error != null;
}

// ============================================
// CLASSES POUR LES ÉVÉNEMENTS
// ============================================

abstract class ProductEvent {}

class LoadProductsEvent extends ProductEvent {
  final bool refresh;

  LoadProductsEvent({this.refresh = false});
}

class LoadMoreProductsEvent extends ProductEvent {}

class CreateProductEvent extends ProductEvent {
  final ProductCreateRequest request;

  CreateProductEvent({required this.request});
}

class UpdateProductEvent extends ProductEvent {
  final String productId;
  final ProductUpdateRequest request;

  UpdateProductEvent({required this.productId, required this.request});
}

class DeleteProductEvent extends ProductEvent {
  final String productId;

  DeleteProductEvent({required this.productId});
}

class SearchProductsEvent extends ProductEvent {
  final String query;

  SearchProductsEvent({required this.query});
}

class FilterProductsEvent extends ProductEvent {
  final ProductFilter filter;

  FilterProductsEvent({required this.filter});
}

class LoadProductStatsEvent extends ProductEvent {
  final String sellerId;

  LoadProductStatsEvent({required this.sellerId});
}

class GenerateProductCodeEvent extends ProductEvent {
  final CodeGenerationRequest request;

  GenerateProductCodeEvent({required this.request});
}

// ============================================
// CLASSES POUR LES EXCEPTIONS
// ============================================

class ProductException implements Exception {
  final String message;
  final int? statusCode;

  ProductException(this.message, {this.statusCode});

  @override
  String toString() =>
      'ProductException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class ProductNotFoundException extends ProductException {
  ProductNotFoundException(super.message);
}

class ProductValidationException extends ProductException {
  final List<String> errors;

  ProductValidationException(this.errors)
    : super('Erreur de validation: ${errors.join(", ")}');
}

class ProductCreationException extends ProductException {
  ProductCreationException(super.message);
}

class ProductUpdateException extends ProductException {
  ProductUpdateException(super.message);
}

class ProductDeletionException extends ProductException {
  ProductDeletionException(super.message);
}

// ============================================
// ENUMS
// ============================================

enum ProductSortOption {
  createdAt('created_at', 'Date de création'),
  updatedAt('updated_at', 'Dernière modification'),
  name('name', 'Nom'),
  price('price', 'Prix'),
  stock('stock', 'Stock');

  final String value;
  final String label;

  const ProductSortOption(this.value, this.label);

  static ProductSortOption fromValue(String value) {
    return values.firstWhere(
      (option) => option.value == value,
      orElse: () => ProductSortOption.createdAt,
    );
  }
}

enum ProductSortDirection {
  asc(false, 'Croissant'),
  desc(true, 'Décroissant');

  final bool value;
  final String label;

  const ProductSortDirection(this.value, this.label);

  static ProductSortDirection fromValue(bool value) {
    return value ? ProductSortDirection.desc : ProductSortDirection.asc;
  }
}

// ============================================
// EXTENSIONS UTILES
// ============================================

extension ProductListExtensions on List<Product> {
  List<Product> sortBy(ProductSortOption option, bool descending) {
    return List<Product>.from(this)..sort((a, b) {
      int comparison;
      switch (option) {
        case ProductSortOption.createdAt:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case ProductSortOption.updatedAt:
          comparison = a.updatedAt.compareTo(b.updatedAt);
          break;
        case ProductSortOption.name:
          comparison = a.name.compareTo(b.name);
          break;
        case ProductSortOption.price:
          comparison = a.price.compareTo(b.price);
          break;
        case ProductSortOption.stock:
          comparison = a.stock.compareTo(b.stock);
          break;
      }
      return descending ? -comparison : comparison;
    });
  }

  List<Product> filterByCategory(String category) {
    if (category.isEmpty) return this;
    return where((product) => product.categoryName == category).toList();
  }

  List<Product> filterActiveOnly() {
    return where((product) => product.isActive).toList();
  }

  List<Product> filterLowStock() {
    return where((product) => product.hasLowStock).toList();
  }

  List<Product> filterOutOfStock() {
    return where((product) => product.isOutOfStock).toList();
  }

  List<String> getCategories() {
    return map((product) => product.categoryName).toSet().toList()..sort();
  }

  int get totalStock => fold(0, (sum, product) => sum + product.stock);

  double get totalValue =>
      fold(0.0, (sum, product) => sum + (product.price * product.stock));
}

extension ProductPriceFormat on double {
  String formatPrice({String symbol = 'Ar'}) {
    return '${toStringAsFixed(2)} $symbol';
  }
}

extension ProductCodeFormat on String {
  String formatProductCode() {
    if (length >= 6) {
      return '${substring(0, 3)}-${substring(3)}';
    }
    return this;
  }

  bool isValidProductCode() {
    return RegExp(r'^[A-Z]{3}\d{3}$').hasMatch(this);
  }
}
