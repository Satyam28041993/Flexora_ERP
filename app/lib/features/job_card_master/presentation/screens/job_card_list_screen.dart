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

class _JobCardItem extends StatelessWidget {
  const _JobCardItem({required this.jobCard});

  final JobCardModel jobCard;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
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
        trailing: const Icon(Icons.chevron_right),
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
