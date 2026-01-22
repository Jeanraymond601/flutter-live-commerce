import 'dart:async';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../widgets/order_card.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order> orders = [];
  List<Order> filteredOrders = [];
  OrderStatus? selectedFilter;

  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _loadSampleOrders();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  // =========================
  // AUTO REFRESH (simulation live)
  // =========================
  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _autoUpdateOrders(),
    );
  }

  void _autoUpdateOrders() {
    setState(() {
      orders = orders.map((order) {
        if (order.status == OrderStatus.pending &&
            order.availableStock >= order.quantity) {
          return order.copyWith(status: OrderStatus.confirmed);
        }
        if (order.status == OrderStatus.pending &&
            order.availableStock < order.quantity) {
          return order.copyWith(status: OrderStatus.rejected);
        }
        return order;
      }).toList();

      _filterOrders(selectedFilter);
    });
  }

  // =========================
  // SAMPLE DATA
  // =========================
  void _loadSampleOrders() {
    final sampleOrders = [
      Order(
        id: '1',
        customerName: 'Jean Dupont',
        neighborhood: 'Centre-ville',
        city: 'Paris',
        phone: '06 12 34 56 78',
        productName: 'T-shirt Premium',
        quantity: 2,
        productPrice: 29.99,
        deliveryFee: 4.99,
        orderDate: DateTime.now().subtract(const Duration(hours: 2)),
        status: OrderStatus.pending,
        availableStock: 5,
      ),
      Order(
        id: '2',
        customerName: 'Marie Martin',
        neighborhood: 'Les Hauts',
        city: 'Lyon',
        phone: '07 23 45 67 89',
        productName: 'Casque Bluetooth',
        quantity: 1,
        productPrice: 89.99,
        deliveryFee: 6.99,
        orderDate: DateTime.now().subtract(const Duration(days: 1)),
        status: OrderStatus.confirmed,
        availableStock: 3,
      ),
      Order(
        id: '3',
        customerName: 'Pierre Lefevre',
        neighborhood: 'Le Port',
        city: 'Marseille',
        phone: '06 98 76 54 32',
        productName: 'Montre Connectée',
        quantity: 3,
        productPrice: 149.99,
        deliveryFee: 8.99,
        orderDate: DateTime.now().subtract(const Duration(hours: 5)),
        status: OrderStatus.pending,
        availableStock: 2,
      ),
      Order(
        id: '4',
        customerName: 'Sophie Bernard',
        neighborhood: 'La Plaine',
        city: 'Bordeaux',
        phone: '06 11 22 33 44',
        productName: 'Enceinte Portable',
        quantity: 1,
        productPrice: 59.99,
        deliveryFee: 5.99,
        orderDate: DateTime.now().subtract(const Duration(days: 2)),
        status: OrderStatus.rejected,
        availableStock: 0,
      ),
    ];

    setState(() {
      orders = sampleOrders;
      filteredOrders = sampleOrders;
    });
  }

  // =========================
  // FILTER
  // =========================
  void _filterOrders(OrderStatus? status) {
    selectedFilter = status;

    setState(() {
      if (status == null) {
        filteredOrders = orders;
      } else {
        filteredOrders = orders.where((o) => o.status == status).toList();
      }
    });
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Commandes Live Commerce'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSampleOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(theme),
          _buildCounter(theme),
          const SizedBox(height: 6),
          Expanded(child: _buildOrdersList(theme)),
        ],
      ),
    );
  }

  // =========================
  // FILTER CHIPS
  // =========================
  Widget _buildFilters(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip('Toutes', null),
            _filterChip('En attente', OrderStatus.pending),
            _filterChip('Confirmées', OrderStatus.confirmed),
            _filterChip('Refusées', OrderStatus.rejected),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, OrderStatus? status) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selectedFilter == status,
        onSelected: (_) => _filterOrders(status),
      ),
    );
  }

  // =========================
  // COUNTER
  // =========================
  Widget _buildCounter(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '${filteredOrders.length} commande(s)',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  // =========================
  // LIST
  // =========================
  Widget _buildOrdersList(ThemeData theme) {
    if (filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'Aucune commande',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        return OrderCard(order: filteredOrders[index]);
      },
    );
  }
}
