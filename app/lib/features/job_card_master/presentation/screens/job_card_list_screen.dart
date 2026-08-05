import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/job_card_model.dart';
import '../../logic/job_card_providers.dart';
import 'job_card_detail_screen.dart';
import 'job_card_form_screen.dart';

class JobCardListScreen extends ConsumerStatefulWidget {
  const JobCardListScreen({super.key});

  @override
  ConsumerState<JobCardListScreen> createState() => _JobCardListScreenState();
}

class _JobCardListScreenState extends ConsumerState<JobCardListScreen> {
  String _searchQuery = '';
  String _selectedStatusFilter = 'All Statuses';
  String _selectedCustomerFilter = 'All Customers';

  @override
  Widget build(BuildContext context) {
    final jobCardsAsync = ref.watch(jobCardsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Job Cards Master & Dispatch Log')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const JobCardFormScreen()),
        ),
        icon: const Icon(Icons.add_task),
        label: const Text('New Job Card'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by Job Card No, PO, Customer, SKU, or Product Name...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _selectedStatusFilter,
                        decoration: const InputDecoration(labelText: 'Filter Status', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                        items: const [
                          DropdownMenuItem(value: 'All Statuses', child: Text('All Statuses')),
                          DropdownMenuItem(value: 'draft', child: Text('Draft / Planned')),
                          DropdownMenuItem(value: 'released', child: Text('Released to Press')),
                          DropdownMenuItem(value: 'in_progress', child: Text('In Production')),
                          DropdownMenuItem(value: 'completed', child: Text('Completed')),
                        ],
                        onChanged: (val) => setState(() => _selectedStatusFilter = val!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _selectedCustomerFilter,
                        decoration: const InputDecoration(labelText: 'Filter Customer', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                        items: const [
                          DropdownMenuItem(value: 'All Customers', child: Text('All Customers')),
                          DropdownMenuItem(value: 'RALLIS', child: Text('RALLIS INDIA')),
                          DropdownMenuItem(value: 'OCTAGREEN', child: Text('OCTAGREEN')),
                          DropdownMenuItem(value: 'Surya', child: Text('Surya Aries')),
                        ],
                        onChanged: (val) => setState(() => _selectedCustomerFilter = val!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: jobCardsAsync.when(
              data: (jobCards) {
                final filtered = jobCards.where((j) {
                  if (_selectedStatusFilter != 'All Statuses' && j.status.toLowerCase() != _selectedStatusFilter.toLowerCase()) return false;
                  if (_selectedCustomerFilter != 'All Customers' && !j.customerName.toLowerCase().contains(_selectedCustomerFilter.toLowerCase())) return false;
                  if (_searchQuery.isEmpty) return true;
                  return j.jobCardNo.toLowerCase().contains(_searchQuery) ||
                      j.poNumber.toLowerCase().contains(_searchQuery) ||
                      j.customerName.toLowerCase().contains(_searchQuery) ||
                      j.productName.toLowerCase().contains(_searchQuery) ||
                      j.internalSkuCode.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No Job Cards issued yet.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _JobCardItem(jobCard: filtered[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error loading Job Cards: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _JobCardItem extends ConsumerWidget {
  const _JobCardItem({required this.jobCard});

  final JobCardModel jobCard;

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppTheme.danger),
            const SizedBox(width: 8),
            Text('Delete Job Card [${jobCard.jobCardNo}]'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete Job Card "${jobCard.jobCardNo}" for ${jobCard.productName} (${jobCard.customerName})?\n\nThis action cannot be undone.',
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
                final repo = ref.read(jobCardRepositoryProvider);
                await repo.deleteJobCard(jobCard.id);
                ref.invalidate(jobCardsStreamProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Job Card [${jobCard.jobCardNo}] deleted successfully!'),
                      backgroundColor: Colors.green.shade800,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting Job Card: $e'),
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
    return Card(
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => JobCardDetailScreen(jobCardId: jobCard.id)),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              jobCard.jobCardNo,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary),
            ),
            Chip(
              label: Text(jobCard.status.toUpperCase()),
              backgroundColor: _getStatusColor(jobCard.status).withAlpha(25),
              labelStyle: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(jobCard.status),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${jobCard.productName} (${jobCard.internalSkuCode})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                'Customer: ${jobCard.customerName} | PO: ${jobCard.poNumber}',
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text('Order Qty: ${jobCard.targetOrderQty.toInt()}', style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 16),
                  Text('Planned Qty: ${jobCard.plannedProductionQty.toInt()}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                ],
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_note, color: AppTheme.primary, size: 22),
              tooltip: 'Edit Job Card',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => JobCardFormScreen(jobCard: jobCard)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppTheme.danger, size: 20),
              tooltip: 'Delete Job Card',
              onPressed: () => _confirmDelete(context, ref),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case JobCardStatus.prePressReady:
        return Colors.blue.shade800;
      case JobCardStatus.scheduled:
        return Colors.purple.shade800;
      case JobCardStatus.inProduction:
        return Colors.orange.shade800;
      case JobCardStatus.completed:
        return Colors.green.shade800;
      default:
        return Colors.grey.shade800;
    }
  }
}
