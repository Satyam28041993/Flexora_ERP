import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/shade_card_model.dart';
import '../../logic/shade_card_providers.dart';

class ShadeCardDetailScreen extends ConsumerWidget {
  const ShadeCardDetailScreen({super.key, required this.shadeCardId});

  final String shadeCardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(shadeCardRepositoryProvider);

    return FutureBuilder<ShadeCardModel?>(
      future: repo.getShadeCard(shadeCardId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final shadeCard = snapshot.data;
        if (shadeCard == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Shade Card Detail')),
            body: const Center(child: Text('Shade Card not found.')),
          );
        }

        final isApproved = shadeCard.status == ShadeCardStatus.approved;
        final dateFormat = DateFormat('dd-MM-yyyy HH:mm');

        return Scaffold(
          appBar: AppBar(
            title: Text(shadeCard.shadeCardCode),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (isApproved && shadeCard.isPermanentReference)
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.verified, color: Colors.green, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'APPROVED SHADE REFERENCE AVAILABLE',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14),
                              ),
                              Text(
                                'This shade card is saved as the permanent reference for repeat production runs of this SKU.',
                                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(shadeCard.shadeCardCode,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary)),
                          Chip(
                            label: Text(shadeCard.status.toUpperCase()),
                            backgroundColor: isApproved ? Colors.green.shade50 : Colors.orange.shade50,
                            labelStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isApproved ? Colors.green.shade800 : Colors.orange.shade800,
                                fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(shadeCard.productName,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      Text('Internal SKU: ${shadeCard.internalSkuCode}', style: const TextStyle(color: AppTheme.textSecondary)),
                      const SizedBox(height: 4),
                      Text('Customer: ${shadeCard.customerName} | Job Card: ${shadeCard.jobCardNo}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Shade Sample Evidence References',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                      const Divider(height: 20),
                      _buildRow('Standard Shade Ref', shadeCard.standardShadeStoragePath),
                      if (shadeCard.darkShadeStoragePath != null)
                        _buildRow('Dark Shade Ref', shadeCard.darkShadeStoragePath!),
                      if (shadeCard.lightShadeStoragePath != null)
                        _buildRow('Light Shade Ref', shadeCard.lightShadeStoragePath!),
                      _buildRow('Production Batch', shadeCard.productionBatchRunNo),
                      _buildRow('Created Date', dateFormat.format(shadeCard.dateCreated)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (!isApproved)
                Card(
                  color: Colors.amber.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.mark_email_read_outlined, size: 40, color: Colors.amber),
                        const SizedBox(height: 8),
                        const Text('Customer Approval Pending', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text(
                          'Record customer approval evidence to store this shade card as a permanent reference.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => _recordApprovalDialog(context, ref, shadeCard),
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Record Customer Approval'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (shadeCard.approvedBy != null)
                Card(
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Approval Record', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                        const Divider(height: 20),
                        _buildRow('Approved By', shadeCard.approvedBy!),
                        if (shadeCard.approvalDate != null)
                          _buildRow('Approval Date', dateFormat.format(shadeCard.approvalDate!)),
                        if (shadeCard.approvalEvidenceRef != null)
                          _buildRow('Evidence Ref', shadeCard.approvalEvidenceRef!),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _recordApprovalDialog(BuildContext context, WidgetRef ref, ShadeCardModel shadeCard) {
    final approverController = TextEditingController(text: 'Customer Email');
    final refController = TextEditingController(text: 'Email Ref Dated ${DateFormat('dd-MM-yyyy').format(DateTime.now())}');
    bool setAsPermanent = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Record Customer Approval (${shadeCard.shadeCardCode})'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: approverController,
                decoration: const InputDecoration(labelText: 'Approved By (Customer Rep)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: refController,
                decoration: const InputDecoration(labelText: 'Approval Evidence Reference'),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                title: const Text('Save as Permanent Reference for repeat jobs'),
                value: setAsPermanent,
                onChanged: (val) => setState(() => setAsPermanent = val ?? true),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final repo = ref.read(shadeCardRepositoryProvider);
                await repo.updateShadeCardApproval(
                  shadeCardId: shadeCard.id,
                  status: ShadeCardStatus.approved,
                  approvedBy: approverController.text.trim(),
                  approvalEvidenceRef: refController.text.trim(),
                  setAsPermanentReference: setAsPermanent,
                );
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('Approve & Save Reference'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
