import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/packing_list_model.dart';
import '../../logic/box_label_pdf_generator.dart';
import '../../logic/dispatch_providers.dart';
import 'packing_form_screen.dart';

class PackingListScreen extends ConsumerWidget {
  const PackingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packingListsAsync = ref.watch(packingListsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Packing Lists & Box Labels'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(packingListsStreamProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
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
            return const Center(
              child: Text(
                'No Packing Lists generated yet.\nClick "New Packing List" to add one.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lists.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
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

  Future<void> _printBoxLabel(BuildContext context, int boxIndex) async {
    try {
      final p = packingList;
      final labelsPerRoll = p.totalRolls > 0 ? (p.totalQuantityPcs / p.totalRolls).round() : 1000;
      final rollsPerBox = p.totalBoxes > 0 ? (p.totalRolls / p.totalBoxes).ceil() : p.totalRolls;
      final pcsPerBox = p.totalBoxes > 0 ? (p.totalQuantityPcs / p.totalBoxes) : p.totalQuantityPcs;

      final pdfBytes = await BoxLabelPdfGenerator.generateSingleBoxLabel(
        boxNumber: '$boxIndex',
        totalBoxesInShipment: p.totalBoxes,
        jobCardNo: p.jobCardNo,
        poNumber: 'PO-REF-${p.jobCardNo}',
        customerName: p.customerName,
        productName: p.productName,
        rollCount: rollsPerBox,
        labelsPerRoll: labelsPerRoll,
        totalQuantityPcs: pcsPerBox,
        netWeightKg: (pcsPerBox * 0.0012), // Est net weight per pcs
        grossWeightKg: (pcsPerBox * 0.0012) + 0.45, // Box & core weight offset
        windingDirection: 'Head First / Outward',
        coreSizeMm: 76.0,
        packedBy: p.packedBy,
        packingDate: p.packingDate,
      );

      await Printing.layoutPdf(
        onLayout: (_) => pdfBytes,
        name: 'BoxLabel_${p.jobCardNo}_Box$boxIndex.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating Box Label PDF: $e'), backgroundColor: AppTheme.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = packingList;

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
                      child: const Icon(Icons.inventory_2, color: AppTheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.packingListNo,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary),
                        ),
                        Text(
                          'Job Card: ${p.jobCardNo}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Text(
                    '${p.totalQuantityPcs.toInt()} Pcs',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green.shade800),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(p.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 2),
            Text('Customer: ${p.customerName}', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            Row(
              children: [
                _metricBadge(Icons.inbox, '${p.totalBoxes} Boxes'),
                const SizedBox(width: 12),
                _metricBadge(Icons.adjust, '${p.totalRolls} Rolls'),
                const SizedBox(width: 12),
                _metricBadge(Icons.person, 'Packed by: ${p.packedBy}'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (ctx) => Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Print Box QR Labels (${p.totalBoxes} Boxes)',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            const Text('Select box label to print or download as PDF:',
                                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: List.generate(
                                p.totalBoxes,
                                (i) => ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    _printBoxLabel(context, i + 1);
                                  },
                                  icon: const Icon(Icons.qr_code, size: 18),
                                  label: Text('Box #${i + 1} Label'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.qr_code_2),
                  label: const Text('Print Box QR Labels'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF64748B)),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF334155))),
        ],
      ),
    );
  }
}
