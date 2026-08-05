import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/order_model.dart';
import '../../logic/order_providers.dart';
import 'order_detail_screen.dart';
import 'order_form_screen.dart';

class OrderListScreen extends ConsumerStatefulWidget {
  const OrderListScreen({super.key});

  @override
  ConsumerState<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends ConsumerState<OrderListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Orders (Order Intake)'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const OrderFormScreen()),
        ),
        icon: const Icon(Icons.add_task),
        label: const Text('New Order Entry'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by PO Number, Customer Name, or Label SKU...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                final filtered = orders.where((o) {
                  if (_searchQuery.isEmpty) return true;
                  return o.poNumber.toLowerCase().contains(_searchQuery) ||
                      o.customerName.toLowerCase().contains(_searchQuery) ||
                      o.lineItems.any((item) => item.itemName.toLowerCase().contains(_searchQuery));
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No Purchase Orders registered yet.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _POCard(order: filtered[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error loading Purchase Orders: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _POCard extends ConsumerWidget {
  const _POCard({required this.order});

  final OrderModel order;

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppTheme.danger),
            const SizedBox(width: 8),
            Text('Delete PO [${order.poNumber}]'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete Purchase Order "${order.poNumber}" for ${order.customerName}?\n\nThis action cannot be undone.',
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
                final repo = ref.read(orderRepositoryProvider);
                await repo.deleteOrder(order.id);
                ref.invalidate(ordersStreamProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('PO [${order.poNumber}] deleted successfully!'),
                      backgroundColor: Colors.green.shade800,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting PO: $e'),
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
    final o = order;
    final dateFormat = DateFormat('dd-MM-yyyy');

    return Card(
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: o.id)),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(o.poNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                if (o.attachmentFileName != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.picture_as_pdf, size: 12, color: Colors.red),
                        SizedBox(width: 4),
                        Text('ATTACHED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            Text('₹${o.grandTotalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.accentEmerald)),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Customer: ${o.customerName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text('PO Date: ${dateFormat.format(o.poDate)}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(width: 16),
                  Text('${o.lineItems.length} Label SKU(s)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                  const SizedBox(width: 16),
                  Text('${o.totalQuantityPcs.toInt()} Pcs', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
              tooltip: 'Edit PO',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => OrderFormScreen(order: o)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppTheme.danger, size: 20),
              tooltip: 'Delete PO',
              onPressed: () => _confirmDelete(context, ref),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
