import 'package:flutter/material.dart';
import '../models/delivery_model.dart';
import '../widgets/delivery_card.dart';

class DeliveriesScreen extends StatefulWidget {
  const DeliveriesScreen({super.key});

  @override
  State<DeliveriesScreen> createState() => _DeliveriesScreenState();
}

class _DeliveriesScreenState extends State<DeliveriesScreen> {
  List<Delivery> deliveries = [];
  List<Delivery> filteredDeliveries = [];
  DeliveryStatus? selectedFilter;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSampleDeliveries();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadSampleDeliveries() {
    final sampleDeliveries = DeliveryDataGenerator.generateSampleDeliveries(8);
    setState(() {
      deliveries = sampleDeliveries;
      filteredDeliveries = sampleDeliveries;
    });
  }

  void _filterDeliveries(DeliveryStatus? status) {
    setState(() {
      selectedFilter = status;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Delivery> result = deliveries;

    // Filtre par statut
    if (selectedFilter != null) {
      result = result.where((d) => d.status == selectedFilter).toList();
    }

    // Filtre par recherche
    final query = _searchController.text.toLowerCase().trim();
    if (query.isNotEmpty) {
      result = result
          .where(
            (d) =>
                d.customerName.toLowerCase().contains(query) ||
                d.id.toLowerCase().contains(query) ||
                d.productName.toLowerCase().contains(query) ||
                d.deliveryPersonName.toLowerCase().contains(query),
          )
          .toList();
    }

    setState(() {
      filteredDeliveries = result;
    });
  }

  void _showDeliveryDetails(Delivery delivery) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Détails de la livraison #${delivery.id}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildDetailItem(
                    context,
                    'Client',
                    delivery.customerName,
                    Icons.person,
                  ),
                  _buildDetailItem(
                    context,
                    'Adresse',
                    delivery.fullAddress,
                    Icons.location_on,
                  ),
                  _buildDetailItem(
                    context,
                    'Produit',
                    delivery.productInfo,
                    Icons.shopping_bag,
                  ),
                  _buildDetailItem(
                    context,
                    'Montant total',
                    '${delivery.orderTotal.toStringAsFixed(2)} €',
                    Icons.euro,
                  ),
                  _buildDetailItem(
                    context,
                    'Frais livraison',
                    '${delivery.deliveryFee.toStringAsFixed(2)} €',
                    Icons.local_shipping,
                  ),
                  _buildDetailItem(
                    context,
                    'Livreur',
                    delivery.deliveryPersonName,
                    Icons.delivery_dining,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Action depuis menu d'actions si besoin
                      },
                      icon: const Icon(Icons.more_vert),
                      label: const Text('Actions'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi des Livraisons'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Recherche
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une livraison...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
              ),
            ),
          ),

          // Filtres
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('Toutes', null),
                const SizedBox(width: 8),
                _buildFilterChip('En attente', DeliveryStatus.pending),
                const SizedBox(width: 8),
                _buildFilterChip('En cours', DeliveryStatus.inProgress),
                const SizedBox(width: 8),
                _buildFilterChip('Livrées', DeliveryStatus.delivered),
                const SizedBox(width: 8),
                _buildFilterChip('Échouées', DeliveryStatus.failed),
              ],
            ),
          ),

          // Compteur et refresh
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredDeliveries.length} livraison${filteredDeliveries.length > 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadSampleDeliveries,
                  tooltip: 'Actualiser',
                ),
              ],
            ),
          ),

          // Liste
          Expanded(
            child: filteredDeliveries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_shipping_outlined,
                          size: 72,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune livraison trouvée',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.5),
                              ),
                        ),
                        const SizedBox(height: 8),
                        if (_searchController.text.isNotEmpty ||
                            selectedFilter != null)
                          OutlinedButton(
                            onPressed: () {
                              _searchController.clear();
                              _filterDeliveries(null);
                            },
                            child: const Text('Réinitialiser les filtres'),
                          ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async => _loadSampleDeliveries(),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: filteredDeliveries.length,
                      itemBuilder: (context, index) {
                        final delivery = filteredDeliveries[index];
                        return DeliveryCard(
                          delivery: delivery,
                          onViewDetails: () => _showDeliveryDetails(delivery),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, DeliveryStatus? status) {
    return FilterChip(
      label: Text(label),
      selected: selectedFilter == status,
      onSelected: (_) => _filterDeliveries(status),
      selectedColor: status?.getColor().withOpacity(0.2),
      checkmarkColor: status?.getColor(),
      labelStyle: TextStyle(
        color: selectedFilter == status ? status?.getColor() : null,
        fontWeight: selectedFilter == status
            ? FontWeight.w600
            : FontWeight.normal,
      ),
    );
  }
}
