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
      appBar: AppBar(
        title: const Text('Roll Inventory — tracked by individual Roll ID'),
      ),
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
                  // Point users at the right screen: material-wise paper stock
                  // (including the Excel opening-stock import) lives in the RM
                  // ledger, not here — this screen is per-physical-roll only.
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox_outlined, size: 40, color: Colors.grey),
                          SizedBox(height: 12),
                          Text(
                            'No individual rolls registered yet.',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'This screen tracks rolls one-by-one using a Roll ID.\n'
                            'Material-wise paper stock (supplier / GSM / width) is in\n'
                            'Materials & Stores → RM Stock & Ledger → "Material Stock On-Hand".',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
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

class _RollCard extends ConsumerWidget {
  const _RollCard({required this.roll});

  final RollModel roll;

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppTheme.danger),
            const SizedBox(width: 8),
            Text('Delete Roll [${roll.rollCode}]'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete roll "${roll.rollCode}" (${roll.substrateMaterial})?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                final repo = ref.read(materialRepositoryProvider);
                await repo.deleteRoll(roll.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Roll [${roll.rollCode}] deleted successfully!'),
                      backgroundColor: Colors.green.shade800,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting roll: $e'),
                      backgroundColor: AppTheme.danger,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete_forever, size: 16),
            label: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                Row(
                  children: [
                    Chip(
                      label: Text(roll.status.toUpperCase()),
                      backgroundColor: isAvailable ? Colors.green.shade50 : Colors.orange.shade50,
                      labelStyle: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isAvailable ? Colors.green.shade800 : Colors.orange.shade800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: AppTheme.primary, size: 20),
                      tooltip: 'Edit Roll Details',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => RollFormScreen(roll: roll)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppTheme.danger, size: 20),
                      tooltip: 'Delete Roll',
                      onPressed: () => _confirmDelete(context, ref),
                    ),
                  ],
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
