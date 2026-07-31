import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/dispatch_challan_model.dart';
import '../../logic/dispatch_providers.dart';
import 'dispatch_form_screen.dart';

class DispatchChallanListScreen extends ConsumerWidget {
  const DispatchChallanListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challansAsync = ref.watch(dispatchChallansStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dispatch Challans & Balance Tracking')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DispatchFormScreen()),
        ),
        icon: const Icon(Icons.local_shipping_outlined),
        label: const Text('New Dispatch Challan'),
      ),
      body: challansAsync.when(
        data: (challans) {
          if (challans.isEmpty) {
            return const Center(child: Text('No Dispatch Challans issued yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: challans.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _ChallanCard(challan: challans[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading Dispatch Challans: $err')),
      ),
    );
  }
}

class _ChallanCard extends StatelessWidget {
  const _ChallanCard({required this.challan});

  final DispatchChallanModel challan;

  @override
  Widget build(BuildContext context) {
    final c = challan;
    final isFullyDispatched = c.isFullyDispatched;

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
                Text(c.challanNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                Chip(
                  label: Text(isFullyDispatched ? 'FULL DISPATCH' : 'PARTIAL DISPATCH'),
                  backgroundColor: isFullyDispatched ? Colors.green.shade50 : Colors.orange.shade50,
                  labelStyle: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isFullyDispatched ? Colors.green.shade800 : Colors.orange.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Customer: ${c.customerName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text('PO No: ${c.poNumber} | Job Card: ${c.jobCardNo}',
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 4),
            Text('Vehicle No: ${c.vehicleNo}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Target Order', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    Text('${c.targetOrderQtyPcs.toInt()} Pcs', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Dispatched Qty', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    Text('${c.dispatchedQtyPcs.toInt()} Pcs', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Balance Remaining', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    Text('${c.balanceQtyPcs.toInt()} Pcs',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isFullyDispatched ? Colors.grey : Colors.red)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
