// lib/screens/drivers/driver_list_screen.dart
// ignore_for_file: deprecated_member_use, unrelated_type_equality_checks

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
  bool _isLoading = true;
  bool _isLoadingStats = true;
  String? _selectedStatus;
  String _searchQuery = '';
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await _loadDrivers();
    await _loadStats();
    await _loadAvailableZones();
  }

  Future<void> _loadDrivers({bool refresh = false}) async {
    if (!mounted) return;

    setState(() {
      if (refresh) {
        _isLoading = true;
      }
    });

    try {
      final driverService = context.read<DriverService>();
      await driverService.initializeToken();

      final response = await driverService.getDrivers(
        status: _selectedStatus,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _drivers = response.drivers;
          _filteredDrivers = _applyFilters(_drivers);
        });
      }

      if (refresh) {
        _refreshController.refreshCompleted();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      if (refresh) {
        _refreshController.refreshFailed();
      }
      _showErrorSnackbar('Erreur de chargement des livreurs: $e');
    }
  }

  Future<void> _loadStats() async {
    if (!mounted) return;

    try {
      setState(() {
        _isLoadingStats = true;
      });

      final driverService = context.read<DriverService>();
      final result = await driverService.getStatsSummary();

      if (result['success'] == true && mounted) {
        setState(() {
          _isLoadingStats = false;
          _stats = result['stats'] ?? {};
        });
      } else if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
      if (e.toString().contains('Erreur de connexion')) {
        _showErrorSnackbar('Erreur de connexion au serveur');
      }
    }
  }

  Future<void> _loadAvailableZones() async {
    try {
      final driverService = context.read<DriverService>();
      await driverService.getAvailableZones();
    } catch (e) {
      // Silencieux en cas d'erreur
    }
  }

  List<Driver> _applyFilters(List<Driver> drivers) {
    List<Driver> filtered = drivers.where((driver) {
      // EXCLURE LES LIVREURS SUPPRIMÉS
      if (driver.is_deleted == true || driver.deleted_at != null) {
        return false;
      }

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

    // TRIER PAR DATE DE CRÉATION (plus récent en premier)
    filtered.sort((a, b) => b.created_at.compareTo(a.created_at));

    return filtered;
  }

  void _onRefresh() async {
    await Future.wait([_loadDrivers(refresh: true), _loadStats()]);
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filteredDrivers = _applyFilters(_drivers);
    });
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showSuccessSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteDriver(Driver driver) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Voulez-vous vraiment supprimer le livreur ${driver.fullName} ?\n\nCette action est irréversible.',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      if (!mounted) return;

      final driverService = context.read<DriverService>();
      final result = await driverService.deleteDriver(driver.id);

      if (result['success'] == true && mounted) {
        _showSuccessSnackbar('Livreur supprimé avec succès');

        setState(() {
          _drivers.removeWhere((d) => d.id == driver.id);
          _filteredDrivers = _applyFilters(_drivers);
        });

        await _loadStats();

        Future.delayed(Duration.zero, () async {
          await _loadDrivers();
        });
      } else if (mounted) {
        _showErrorSnackbar(result['error'] ?? 'Erreur lors de la suppression');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Erreur: ${e.toString()}');
      }
    }
  }

  Widget _buildStatsCards() {
    if (_isLoadingStats) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final stats = _stats ?? {};
    final byStatut = stats['by_statut'] ?? {};
    final byDisponibilite = stats['by_disponibilite'] ?? {};

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // Cartes de statistiques horizontales
            _buildStatCard(
              title: 'Total',
              value: '${stats['total'] ?? _drivers.length}',
              icon: Icons.people,
              color: Colors.blue,
            ),
            const SizedBox(width: 8),
            _buildStatCard(
              title: 'Actifs',
              value:
                  '${stats['active'] ?? _drivers.where((d) => d.statut == 'actif').length}',
              icon: Icons.check_circle,
              color: Colors.green,
            ),
            const SizedBox(width: 8),
            _buildStatCard(
              title: 'Disponibles',
              value:
                  '${stats['available'] ?? _drivers.where((d) => d.disponibilite == 'disponible').length}',
              icon: Icons.directions_car,
              color: Colors.teal,
            ),
            const SizedBox(width: 8),
            _buildStatCard(
              title: 'Indisponibles',
              value:
                  '${byDisponibilite['indisponible'] ?? _drivers.where((d) => d.disponibilite == 'indisponible').length}',
              icon: Icons.block,
              color: Colors.grey,
            ),
            const SizedBox(width: 8),
            _buildStatCard(
              title: 'En attente',
              value:
                  '${byStatut['en_attente'] ?? _drivers.where((d) => d.statut == 'en_attente').length}',
              icon: Icons.access_time,
              color: Colors.orange,
            ),
            const SizedBox(width: 8),
            _buildStatCard(
              title: 'Suspendus',
              value:
                  '${byStatut['suspendu'] ?? _drivers.where((d) => d.statut == 'suspendu').length}',
              icon: Icons.pause_circle,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return SizedBox(
      width: 120, // Largeur fixe pour les cartes
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(icon, size: 16, color: color),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20, // Taille réduite pour mieux s'adapter
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatusFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: const Text(
                'Filtrer par statut',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              title: const Text('Tous les statuts'),
              leading: Radio<String?>(
                value: null,
                groupValue: _selectedStatus,
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                    _filteredDrivers = _applyFilters(_drivers);
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ...['actif', 'en_attente', 'suspendu', 'rejeté'].map((status) {
              return ListTile(
                title: Text(_getStatusLabel(status)),
                leading: Radio<String?>(
                  value: status,
                  groupValue: _selectedStatus,
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                      _filteredDrivers = _applyFilters(_drivers);
                    });
                    Navigator.pop(context);
                  },
                ),
              );
            }),
            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Fermer'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip() {
    if (_selectedStatus == null && _searchQuery.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          if (_selectedStatus != null)
            InputChip(
              label: Text('Statut: ${_getStatusLabel(_selectedStatus!)}'),
              deleteIcon: const Icon(Icons.close, size: 14),
              onDeleted: () {
                setState(() {
                  _selectedStatus = null;
                  _filteredDrivers = _applyFilters(_drivers);
                });
              },
              backgroundColor: Colors.blue.shade100,
              labelStyle: const TextStyle(
                color: Colors.blue,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          if (_searchQuery.isNotEmpty)
            InputChip(
              label: Text('Recherche: $_searchQuery'),
              deleteIcon: const Icon(Icons.close, size: 14),
              onDeleted: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _filteredDrivers = _applyFilters(_drivers);
                });
              },
              backgroundColor: Colors.green.shade100,
              labelStyle: const TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          if (_selectedStatus != null || _searchQuery.isNotEmpty)
            ActionChip(
              label: const Text('Tout effacer'),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _selectedStatus = null;
                  _searchQuery = '';
                  _filteredDrivers = _applyFilters(_drivers);
                });
              },
              backgroundColor: Colors.red.shade100,
              labelStyle: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              avatar: const Icon(Icons.clear_all, size: 14, color: Colors.red),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
        ],
      ),
    );
  }

  Widget _buildDriversList() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_filteredDrivers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isNotEmpty || _selectedStatus != null
                    ? 'Aucun livreur ne correspond aux filtres'
                    : 'Aucun livreur trouvé',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              if (_searchQuery.isEmpty && _selectedStatus == null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ElevatedButton.icon(
                    onPressed: _navigateToCreateDriver,
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter un livreur'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      onRefresh: _onRefresh,
      header: const ClassicHeader(),
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _filteredDrivers.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final driver = _filteredDrivers[index];
          return DriverCard(
            driver: driver,
            onTap: () => _navigateToEditDriver(driver),
            onDelete: () => _deleteDriver(driver),
          );
        },
      ),
    );
  }

  Future<void> _navigateToCreateDriver() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateDriverScreen()),
    );

    if (result != null && result == true && mounted) {
      _onRefresh();
    }
  }

  Future<void> _navigateToEditDriver(Driver driver) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditDriverScreen(driver: driver)),
    );

    if (result != null && result == true && mounted) {
      _onRefresh();
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'actif':
        return 'Actif';
      case 'en_attente':
        return 'En attente';
      case 'suspendu':
        return 'Suspendu';
      case 'rejeté':
        return 'Rejeté';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Livreurs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showStatusFilter,
            tooltip: 'Filtrer par statut',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cartes de statistiques horizontales
            SizedBox(
              height: 100, // Hauteur fixe pour les cartes de stats
              child: _buildStatsCards(),
            ),

            // Barre de recherche
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher un livreur...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                onChanged: _onSearchChanged,
              ),
            ),

            // Filtres actifs
            _buildFilterChip(),

            // En-tête avec compte et bouton d'ajout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Livreurs (${_filteredDrivers.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _navigateToCreateDriver,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Ajouter'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Liste des livreurs
            Expanded(child: _buildDriversList()),
          ],
        ),
      ),
    );
  }
}
