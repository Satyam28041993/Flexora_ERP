import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/job_card_model.dart';
import '../../data/models/master_card_model.dart';
import '../../logic/job_card_providers.dart';

class JobCardDetailScreen extends ConsumerWidget {
  const JobCardDetailScreen({super.key, required this.jobCardId});

  final String jobCardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(jobCardRepositoryProvider);
    final masterCardAsync = ref.watch(masterCardFutureProvider(jobCardId));

    return FutureBuilder<JobCardModel?>(
      future: repo.getJobCard(jobCardId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final jobCard = snapshot.data;
        if (jobCard == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Job Card Detail')),
            body: const Center(child: Text('Job Card not found.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(jobCard.jobCardNo),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
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
                          Text(
                            jobCard.jobCardNo,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary),
                          ),
                          Chip(
                            label: Text(jobCard.status.toUpperCase()),
                            backgroundColor: Colors.blue.shade50,
                            labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        jobCard.productName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text('SKU Code: ${jobCard.internalSkuCode}', style: const TextStyle(color: AppTheme.textSecondary)),
                      const SizedBox(height: 4),
                      Text('Customer: ${jobCard.customerName} | PO No: ${jobCard.poNumber}',
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
                      const Text('Production Targets & Quantities', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                      const Divider(height: 20),
                      _buildRow('Target Order Qty', '${jobCard.targetOrderQty.toInt()} pcs'),
                      _buildRow('Planned Prod Qty', '${jobCard.plannedProductionQty.toInt()} pcs (incl. setup/running waste)'),
                      if (jobCard.plateCode.isNotEmpty) _buildRow('Assigned Plate', jobCard.plateCode),
                      if (jobCard.dieCode.isNotEmpty) _buildRow('Assigned Punch/Die', jobCard.dieCode),
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
                      const Text('Process Route Sequence', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                      const Divider(height: 20),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: jobCard.processRoute.map((step) {
                          return Chip(
                            avatar: const Icon(Icons.play_arrow, size: 14, color: AppTheme.primary),
                            label: Text(step, style: const TextStyle(fontWeight: FontWeight.w600)),
                            backgroundColor: AppTheme.primary.withAlpha(20),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              masterCardAsync.when(
                data: (masterCard) {
                  if (masterCard == null) {
                    return Card(
                      color: Colors.amber.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(Icons.assignment_late_outlined, size: 40, color: Colors.amber),
                            const SizedBox(height: 8),
                            const Text('Pre-Press Master Card Pending Verification', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            const Text(
                              'Master Card must be verified before physical handover to production.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () => _createMasterCardDialog(context, ref, jobCard),
                              icon: const Icon(Icons.verified_user),
                              label: const Text('Verify & Issue Master Card'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final dateFormat = DateFormat('dd-MM-yyyy HH:mm');

                  return Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Master Card: ${masterCard.masterCardNo}',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green.shade900)),
                              const Icon(Icons.verified, color: Colors.green),
                            ],
                          ),
                          const Divider(),
                          _buildRow('Pre-Press Verified By', masterCard.verifiedBy),
                          _buildRow('Verification Date', dateFormat.format(masterCard.verificationDate)),
                          _buildRow('Handover Status', 'Master Card + Job Card + Plate + Die Ready'),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text('Error loading Master Card: $err'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _createMasterCardDialog(BuildContext context, WidgetRef ref, JobCardModel jobCard) {
    final verifiedByController = TextEditingController(text: 'Pre-Press Incharge');
    final speedController = TextEditingController(text: '40 m/min');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Pre-Press Handover Verification (${jobCard.jobCardNo})'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Confirm that Artwork, Polymer Plate, Punch/Die, and Shade Reference have been verified for handover:',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: verifiedByController,
              decoration: const InputDecoration(labelText: 'Verified By (Pre-Press Operator)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: speedController,
              decoration: const InputDecoration(labelText: 'Target Machine Speed'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final repo = ref.read(jobCardRepositoryProvider);
              final masterCard = MasterCardModel(
                id: '',
                plantId: DefaultPlant.id,
                masterCardNo: 'MC-${jobCard.jobCardNo}',
                jobCardId: jobCard.id,
                jobCardNo: jobCard.jobCardNo,
                customerName: jobCard.customerName,
                internalSkuCode: jobCard.internalSkuCode,
                productName: jobCard.productName,
                verifiedBy: verifiedByController.text.trim(),
                verificationDate: DateTime.now(),
                createdAt: DateTime.now(),
                createdBy: 'system',
              );

              await repo.createMasterCard(masterCard);
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
                ref.invalidate(masterCardFutureProvider(jobCard.id));
              }
            },
            child: const Text('Confirm Handover & Issue Master Card'),
          ),
        ],
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
