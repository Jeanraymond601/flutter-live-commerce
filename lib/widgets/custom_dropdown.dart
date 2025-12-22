// lib/widgets/custom_dropdown.dart
// ignore_for_file: unnecessary_to_list_in_spreads, deprecated_member_use

import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final IconData? icon;
  final List<String> suggestions;
  final bool showClearButton;
  final bool showSearch;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final bool enabled;
  final bool required;
  final Color? fillColor;
  final BorderRadius? borderRadius;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final EdgeInsetsGeometry? contentPadding;
  final bool showLabel;
  final bool showBorder;

  const CustomDropdown({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.icon,
    required this.suggestions,
    this.showClearButton = true,
    this.showSearch = true,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.required = false,
    this.fillColor,
    this.borderRadius,
    this.labelStyle,
    this.hintStyle,
    this.contentPadding,
    this.showLabel = true,
    this.showBorder = true,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<String> _filteredSuggestions = [];
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _filteredSuggestions = widget.suggestions;
    _focusNode.addListener(_onFocusChanged);
    widget.controller.addListener(_onTextChanged);
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _showOverlay();
    } else {
      _hideOverlay();
    }
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    if (text.isNotEmpty) {
      _filteredSuggestions = widget.suggestions
          .where((item) => item.toLowerCase().contains(text.toLowerCase()))
          .toList();
    } else {
      _filteredSuggestions = widget.suggestions;
    }

    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 32,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 50),
          child: _buildDropdownMenu(),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isDropdownOpen = true;
    });
  }

  void _hideOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    setState(() {
      _isDropdownOpen = false;
    });
  }

  void _selectItem(String value) {
    widget.controller.text = value;
    widget.onChanged?.call(value);
    _focusNode.unfocus();
  }

  void _clearSelection() {
    widget.controller.clear();
    widget.onChanged?.call('');
    _focusNode.unfocus();
  }

  Widget _buildDropdownMenu() {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.4,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            // Barre de recherche (optionnelle)
            if (widget.showSearch && widget.suggestions.length > 5)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Rechercher...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onChanged: (value) {
                    _filteredSuggestions = widget.suggestions
                        .where(
                          (item) =>
                              item.toLowerCase().contains(value.toLowerCase()),
                        )
                        .toList();
                    _overlayEntry?.markNeedsBuild();
                  },
                ),
              ),

            // Liste des suggestions
            Expanded(
              child: _filteredSuggestions.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Aucune suggestion disponible',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredSuggestions.length,
                      itemBuilder: (context, index) {
                        final item = _filteredSuggestions[index];
                        return ListTile(
                          title: Text(item),
                          dense: true,
                          onTap: () => _selectItem(item),
                        );
                      },
                    ),
            ),

            // Bouton pour effacer
            if (widget.showClearButton && widget.controller.text.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: ListTile(
                  leading: const Icon(Icons.clear, size: 20),
                  title: const Text('Effacer la sélection'),
                  dense: true,
                  onTap: _clearSelection,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          if (widget.showLabel && widget.label.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: [
                  Text(
                    widget.label,
                    style:
                        widget.labelStyle ??
                        Theme.of(context).textTheme.labelMedium,
                  ),
                  if (widget.required)
                    const Padding(
                      padding: EdgeInsets.only(left: 2.0),
                      child: Text('*', style: TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ),

          // Champ avec dropdown
          TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            validator: widget.validator,
            enabled: widget.enabled,
            decoration: InputDecoration(
              hintText: widget.hintText ?? widget.label,
              prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.showClearButton &&
                      widget.controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: _clearSelection,
                    ),
                  Icon(
                    _isDropdownOpen
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                    size: 24,
                  ),
                ],
              ),
              filled: widget.fillColor != null,
              fillColor: widget.fillColor,
              contentPadding: widget.contentPadding ?? const EdgeInsets.all(16),
              border: widget.showBorder
                  ? OutlineInputBorder(
                      borderRadius:
                          widget.borderRadius ?? BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    )
                  : InputBorder.none,
              enabledBorder: widget.showBorder
                  ? OutlineInputBorder(
                      borderRadius:
                          widget.borderRadius ?? BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    )
                  : InputBorder.none,
              focusedBorder: widget.showBorder
                  ? OutlineInputBorder(
                      borderRadius:
                          widget.borderRadius ?? BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    )
                  : InputBorder.none,
              errorBorder: widget.showBorder
                  ? OutlineInputBorder(
                      borderRadius:
                          widget.borderRadius ?? BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    )
                  : InputBorder.none,
            ),
            onTap: () {
              if (!_isDropdownOpen) {
                _focusNode.requestFocus();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    widget.controller.removeListener(_onTextChanged);
    _hideOverlay();
    super.dispose();
  }
}

// Dropdown simple avec des options prédéfinies
class SimpleDropdown<T> extends StatelessWidget {
  final T? value;
  final String label;
  final List<DropdownMenuItem<T>> items;
  final Function(T?)? onChanged;
  final String? hintText;
  final IconData? icon;
  final String? Function(T?)? validator;
  final bool enabled;
  final bool required;
  final bool showBorder;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;

  const SimpleDropdown({
    super.key,
    this.value,
    required this.label,
    required this.items,
    this.onChanged,
    this.hintText,
    this.icon,
    this.validator,
    this.enabled = true,
    this.required = false,
    this.showBorder = true,
    this.fillColor,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Row(
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              if (required)
                const Padding(
                  padding: EdgeInsets.only(left: 2.0),
                  child: Text('*', style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),

        // Dropdown
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: icon != null ? Icon(icon) : null,
            filled: fillColor != null,
            fillColor: fillColor,
            contentPadding:
                contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            border: showBorder
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  )
                : InputBorder.none,
            enabledBorder: showBorder
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  )
                : InputBorder.none,
            focusedBorder: showBorder
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  )
                : InputBorder.none,
          ),
          validator: validator,
          isExpanded: true,
        ),
      ],
    );
  }
}

// Dropdown pour les catégories avec icônes
class CategoryDropdown extends StatelessWidget {
  final String? value;
  final Function(String?)? onChanged;
  final List<String> categories;
  final String label;
  final String? hintText;
  final bool enabled;

  const CategoryDropdown({
    super.key,
    this.value,
    this.onChanged,
    required this.categories,
    required this.label,
    this.hintText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDropdown<String>(
      value: value,
      label: label,
      hintText: hintText,
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Sélectionner une catégorie'),
        ),
        ...categories.map((category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Row(
              children: [
                const Icon(Icons.category, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(category),
              ],
            ),
          );
        }).toList(),
      ],
      onChanged: enabled ? onChanged : null,
      icon: Icons.category,
    );
  }
}

// Dropdown pour les statuts avec couleurs
class StatusDropdown extends StatelessWidget {
  final String? value;
  final Function(String?)? onChanged;
  final String label;
  final bool enabled;

  const StatusDropdown({
    super.key,
    this.value,
    this.onChanged,
    required this.label,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    const statuses = ['actif', 'inactif', 'en_attente', 'suspendu'];

    const statusColors = {
      'actif': Colors.green,
      'inactif': Colors.red,
      'en_attente': Colors.orange,
      'suspendu': Colors.grey,
    };

    const statusIcons = {
      'actif': Icons.check_circle,
      'inactif': Icons.block,
      'en_attente': Icons.access_time,
      'suspendu': Icons.pause_circle,
    };

    return SimpleDropdown<String>(
      value: value,
      label: label,
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Sélectionner un statut'),
        ),
        ...statuses.map((status) {
          return DropdownMenuItem<String>(
            value: status,
            child: Row(
              children: [
                Icon(
                  statusIcons[status],
                  size: 20,
                  color: statusColors[status],
                ),
                const SizedBox(width: 8),
                Text(status),
              ],
            ),
          );
        }).toList(),
      ],
      onChanged: enabled ? onChanged : null,
      icon: Icons.circle,
    );
  }
}
