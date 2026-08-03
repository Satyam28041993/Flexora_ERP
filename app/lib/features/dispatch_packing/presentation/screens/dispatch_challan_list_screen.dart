import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/dispatch_challan_model.dart';
import '../../logic/dispatch_challan_pdf_generator.dart';
import '../../logic/dispatch_providers.dart';
import 'dispatch_form_screen.dart';

class DispatchChallanListScreen extends ConsumerWidget {
  const DispatchChallanListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challansAsync = ref.watch(dispatchChallansStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispatch Challans & GST Delivery Docs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(dispatchChallansStreamProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
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
            return const Center(
              child: Text(
                'No Dispatch Challans issued yet.\nClick "New Dispatch Challan" to issue one.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: challans.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
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

  Future<void> _printChallanPdf(BuildContext context) async {
    try {
      final pdfBytes = await DispatchChallanPdfGenerator.generateChallanPdf(
        challan: challan,
      );

      await Printing.layoutPdf(
        onLayout: (_) => pdfBytes,
        name: 'Dispatch_Challan_${challan.challanNo}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating GST Challan PDF: $e'), backgroundColor: AppTheme.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = challan;
    final isFullyDispatched = c.isFullyDispatched;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.local_shipping, color: AppTheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.challanNo,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary),
                        ),
                        Text(
                          'Job Card: ${c.jobCardNo} | PO: ${c.poNumber.isNotEmpty ? c.poNumber : 'N/A'}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                Chip(
                  label: Text(isFullyDispatched ? 'FULL DISPATCH' : 'PARTIAL DISPATCH'),
                  backgroundColor: isFullyDispatched ? Colors.green.shade50 : Colors.orange.shade50,
                  side: BorderSide(color: isFullyDispatched ? Colors.green.shade300 : Colors.orange.shade300),
                  labelStyle: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isFullyDispatched ? Colors.green.shade800 : Colors.orange.shade800,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text('Customer: ${c.customerName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.directions_car, size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text('Vehicle: ${c.vehicleNo}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(width: 16),
                const Icon(Icons.location_on, size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    c.shippingAddress,
                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statColumn('TARGET ORDER', '${c.targetOrderQtyPcs.toInt()} Pcs', AppTheme.textPrimary),
                  _statColumn('DISPATCHED QTY', '${c.dispatchedQtyPcs.toInt()} Pcs', Colors.green.shade700),
                  _statColumn('BALANCE REMAINING', '${c.balanceQtyPcs.toInt()} Pcs', isFullyDispatched ? Colors.grey : Colors.red.shade700),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _printChallanPdf(context),
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: const Text('Print GST Delivery Challan PDF'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statColumn(String title, String val, Color valColor) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(val, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: valColor)),
      ],
    );
  }
}
