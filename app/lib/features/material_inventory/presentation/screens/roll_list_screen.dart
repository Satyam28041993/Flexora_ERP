import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/roll_model.dart';
import '../../logic/material_providers.dart';
import 'material_issue_dialog.dart';
import 'material_return_dialog.dart';
import 'roll_form_screen.dart';

class RollListScreen extends ConsumerStatefulWidget {
  const RollListScreen({super.key});

  @override
  ConsumerState<RollListScreen> createState() => _RollListScreenState();
}

class _RollListScreenState extends ConsumerState<RollListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final rollsAsync = ref.watch(rollsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Stores Roll-Level Inventory')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RollFormScreen()),
        ),
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Goods Receipt (New Roll)'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by Roll ID, Substrate, Width, or Vendor...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: rollsAsync.when(
              data: (rolls) {
                final filtered = rolls.where((r) {
                  if (_searchQuery.isEmpty) return true;
                  return r.rollCode.toLowerCase().contains(_searchQuery) ||
                      r.substrateMaterial.toLowerCase().contains(_searchQuery) ||
                      r.vendorName.toLowerCase().contains(_searchQuery) ||
                      r.storageLocation.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No rolls found in inventory.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _RollCard(roll: filtered[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error loading roll inventory: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _RollCard extends StatelessWidget {
  const _RollCard({required this.roll});

  final RollModel roll;

  @override
  Widget build(BuildContext context) {
    final isAvailable = roll.status == RollStatus.available;
    final rmtPercent = roll.originalRmt > 0 ? (roll.availableRmt / roll.originalRmt) : 0.0;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(roll.rollCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                Chip(
                  label: Text(roll.status.toUpperCase()),
                  backgroundColor: isAvailable ? Colors.green.shade50 : Colors.orange.shade50,
                  labelStyle: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isAvailable ? Colors.green.shade800 : Colors.orange.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('${roll.substrateMaterial} (${roll.widthMm.toInt()} mm Web Width)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text('Vendor: ${roll.vendorName} | Lot: ${roll.vendorBatchLot}',
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: rmtPercent.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              color: rmtPercent > 0.3 ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Stock: ${roll.availableRmt.toInt()} / ${roll.originalRmt.toInt()} RMT',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text('Location: ${roll.storageLocation}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (roll.availableRmt > 0)
                  OutlinedButton.icon(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => MaterialIssueDialog(roll: roll),
                    ),
                    icon: const Icon(Icons.outbox, size: 16),
                    label: const Text('Issue to Job Card'),
                  ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => MaterialReturnDialog(roll: roll),
                  ),
                  icon: const Icon(Icons.move_to_inbox, size: 16),
                  label: const Text('Return Leftover Roll'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
