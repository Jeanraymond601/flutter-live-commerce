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

  @override
  void initState() {
    super.initState();
    _loadSampleOrders();
  }

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
      Order(
        id: '5',
        customerName: 'Thomas Petit',
        neighborhood: 'Le Centre',
        city: 'Lille',
        phone: '07 55 66 77 88',
        productName: 'Sac à dos',
        quantity: 4,
        productPrice: 39.99,
        deliveryFee: 7.99,
        orderDate: DateTime.now().subtract(const Duration(hours: 1)),
        status: OrderStatus.pending,
        availableStock: 10,
      ),
    ];

    setState(() {
      orders = sampleOrders;
      filteredOrders = sampleOrders;
    });
  }

  void _filterOrders(OrderStatus? status) {
    setState(() {
      selectedFilter = status;
      if (status == null) {
        filteredOrders = orders;
      } else {
        filteredOrders = orders
            .where((order) => order.status == status)
            .toList();
      }
    });
  }

  void _acceptOrder(String orderId) {
    setState(() {
      orders = orders.map((order) {
        if (order.id == orderId) {
          return order.copyWith(status: OrderStatus.confirmed);
        }
        return order;
      }).toList();
      _filterOrders(selectedFilter);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Commande acceptée avec succès'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejectOrder(String orderId) {
    setState(() {
      orders = orders.map((order) {
        if (order.id == orderId) {
          return order.copyWith(status: OrderStatus.rejected);
        }
        return order;
      }).toList();
      _filterOrders(selectedFilter);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Commande refusée'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commandes Live Commerce'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSampleOrders,
            tooltip: 'Recharger',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Toutes'),
                    selected: selectedFilter == null,
                    onSelected: (_) => _filterOrders(null),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('En attente'),
                    selected: selectedFilter == OrderStatus.pending,
                    selectedColor: Colors.amber.withOpacity(0.2),
                    onSelected: (_) => _filterOrders(OrderStatus.pending),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Confirmées'),
                    selected: selectedFilter == OrderStatus.confirmed,
                    selectedColor: Colors.green.withOpacity(0.2),
                    onSelected: (_) => _filterOrders(OrderStatus.confirmed),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Refusées'),
                    selected: selectedFilter == OrderStatus.rejected,
                    selectedColor: Colors.red.withOpacity(0.2),
                    onSelected: (_) => _filterOrders(OrderStatus.rejected),
                  ),
                ],
              ),
            ),
          ),

          // Compteur
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${filteredOrders.length} commande${filteredOrders.length > 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Liste des commandes
          Expanded(
            child: filteredOrders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune commande',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.5),
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return OrderCard(
                        order: order,
                        onAccept: () => _acceptOrder(order.id),
                        onReject: () => _rejectOrder(order.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
