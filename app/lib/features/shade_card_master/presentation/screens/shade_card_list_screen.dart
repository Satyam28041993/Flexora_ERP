import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/shade_card_model.dart';
import '../../logic/shade_card_providers.dart';
import 'shade_card_detail_screen.dart';
import 'shade_card_form_screen.dart';

class ShadeCardListScreen extends ConsumerStatefulWidget {
  const ShadeCardListScreen({super.key, this.productId});

  final String? productId;

  @override
  ConsumerState<ShadeCardListScreen> createState() => _ShadeCardListScreenState();
}

class _ShadeCardListScreenState extends ConsumerState<ShadeCardListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final shadeCardsAsync = ref.watch(shadeCardsStreamProvider(widget.productId));

    return Scaffold(
      appBar: AppBar(title: const Text('Shade Card Management')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ShadeCardFormScreen()),
        ),
        icon: const Icon(Icons.palette_outlined),
        label: const Text('New Shade Card'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by Shade Code, Customer, Job No, or SKU...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: shadeCardsAsync.when(
              data: (shadeCards) {
                final filtered = shadeCards.where((s) {
                  if (_searchQuery.isEmpty) return true;
                  return s.shadeCardCode.toLowerCase().contains(_searchQuery) ||
                      s.customerName.toLowerCase().contains(_searchQuery) ||
                      s.internalSkuCode.toLowerCase().contains(_searchQuery) ||
                      s.jobCardNo.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No Shade Cards registered.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _ShadeCardItem(shadeCard: filtered[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error loading Shade Cards: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShadeCardItem extends StatelessWidget {
  const _ShadeCardItem({required this.shadeCard});

  final ShadeCardModel shadeCard;

  @override
  Widget build(BuildContext context) {
    final isApproved = shadeCard.status == ShadeCardStatus.approved;

    return Card(
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ShadeCardDetailScreen(shadeCardId: shadeCard.id)),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(shadeCard.shadeCardCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
            Row(
              children: [
                if (shadeCard.isPermanentReference)
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'PERMANENT REF',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ),
                Chip(
                  label: Text(shadeCard.status.toUpperCase()),
                  backgroundColor: isApproved ? Colors.green.shade50 : Colors.orange.shade50,
                  labelStyle: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isApproved ? Colors.green.shade800 : Colors.orange.shade800,
                  ),
                ),
              ],
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${shadeCard.productName} (${shadeCard.internalSkuCode})', style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('Customer: ${shadeCard.customerName} | Job No: ${shadeCard.jobCardNo}',
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppTheme.primary, size: 20),
              tooltip: 'Edit Shade Card',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ShadeCardFormScreen(shadeCard: shadeCard)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              tooltip: 'Delete Shade Card',
              onPressed: () => showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Shade Card Confirmation'),
                  content: Text('Are you sure you want to delete Shade Card [${shadeCard.shadeCardCode}]?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800, foregroundColor: Colors.white),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Deleted Shade Card [${shadeCard.shadeCardCode}]!'), backgroundColor: Colors.red.shade800),
                        );
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                    ),
                  ],
                ),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
