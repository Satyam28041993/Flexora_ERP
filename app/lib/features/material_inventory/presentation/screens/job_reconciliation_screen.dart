import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/job_material_reconciliation_model.dart';
import '../../logic/material_providers.dart';

class JobReconciliationScreen extends ConsumerWidget {
  const JobReconciliationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reconciliationsAsync = ref.watch(jobReconciliationsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Job-Wise Material Reconciliation (5 Values)')),
      body: reconciliationsAsync.when(
        data: (reconciliations) {
          if (reconciliations.isEmpty) {
            return const Center(child: Text('No job material reconciliations recorded yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reconciliations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _ReconciliationCard(reconciliation: reconciliations[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading reconciliation: $err')),
      ),
    );
  }
}

class _ReconciliationCard extends StatelessWidget {
  const _ReconciliationCard({required this.reconciliation});

  final JobMaterialReconciliationModel reconciliation;

  @override
  Widget build(BuildContext context) {
    final r = reconciliation;

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
                Text(
                  r.jobCardNo,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'NET TAKEN: ${r.netMaterialTakenRmt.toInt()} RMT',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(r.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text('Customer: ${r.customerName}', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const Divider(height: 20),
            const Text('5 Distinct Material Values Breakdown:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildValueTile('1. Planned', '${r.plannedRmt.toInt()} RMT', Colors.blue.shade900),
                _buildValueTile('2. Issued', '${r.issuedRmt.toInt()} RMT', Colors.orange.shade900),
                _buildValueTile('3. Returned', '${r.returnedRmt.toInt()} RMT', Colors.green.shade900),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildValueTile('4. Actual Consumed', '${r.actualConsumptionRmt.toInt()} RMT', Colors.purple.shade900),
                _buildValueTile('5. Calculated Wastage', '${r.wastageRmt.toInt()} RMT', Colors.red.shade900),
                const SizedBox(width: 80),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueTile(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
      ],
    );
  }
}
