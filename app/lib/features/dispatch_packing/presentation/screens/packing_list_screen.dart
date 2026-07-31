import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/packing_list_model.dart';
import '../../logic/dispatch_providers.dart';
import 'packing_form_screen.dart';

class PackingListScreen extends ConsumerWidget {
  const PackingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packingListsAsync = ref.watch(packingListsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Packing Lists')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PackingFormScreen()),
        ),
        icon: const Icon(Icons.inventory_outlined),
        label: const Text('New Packing List'),
      ),
      body: packingListsAsync.when(
        data: (lists) {
          if (lists.isEmpty) {
            return const Center(child: Text('No Packing Lists generated yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lists.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _PackingCard(packingList: lists[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading Packing Lists: $err')),
      ),
    );
  }
}

class _PackingCard extends StatelessWidget {
  const _PackingCard({required this.packingList});

  final PackingListModel packingList;

  @override
  Widget build(BuildContext context) {
    final p = packingList;

    return Card(
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(p.packingListNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
            Text('${p.totalQuantityPcs.toInt()} Pcs', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green)),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('Job Card: ${p.jobCardNo} | Customer: ${p.customerName}',
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text('Boxes: ${p.totalBoxes}', style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 16),
                  Text('Rolls: ${p.totalRolls}', style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 16),
                  Text('Packed By: ${p.packedBy}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
