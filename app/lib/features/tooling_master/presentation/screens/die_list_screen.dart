import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/die_model.dart';
import '../../logic/tooling_providers.dart';
import 'die_form_screen.dart';
import 'die_revision_wizard_screen.dart';

class DieListScreen extends ConsumerStatefulWidget {
  const DieListScreen({super.key});

  @override
  ConsumerState<DieListScreen> createState() => _DieListScreenState();
}

class _DieListScreenState extends ConsumerState<DieListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final diesAsync = ref.watch(diesStreamProvider(null));

    return Scaffold(
      appBar: AppBar(title: const Text('Punch / Die Management')),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'fab_die_revision',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DieRevisionWizardScreen()),
            ),
            backgroundColor: Colors.amber.shade800,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.sync_outlined),
            label: const Text('Die Revision / Remake', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          FloatingActionButton.extended(
            heroTag: 'fab_new_die',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DieFormScreen()),
            ),
            icon: const Icon(Icons.add),
            label: const Text('New Die Set'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by Die Code, Product SKU, Customer, Size, or Type...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: diesAsync.when(
              data: (dies) {
                final filtered = dies.where((d) {
                  if (_searchQuery.isEmpty) return true;
                  return d.dieCode.toLowerCase().contains(_searchQuery) ||
                      d.customerName.toLowerCase().contains(_searchQuery) ||
                      d.internalSkuCode.toLowerCase().contains(_searchQuery) ||
                      d.productName.toLowerCase().contains(_searchQuery) ||
                      d.shape.toLowerCase().contains(_searchQuery) ||
                      d.dieType.toLowerCase().contains(_searchQuery) ||
                      d.storageRackBin.toLowerCase().contains(_searchQuery) ||
                      d.specLabel.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No dies found in registry.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _DieCard(die: filtered[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error loading dies: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _DieCard extends StatelessWidget {
  const _DieCard({required this.die});

  final DieModel die;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(die.dieCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
            Chip(
              label: Text(die.status.toUpperCase()),
              backgroundColor: die.status == DieStatus.available ? Colors.green.shade50 : Colors.blue.shade50,
              labelStyle: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: die.status == DieStatus.available ? Colors.green.shade800 : Colors.blue.shade800,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (die.productName.isNotEmpty)
                Text('${die.productName} (${die.internalSkuCode})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('Size: ${die.specLabel} | Type: ${die.dieType}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              if (die.customerName.isNotEmpty)
                Text('Customer: ${die.customerName} | Teeth: Z-${die.gearTeethCount} | Repeat: ${die.cylinderRepeatMm} mm',
                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text('Rev: ${die.revisionTag}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                  const SizedBox(width: 12),
                  Text('Storage: ${die.storageRackBin}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 12),
                  Text('Condition: ${die.condition}', style: const TextStyle(fontSize: 12)),
                ],
              ),
              if (die.remadeNotes.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('Notes: ${die.remadeNotes}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.amber.shade900)),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => DieRevisionWizardScreen(initialDie: die)),
                    ),
                    icon: const Icon(Icons.sync, size: 16, color: Colors.amber),
                    label: const Text('Remake / Correct Die', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber)),
                    style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.amber.shade700)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
