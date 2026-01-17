// lib/screens/drivers/driver_list_screen.dart - VERSION CORRIGÉE
// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../models/driver.dart';
import '../../services/driver_service.dart';
import '../../widgets/driver_card.dart';
import 'create_driver_screen.dart';
import 'edit_driver_screen.dart';

class DriverListScreen extends StatefulWidget {
  const DriverListScreen({super.key});

  @override
  State<DriverListScreen> createState() => _DriverListScreenState();
}

class _DriverListScreenState extends State<DriverListScreen> {
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  final TextEditingController _searchController = TextEditingController();

  List<Driver> _drivers = [];
  List<Driver> _filteredDrivers = [];
  Map<String, int> _statusCounts = {};

  bool _isLoading = true;
  String? _selectedStatus;
  String _searchQuery = '';

  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDrivers());
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  // ======================= DATA =======================

  Future<void> _loadDrivers({bool refresh = false}) async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final service = context.read<DriverService>();
      final response = await service.getDrivers(
        page: 1,
        pageSize: 50,
        status: _selectedStatus,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (!mounted) return;

      setState(() {
        _drivers = response.drivers;
        _updateFilteredDriversAndCounts();
        _isLoading = false;
      });

      if (refresh) _refreshController.refreshCompleted();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (refresh) _refreshController.refreshFailed();

      // Vérifier si c'est une erreur d'authentification
      if (e.toString().contains('Non authentifié') ||
          e.toString().contains('Token') ||
          e.toString().contains('401') ||
          e.toString().contains('403')) {
        _showAuthErrorDialog();
      } else {
        // Afficher l'erreur normale
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString().split('\n').first}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showAuthErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Session expirée'),
        content: const Text(
          'Votre session a expiré. Veuillez vous reconnecter pour continuer.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Rediriger vers l'écran de connexion
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: const Text('Se reconnecter'),
          ),
        ],
      ),
    );
  }

  void _updateFilteredDriversAndCounts() {
    // Calcul des compteurs
    _statusCounts = _calculateStatusCounts(_drivers);

    // Filtrage des drivers
    _filteredDrivers = _applyFilters(_drivers);
  }

  Map<String, int> _calculateStatusCounts(List<Driver> drivers) {
    final counts = <String, int>{'all': 0};

    for (final driver in drivers) {
      if (driver.isDeleted) continue;

      counts['all'] = (counts['all'] ?? 0) + 1;

      final status = driver.statut;
      counts[status] = (counts[status] ?? 0) + 1;
    }

    return counts;
  }

  List<Driver> _applyFilters(List<Driver> drivers) {
    final filteredList = drivers.where((driver) {
      // Exclure les drivers supprimés
      if (driver.isDeleted) return false;

      // Filtre par statut
      if (_selectedStatus != null && driver.statut != _selectedStatus) {
        return false;
      }

      // Filtre par recherche
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return driver.fullName.toLowerCase().contains(query) ||
            driver.email.toLowerCase().contains(query) ||
            driver.telephone.contains(_searchQuery);
      }

      return true;
    }).toList();

    // Tri par date de création décroissante
    filteredList.sort((a, b) => b.created_at.compareTo(a.created_at));

    return filteredList;
  }

  // ======================= STATUS SECTION =======================

  Widget _buildStatusSection() {
    const statusConfigs = [
      {'key': null, 'label': 'Tous'},
      {'key': 'actif', 'label': 'Actifs'},
      {'key': 'en_attente', 'label': 'En attente'},
      {'key': 'suspendu', 'label': 'Suspendus'},
      {'key': 'rejeté', 'label': 'Rejetés'},
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: statusConfigs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final config = statusConfigs[index];
          final isSelected = _selectedStatus == config['key'];

          // Obtenir le compteur
          final count = _getStatusCount(config['key']);

          return ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(config['label'] as String),
                if (count > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.3)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            selected: isSelected,
            onSelected: (_) {
              setState(() {
                _selectedStatus = isSelected ? null : config['key'];
                _filteredDrivers = _applyFilters(_drivers);
              });
            },
            selectedColor: Theme.of(context).primaryColor,
            backgroundColor: Colors.grey.shade200,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }

  int _getStatusCount(String? statusKey) {
    if (statusKey == null) return _statusCounts['all'] ?? 0;
    return _statusCounts[statusKey] ?? 0;
  }

  // ======================= LIST =======================

  Widget _buildDriversList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_drivers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'Aucun livreur',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Commencez par ajouter votre premier livreur',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_filteredDrivers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'Aucun résultat',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            if (_searchQuery.isNotEmpty || _selectedStatus != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _selectedStatus = null;
                    _filteredDrivers = _applyFilters(_drivers);
                  });
                },
                child: const Text('Réinitialiser les filtres'),
              ),
            ],
          ],
        ),
      );
    }

    return SmartRefresher(
      controller: _refreshController,
      onRefresh: () => _loadDrivers(refresh: true),
      enablePullDown: true,
      header: const ClassicHeader(),
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _filteredDrivers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, index) {
          final driver = _filteredDrivers[index];
          return DriverCard(
            driver: driver,
            onEdit: () => _navigateToEditDriver(driver), // Utiliser onEdit
            onDelete: () => _deleteDriver(driver), // Utiliser onDelete
          );
        },
      ),
    );
  }

  // ======================= DELETE =======================

  Future<void> _deleteDriver(Driver driver) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer "${driver.fullName}" ?'),
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

    if (confirmed == true && mounted) {
      try {
        final service = context.read<DriverService>();
        await service.deleteDriver(driver.id);
        await _loadDrivers();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Livreur supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        // Vérifier si c'est une erreur d'authentification
        if (e.toString().contains('Non authentifié') ||
            e.toString().contains('Token') ||
            e.toString().contains('401') ||
            e.toString().contains('403')) {
          _showAuthErrorDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString().split('\n').first}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // ======================= NAV =======================

  Future<void> _navigateToCreateDriver() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateDriverScreen()),
    );
    if (result == true && mounted) await _loadDrivers();
  }

  Future<void> _navigateToEditDriver(Driver driver) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditDriverScreen(driver: driver)),
    );
    if (result == true && mounted) await _loadDrivers();
  }

  // ======================= BUILD =======================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Livreurs'),
        // Badge et icône d'actualisation SUPPRIMÉS comme demandé
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateDriver,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Barre de recherche
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  _searchDebounce?.cancel();
                  _searchDebounce = Timer(
                    const Duration(milliseconds: 500),
                    () {
                      if (mounted) {
                        setState(() {
                          _searchQuery = value;
                          _filteredDrivers = _applyFilters(_drivers);
                        });
                      }
                    },
                  );
                },
                decoration: InputDecoration(
                  hintText: 'Rechercher un livreur...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _filteredDrivers = _applyFilters(_drivers);
                            });
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Section statuts
            if (_drivers.isNotEmpty) _buildStatusSection(),

            // Indicateur de résultats
            if (!_isLoading && _filteredDrivers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Text(
                      '${_filteredDrivers.length} résultat${_filteredDrivers.length > 1 ? 's' : ''}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 4),

            // Liste des livreurs
            Expanded(child: _buildDriversList()),
          ],
        ),
      ),
    );
  }
}
