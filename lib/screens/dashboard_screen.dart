// lib/screens/dashboard_screen.dart - VERSION AVANCÉE AVEC GRAPHIQUES DYNAMIQUES
import 'package:commerce/screens/abonnement_screen.dart';
import 'package:commerce/screens/deliveries_screen.dart';
import 'package:commerce/screens/facebook_integration_screen.dart';
import 'package:commerce/screens/orders_screen.dart';
import 'package:commerce/screens/seller_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:commerce/models/product.dart';
import 'package:commerce/screens/drivers/driver_list_screen.dart';
import 'package:commerce/screens/product_management_screen.dart';
import 'package:commerce/services/auth_service.dart';
import 'package:commerce/services/driver_service.dart';
import 'package:commerce/services/product_service.dart' as product_service;
import 'package:commerce/widgets/sidebar_menu.dart';

// Import pour les graphiques
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardListScreenState();
}

class _DashboardListScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  bool _isSidebarOpen = false;
  List<Product> _products = [];
  int _selectedMenuIndex = 0;
  String _currentPageTitle = 'Tableau de bord';

  // Statistiques pour les 4 cartes
  int _totalProducts = 0;
  int _totalStock = 0;
  int _lowStockProducts = 0;
  double _stockValue = 0.0;
  Map<String, dynamic>? _productStats;

  // Données pour les graphiques
  // Graphique Revenus
  List<RevenueData> _revenueData = [];
  String _revenueTimeFilter = 'mois';
  String _revenueChartType = 'ligne'; // 'ligne' ou 'barre'

  // Graphique Ventes
  List<SalesData> _salesData = [];
  String _salesTimeFilter = 'mois';
  String _salesChartType = 'barre'; // 'ligne' ou 'barre'

  final Map<int, String> _pageTitles = {
    0: 'Tableau de bord',
    1: 'Gestion des produits',
    2: 'Commandes',
    3: 'Livraison',
    4: 'Gestion des livreurs',
    5: 'Abonnement',
    6: 'Profil',
    7: 'Intégration Facebook',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final productService = Provider.of<product_service.ProductService>(
      context,
      listen: false,
    );

    if (!authService.isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      setState(() => _isLoading = true);

      await Future.wait([
        _loadMyProducts(productService),
        _loadProductStats(productService),
      ]);

      _calculateStatistics();
      _generateChartData();

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMyProducts(
    product_service.ProductService productService,
  ) async {
    try {
      await productService.loadMyProducts();
      if (mounted) {
        setState(() => _products = productService.products);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _products = []);
      }
    }
  }

  Future<void> _loadProductStats(
    product_service.ProductService productService,
  ) async {
    try {
      final stats = await productService.getSellerStats();
      if (mounted) {
        setState(() => _productStats = stats);
      }
    } catch (e) {
      // Ignorer l'erreur, les stats ne sont pas critiques
    }
  }

  void _calculateStatistics() {
    // Produits totaux
    _totalProducts =
        _productStats?['total_products']?.toInt() ?? _products.length;

    // Stock total
    _totalStock =
        _productStats?['total_stock']?.toInt() ??
        _products.fold(0, (sum, product) => sum + product.stock);

    // Produits en stock faible (≤ 10 unités)
    _lowStockProducts = _products.where((p) => p.stock <= 10).length;

    // Valeur totale du stock (en DZD)
    _stockValue =
        _productStats?['total_value']?.toDouble() ??
        _products.fold(
          0.0,
          (sum, product) => sum + (product.price * product.stock),
        );
  }

  void _generateChartData() {
    // Générer les données initiales
    _updateRevenueData();
    _updateSalesData();
  }

  void _updateRevenueData() {
    final now = DateTime.now();

    switch (_revenueTimeFilter) {
      case 'jour':
        // Données quotidiennes (7 derniers jours)
        _revenueData = [];
        for (int i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final dayName = DateFormat('E').format(date).substring(0, 3);
          final revenue = 15000.0 + (i * 2500.0);
          _revenueData.add(RevenueData(dayName, revenue));
        }
        break;

      case 'semaine':
        // Données hebdomadaires (4 dernières semaines)
        _revenueData = [
          RevenueData('S1', 42000.0),
          RevenueData('S2', 38000.0),
          RevenueData('S3', 45000.0),
          RevenueData('S4', 52000.0),
        ];
        break;

      case 'mois':
        // Données mensuelles (12 derniers mois)
        _revenueData = [
          RevenueData('Jan', 45000.0),
          RevenueData('Fév', 52000.0),
          RevenueData('Mar', 48000.0),
          RevenueData('Avr', 61000.0),
          RevenueData('Mai', 59000.0),
          RevenueData('Jun', 72000.0),
          RevenueData('Jul', 68000.0),
          RevenueData('Aoû', 75000.0),
          RevenueData('Sep', 82000.0),
          RevenueData('Oct', 78000.0),
          RevenueData('Nov', 85000.0),
          RevenueData('Déc', 90000.0),
        ];
        break;
    }
  }

  void _updateSalesData() {
    final now = DateTime.now();

    switch (_salesTimeFilter) {
      case 'jour':
        // Données quotidiennes (7 derniers jours)
        _salesData = [];
        for (int i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final dayName = DateFormat('E').format(date).substring(0, 3);
          final sales = 1000.0 + (i * 200.0);
          _salesData.add(SalesData(dayName, sales));
        }
        break;

      case 'semaine':
        // Données hebdomadaires (4 dernières semaines)
        _salesData = [
          SalesData('S1', 42000.0),
          SalesData('S2', 38000.0),
          SalesData('S3', 45000.0),
          SalesData('S4', 52000.0),
        ];
        break;

      case 'mois':
        // Données mensuelles (6 derniers mois)
        _salesData = [
          SalesData('Jan', 45000.0),
          SalesData('Fév', 52000.0),
          SalesData('Mar', 48000.0),
          SalesData('Avr', 61000.0),
          SalesData('Mai', 59000.0),
          SalesData('Jun', 72000.0),
        ];
        break;
    }
  }

  double get _totalRevenue {
    return _revenueData.fold(0.0, (sum, data) => sum + data.revenue);
  }

  double get _totalSales {
    return _salesData.fold(0.0, (sum, data) => sum + data.sales);
  }

  void _toggleSidebar() => setState(() => _isSidebarOpen = !_isSidebarOpen);
  void _closeSidebar() => setState(() => _isSidebarOpen = false);

  void _onSidebarItemSelected(int index) {
    setState(() {
      _selectedMenuIndex = index;
      _currentPageTitle = _pageTitles[index] ?? 'Tableau de bord';
    });
    _closeSidebar();

    switch (index) {
      case 0:
        // Tableau de bord - déjà sur cette page
        break;
      case 1:
        _navigateToProductManagement();
        break;
      case 2:
        _navigateToOrderManagement();
        break;
      case 3:
        _navigateToDeliveryManagement();
        break;
      case 4:
        _navigateToDriverManagement();
        break;
      case 5:
        _navigateToAbonnement();
        break;
      case 6:
        _navigateToSellerProfile();
        break;
      case 7:
        _navigateToFacebookIntegration();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_pageTitles[index]} - Bientôt disponible'),
            backgroundColor: Colors.blue,
          ),
        );
    }
  }

  Future<void> _navigateToFacebookIntegration() async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FacebookIntegrationScreen(),
        ),
      );
    } catch (e) {
      _showErrorSnackbar('Erreur lors de la navigation: $e');
    }
  }

  Future<void> _navigateToOrderManagement() async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OrdersScreen()),
      );
    } catch (e) {
      _showErrorSnackbar('Erreur lors de la navigation: $e');
    }
  }

  Future<void> _navigateToDeliveryManagement() async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DeliveriesScreen()),
      );
    } catch (e) {
      _showErrorSnackbar('Erreur lors de la navigation: $e');
    }
  }

  Future<void> _navigateToSellerProfile() async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SellerProfileScreen()),
      );
    } catch (e) {
      _showErrorSnackbar('Erreur lors de la navigation: $e');
    }
  }

  Future<void> _navigateToAbonnement() async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AbonnementScreen()),
      );
    } catch (e) {
      _showErrorSnackbar('Erreur lors de la navigation: $e');
    }
  }

  Future<void> _navigateToProductManagement() async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProductManagementScreen(),
        ),
      );
    } catch (e) {
      _showErrorSnackbar('Erreur: $e');
    }
  }

  Future<void> _navigateToDriverManagement() async {
    try {
      final driverService = Provider.of<DriverService>(context, listen: false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider.value(
            value: driverService,
            child: const DriverListScreen(),
          ),
        ),
      );
    } catch (e) {
      _showErrorSnackbar('Erreur: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vendor = Provider.of<AuthService>(context).currentVendor;
    final vendorName = vendor?.name ?? 'Vendeur';

    return Scaffold(
      body: Stack(
        children: [
          _buildMainContent(),
          if (_isSidebarOpen)
            GestureDetector(
              onTap: _closeSidebar,
              child: Container(color: Colors.black.withOpacity(0.4)),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: _isSidebarOpen ? 0 : -280,
            top: 0,
            bottom: 0,
            child: SidebarMenu(
              vendorName: vendorName,
              onItemSelected: _onSidebarItemSelected,
              onClose: _closeSidebar,
              selectedIndex: _selectedMenuIndex,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingScreen()
                  : _buildDashboardContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Chargement du tableau de bord...'),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: _toggleSidebar,
            icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentPageTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _currentPageTitle == 'Tableau de bord'
                      ? 'Bienvenue sur votre dashboard'
                      : 'Navigation',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Badge(
              label: const Text('0'),
              child: const Icon(Icons.notifications_none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        primary: false,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECTION 1: CARTES STATISTIQUES
            _buildStatsCards(),
            const SizedBox(height: 24),

            // SECTION 2: GRAPHIQUES DYNAMIQUES
            _buildChartsSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistiques Produits',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.0, // CORRIGÉ: 1.0 au lieu de 1.2
          children: [
            // CARTE 1: Produits totaux
            _buildStatCard(
              title: 'Produits totaux',
              value: _totalProducts.toString(),
              subtitle: 'articles en vente',
              icon: Icons.inventory,
              color: Colors.blue,
              trend: '+12%',
            ),

            // CARTE 2: Stock total
            _buildStatCard(
              title: 'Stock total',
              value: _totalStock.toString(),
              subtitle: 'unités disponibles',
              icon: Icons.warehouse,
              color: Colors.green,
              trend: '+5%',
            ),

            // CARTE 3: Stock faible
            _buildStatCard(
              title: 'Stock faible',
              value: _lowStockProducts.toString(),
              subtitle: _lowStockProducts > 0
                  ? 'à réapprovisionner'
                  : 'stock optimal',
              icon: Icons.warning_amber,
              color: _lowStockProducts > 0 ? Colors.orange : Colors.grey,
              trend: _lowStockProducts > 0 ? '⚠️ Attention' : '✅ Bon',
            ),

            // CARTE 4: Valeur du stock
            _buildStatCard(
              title: 'Valeur du stock',
              value: 'AR ${NumberFormat('#,##0').format(_stockValue)}',
              subtitle: 'valeur totale',
              icon: Icons.attach_money,
              color: Colors.purple,
              trend:
                  'AR ${NumberFormat('#,##0').format(_totalProducts > 0 ? _stockValue / _totalProducts : 0)}/prod',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String trend,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12), // CORRIGÉ: réduit de 16 à 12
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment.center, // CORRIGÉ: center au lieu de spaceBetween
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36, // CORRIGÉ: réduit de 40 à 36
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ), // CORRIGÉ: réduit de 22 à 20
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 3,
                ), // CORRIGÉ: réduit
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    fontSize: 9, // CORRIGÉ: réduit de 10 à 9
                    fontWeight: FontWeight.w500,
                    color: color == Colors.orange && title == 'Stock faible'
                        ? Colors.orange
                        : Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6), // CORRIGÉ: réduit de 8 à 6
          Text(
            value,
            style: const TextStyle(
              fontSize: 18, // CORRIGÉ: réduit de 20 à 18
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12, // CORRIGÉ: réduit de 14 à 12
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ), // CORRIGÉ: réduit de 11 à 10
            maxLines: 1, // CORRIGÉ: ajouté
            overflow: TextOverflow.ellipsis, // CORRIGÉ: ajouté
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          // Écran large: graphiques côte à côte
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildRevenueChart()),
              const SizedBox(width: 16),
              Expanded(child: _buildSalesChart()),
            ],
          );
        } else {
          // Écran étroit: graphiques empilés
          return Column(
            children: [
              _buildRevenueChart(),
              const SizedBox(height: 24),
              _buildSalesChart(),
            ],
          );
        }
      },
    );
  }

  Widget _buildRevenueChart() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // EN-TÊTE AVEC FILTRES
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.trending_up, color: Colors.green, size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Revenus',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),

              // DROPDOWN TYPE DE GRAPHIQUE
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _revenueChartType,
                    icon: const Icon(Icons.arrow_drop_down, size: 20),
                    iconSize: 16,
                    elevation: 16,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    onChanged: (String? newValue) {
                      setState(() {
                        _revenueChartType = newValue!;
                      });
                    },
                    items: <String>['ligne', 'barre']
                        .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                Icon(
                                  value == 'ligne'
                                      ? Icons.show_chart
                                      : Icons.bar_chart,
                                  size: 16,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  value == 'ligne' ? 'Ligne' : 'Barre',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        })
                        .toList(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // FILTRES TEMPORELS
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeFilterButton(
                  'jour',
                  'Jours',
                  Colors.green,
                  _revenueTimeFilter == 'jour',
                  () {
                    setState(() {
                      _revenueTimeFilter = 'jour';
                      _updateRevenueData();
                    });
                  },
                ),
                _buildTimeFilterButton(
                  'semaine',
                  'Semaines',
                  Colors.green,
                  _revenueTimeFilter == 'semaine',
                  () {
                    setState(() {
                      _revenueTimeFilter = 'semaine';
                      _updateRevenueData();
                    });
                  },
                ),
                _buildTimeFilterButton(
                  'mois',
                  'Mois(12)',
                  Colors.green,
                  _revenueTimeFilter == 'mois',
                  () {
                    setState(() {
                      _revenueTimeFilter = 'mois';
                      _updateRevenueData();
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // GRAPHIQUE
          SizedBox(
            height: 200,
            child: _revenueChartType == 'ligne'
                ? _buildLineChart(_revenueData, Colors.green, true)
                : _buildBarChart(_revenueData, Colors.green, true),
          ),

          const SizedBox(height: 8),

          // PIED DE PAGE AVEC TOTAL
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'Évolution des revenus',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Total: AR ${NumberFormat('#,##0').format(_totalRevenue)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalesChart() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // EN-TÊTE AVEC FILTRES
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.shopping_cart, color: Colors.blue, size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Ventes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),

              // DROPDOWN TYPE DE GRAPHIQUE
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _salesChartType,
                    icon: const Icon(Icons.arrow_drop_down, size: 20),
                    iconSize: 16,
                    elevation: 16,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    onChanged: (String? newValue) {
                      setState(() {
                        _salesChartType = newValue!;
                      });
                    },
                    items: <String>['ligne', 'barre']
                        .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                Icon(
                                  value == 'ligne'
                                      ? Icons.show_chart
                                      : Icons.bar_chart,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  value == 'ligne' ? 'Ligne' : 'Barre',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        })
                        .toList(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // FILTRES TEMPORELS
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeFilterButton(
                  'jour',
                  'Jour',
                  Colors.blue,
                  _salesTimeFilter == 'jour',
                  () {
                    setState(() {
                      _salesTimeFilter = 'jour';
                      _updateSalesData();
                    });
                  },
                ),
                _buildTimeFilterButton(
                  'semaine',
                  'Semaine',
                  Colors.blue,
                  _salesTimeFilter == 'semaine',
                  () {
                    setState(() {
                      _salesTimeFilter = 'semaine';
                      _updateSalesData();
                    });
                  },
                ),
                _buildTimeFilterButton(
                  'mois',
                  'Mois',
                  Colors.blue,
                  _salesTimeFilter == 'mois',
                  () {
                    setState(() {
                      _salesTimeFilter = 'mois';
                      _updateSalesData();
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // GRAPHIQUE
          SizedBox(
            height: 200,
            child: _salesChartType == 'ligne'
                ? _buildLineChart(_salesData, Colors.blue, false)
                : _buildBarChart(_salesData, Colors.blue, false),
          ),

          const SizedBox(height: 8),

          // PIED DE PAGE AVEC TOTAL
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Ventes par $_salesTimeFilter',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Total: AR ${NumberFormat('#,##0').format(_totalSales)}',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFilterButton(
    String value,
    String label,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart(List<dynamic> data, Color color, bool isRevenue) {
    List<FlSpot> spots = data.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        isRevenue ? entry.value.revenue : entry.value.sales,
      );
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: _getInterval(data, isRevenue) / 4,
          verticalInterval: 1,
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${(value / 1000).toInt()}K',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      isRevenue
                          ? data[value.toInt()].month
                          : data[value.toInt()].period,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: color,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.1),
            ),
          ),
        ],
        minX: 0,
        maxX: data.length.toDouble() - 1,
        minY: 0,
        maxY: _getMaxValue(data, isRevenue) * 1.1,
      ),
    );
  }

  Widget _buildBarChart(List<dynamic> data, Color color, bool isRevenue) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxValue(data, isRevenue) * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${isRevenue ? data[groupIndex].month : data[groupIndex].period}\nAR ${NumberFormat('#,##0').format(rod.toY)}',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${(value / 1000).toInt()}K',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      isRevenue
                          ? data[value.toInt()].month
                          : data[value.toInt()].period,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _getInterval(data, isRevenue) / 4,
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: isRevenue ? entry.value.revenue : entry.value.sales,
                width: 16,
                borderRadius: BorderRadius.circular(4),
                color: color,
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: _getMaxValue(data, isRevenue) * 1.2,
                  color: Colors.grey[100],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  double _getMaxValue(List<dynamic> data, bool isRevenue) {
    if (data.isEmpty) return 0;
    return data
        .map((e) => isRevenue ? e.revenue : e.sales)
        .reduce((a, b) => a > b ? a : b);
  }

  double _getInterval(List<dynamic> data, bool isRevenue) {
    final maxValue = _getMaxValue(data, isRevenue);
    if (maxValue <= 1000) return 1000;
    if (maxValue <= 10000) return 5000;
    if (maxValue <= 50000) return 10000;
    if (maxValue <= 100000) return 20000;
    return 50000;
  }
}

// Classes pour les données des graphiques
class RevenueData {
  final String month;
  final double revenue;

  RevenueData(this.month, this.revenue);
}

class SalesData {
  final String period;
  final double sales;

  SalesData(this.period, this.sales);
}
