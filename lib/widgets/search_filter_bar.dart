// lib/widgets/search_filter_bar.dart
// ignore_for_file: library_private_types_in_public_api, unnecessary_to_list_in_spreads, deprecated_member_use

import 'dart:async';

import 'package:commerce/utils/constants.dart';
import 'package:flutter/material.dart';

class SearchFilterBar extends StatefulWidget {
  final Function(String) onSearch;
  final Function(String?) onCategorySelected;
  final VoidCallback? onFilterPressed;
  final String sellerId;
  final String? initialCategory;

  const SearchFilterBar({
    super.key,
    required this.onSearch,
    required this.onCategorySelected,
    this.onFilterPressed,
    required this.sellerId,
    this.initialCategory,
  });

  @override
  _SearchFilterBarState createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(
      const Duration(milliseconds: Constants.debounceDelay),
      () {
        widget.onSearch(_searchController.text);
      },
    );
  }

  void _clearSearch() {
    _searchController.clear();
    widget.onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Constants.defaultPadding),
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          // Barre de recherche
          _buildSearchBar(),
          const SizedBox(height: 12),

          // Filtres rapides
          _buildQuickFilters(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Rechercher un produit...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(icon: const Icon(Icons.clear), onPressed: _clearSearch)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Constants.defaultRadius),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Constants.defaultRadius),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Constants.defaultRadius),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Row(
      children: [
        // Filtre par catégorie
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Constants.defaultRadius),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                hint: const Row(
                  children: [
                    Icon(Icons.category, size: 20, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      'Toutes les catégories',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Toutes les catégories'),
                  ),
                  ...Constants.commonCategories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                  widget.onCategorySelected(value);
                },
              ),
            ),
          ),
        ),

        // Bouton filtres avancés
        if (widget.onFilterPressed != null) ...[
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Constants.defaultRadius),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: widget.onFilterPressed,
              tooltip: 'Filtres avancés',
            ),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }
}

// Barre de filtres avancés
class AdvancedFilterBar extends StatefulWidget {
  final Function(Map<String, dynamic>) onApply;
  final Map<String, dynamic>? initialFilters;

  const AdvancedFilterBar({
    super.key,
    required this.onApply,
    this.initialFilters,
  });

  @override
  _AdvancedFilterBarState createState() => _AdvancedFilterBarState();
}

class _AdvancedFilterBarState extends State<AdvancedFilterBar> {
  bool _isActive = true;
  String? _selectedCategory;
  double? _priceMin;
  double? _priceMax;
  final TextEditingController _priceMinController = TextEditingController();
  final TextEditingController _priceMaxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeFilters();
  }

  void _initializeFilters() {
    if (widget.initialFilters != null) {
      _isActive = widget.initialFilters!['is_active'] ?? true;
      _selectedCategory = widget.initialFilters!['category'];
      _priceMin = widget.initialFilters!['price_min'];
      _priceMax = widget.initialFilters!['price_max'];

      if (_priceMin != null) {
        _priceMinController.text = _priceMin!.toString();
      }
      if (_priceMax != null) {
        _priceMaxController.text = _priceMax!.toString();
      }
    }
  }

  void _applyFilters() {
    final filters = <String, dynamic>{};

    filters['is_active'] = _isActive;

    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      filters['category'] = _selectedCategory;
    }

    if (_priceMin != null && _priceMin! > 0) {
      filters['price_min'] = _priceMin;
    }

    if (_priceMax != null && _priceMax! > 0) {
      filters['price_max'] = _priceMax;
    }

    widget.onApply(filters);
  }

  void _resetFilters() {
    setState(() {
      _isActive = true;
      _selectedCategory = null;
      _priceMin = null;
      _priceMax = null;
      _priceMinController.clear();
      _priceMaxController.clear();
    });

    widget.onApply({});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Constants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Constants.defaultRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtres avancés',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),

          // Statut
          SwitchListTile(
            title: const Text('Produits actifs seulement'),
            value: _isActive,
            onChanged: (value) {
              setState(() {
                _isActive = value;
              });
            },
            contentPadding: EdgeInsets.zero,
          ),

          const SizedBox(height: 12),

          // Catégorie
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Catégorie',
              border: OutlineInputBorder(),
            ),
            value: _selectedCategory,
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Toutes les catégories'),
              ),
              ...Constants.commonCategories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ],
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
          ),

          const SizedBox(height: 12),

          // Plage de prix
          const Text(
            'Plage de prix',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _priceMinController,
                  decoration: const InputDecoration(
                    labelText: 'Min',
                    prefixText: 'Ar ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _priceMin = double.tryParse(value);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _priceMaxController,
                  decoration: const InputDecoration(
                    labelText: 'Max',
                    prefixText: 'Ar ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _priceMax = double.tryParse(value);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Boutons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetFilters,
                  child: const Text('Réinitialiser'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text('Appliquer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _priceMinController.dispose();
    _priceMaxController.dispose();
    super.dispose();
  }
}
