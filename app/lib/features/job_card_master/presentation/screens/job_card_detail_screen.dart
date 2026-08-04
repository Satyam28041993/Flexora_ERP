import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../production/data/models/production_job_model.dart';
import '../../../production/logic/production_providers.dart';
import '../../data/models/job_card_model.dart';
import '../../data/models/master_card_model.dart';
import '../../logic/job_card_providers.dart';
import '../widgets/job_card_attachments_widget.dart';
import '../widgets/job_sheet_print_view.dart';

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
            title: Text('Job Sheet: ${jobCard.jobCardNo}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.print_outlined),
                tooltip: 'View / Print PGPL Job Sheet',
                onPressed: () => _openPrintPreview(context, jobCard),
              ),
            ],
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
                      Text('Job Code: ${jobCard.jobCode} | Customer: ${jobCard.customerName}', style: const TextStyle(color: AppTheme.textSecondary)),
                      const SizedBox(height: 4),
                      Text('Machine: ${jobCard.machineName} | PO No: ${jobCard.poNumber}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => _openPrintPreview(context, jobCard),
                        icon: const Icon(Icons.table_chart),
                        label: const Text('View PGPL Excel Format Job Sheet'),
                      ),
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
                      _buildRow('Paper Size', '${jobCard.paperSize.toInt()} mm'),
                      _buildRow('UPS / LABLE PER MTR', '${jobCard.ups} UPS / ${jobCard.labelPerMtr} per mtr'),
                      _buildRow('Calculated RMT', '${jobCard.rmt.toInt()} RMT'),
                      _buildRow('Winding Direction', jobCard.rollWindingDirection),
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
                          const SizedBox(height: 12),
                          if (jobCard.status.toLowerCase() == 'in_production')
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.check_circle, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text(
                                    'In Production Pipeline (Pending Job Stage)',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                  ),
                                ],
                              ),
                            )
                          else
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                              onPressed: () => _pushToProductionJob(context, ref, jobCard),
                              icon: const Icon(Icons.rocket_launch),
                              label: const Text('🚀 Push to Production Pipeline (Pending Jobs)'),
                            ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text('Error loading Master Card: $err'),
              ),
              const SizedBox(height: 16),
              const JobCardAttachmentsWidget(),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pushToProductionJob(BuildContext context, WidgetRef ref, JobCardModel jobCard) async {
    try {
      final prodRepo = ref.read(productionRepositoryProvider);
      final prodJob = ProductionJobModel(
        id: '',
        plantId: jobCard.plantId.isEmpty ? DefaultPlant.id : jobCard.plantId,
        jobDocNo: jobCard.jobCardNo,
        clientName: jobCard.customerName,
        orderDate: DateTime.now(),
        poNumber: jobCard.poNumber,
        materialDescription: jobCard.productName,
        totalReqQty: jobCard.targetOrderQty,
        gearTeethCount: 96,
        ups: jobCard.ups > 0 ? jobCard.ups : 2,
        paperSizeMm: jobCard.paperSize,
        substrateMaterial: 'Self-Adhesive Chromo Paper',
        labelSize: '${jobCard.paperSize.toInt()} mm',
        pendingSubStatus: PendingSubStatus.newPending,
        currentStage: ProductionStage.pending,
        paperStatus: 'Available',
        plateStatus: jobCard.plateCode.isNotEmpty ? 'Ready' : 'Pending',
        punchStatus: jobCard.dieCode.isNotEmpty ? 'Ready' : 'Pending',
        plantLocation: 'DAMAN',
        createdAt: DateTime.now(),
        createdBy: 'master_card_handover',
      );

      await prodRepo.createProductionJob(prodJob);

      final repo = ref.read(jobCardRepositoryProvider);
      await repo.updateJobCardStatus(jobCard.id, 'in_production');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🚀 Job Card [${jobCard.jobCardNo}] pushed to Production Pipeline (Pending Stage)!'),
            backgroundColor: AppTheme.accentEmerald,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error pushing to production: $e'), backgroundColor: AppTheme.danger),
        );
      }
    }
  }

  void _openPrintPreview(BuildContext context, JobCardModel jobCard) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          appBar: AppBar(
            title: Text('PGPL Job Sheet (${jobCard.jobCardNo})'),
          ),
          body: JobSheetPrintView(jobCard: jobCard),
        ),
      ),
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

              // Automatically push job to Production Pipeline (Pending Stage)
              await _pushToProductionJob(context, ref, jobCard);

              if (ctx.mounted) {
                Navigator.of(ctx).pop();
                ref.invalidate(masterCardFutureProvider(jobCard.id));
              }
            },
            child: const Text('Confirm Handover & Issue to Production'),
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

