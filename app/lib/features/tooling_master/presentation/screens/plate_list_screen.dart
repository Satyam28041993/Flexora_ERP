import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/plate_model.dart';
import '../../logic/tooling_providers.dart';
import 'plate_form_screen.dart';

class PlateListScreen extends ConsumerStatefulWidget {
  const PlateListScreen({super.key, this.productId});

  final String? productId;

  @override
  ConsumerState<PlateListScreen> createState() => _PlateListScreenState();
}

class _PlateListScreenState extends ConsumerState<PlateListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final platesAsync = ref.watch(platesStreamProvider(widget.productId));

    return Scaffold(
      appBar: AppBar(title: const Text('Plate Management')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PlateFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New Plate'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by Plate Code, Customer, or Product SKU...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: platesAsync.when(
              data: (plates) {
                final filtered = plates.where((p) {
                  if (_searchQuery.isEmpty) return true;
                  return p.plateCode.toLowerCase().contains(_searchQuery) ||
                      p.customerName.toLowerCase().contains(_searchQuery) ||
                      p.internalSkuCode.toLowerCase().contains(_searchQuery) ||
                      p.productName.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No plates found in registry.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _PlateCard(plate: filtered[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error loading plates: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlateCard extends StatelessWidget {
  const _PlateCard({required this.plate});

  final PlateModel plate;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(plate.plateCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
            Chip(
              label: Text(plate.status.toUpperCase()),
              backgroundColor: plate.status == PlateStatus.available ? Colors.green.shade50 : Colors.blue.shade50,
              labelStyle: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: plate.status == PlateStatus.available ? Colors.green.shade800 : Colors.blue.shade800,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${plate.productName} (${plate.internalSkuCode})', style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('Customer: ${plate.customerName} | Artwork: ${plate.artworkVersionLabel}',
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text('Colors: ${plate.colorCount}', style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 16),
                  Text('Storage: ${plate.storageRackBin}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 16),
                  Text('Condition: ${plate.condition}', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
