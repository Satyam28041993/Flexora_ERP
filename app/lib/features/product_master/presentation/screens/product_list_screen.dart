import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/product_model.dart';
import '../../logic/product_providers.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key, this.customerId});

  final String? customerId;

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  String _searchQuery = '';
  String _selectedClientFilter = 'All Clients';
  String _selectedMaterialFilter = 'All Substrates';
  String _selectedArtworkFilter = 'All Statuses';

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider(widget.customerId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product / SKU Master Catalog'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ProductFormScreen(preselectedCustomerId: widget.customerId)),
        ),
        icon: const Icon(Icons.add_box),
        label: const Text('New SKU'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by SKU Code, Product Name, Material, or Customer...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
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
                        value: _selectedClientFilter,
                        decoration: const InputDecoration(labelText: 'Filter by Client', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                        items: const [
                          DropdownMenuItem(value: 'All Clients', child: Text('All Clients')),
                          DropdownMenuItem(value: 'RALLIS', child: Text('RALLIS INDIA')),
                          DropdownMenuItem(value: 'OCTAGREEN', child: Text('OCTAGREEN')),
                          DropdownMenuItem(value: 'Surya', child: Text('Surya Aries')),
                        ],
                        onChanged: (val) => setState(() => _selectedClientFilter = val!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _selectedMaterialFilter,
                        decoration: const InputDecoration(labelText: 'Filter Substrate', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                        items: const [
                          DropdownMenuItem(value: 'All Substrates', child: Text('All Substrates')),
                          DropdownMenuItem(value: 'CHROMO', child: Text('CHROMO Paper')),
                          DropdownMenuItem(value: 'PP WHITE', child: Text('PP WHITE')),
                          DropdownMenuItem(value: 'SILVER', child: Text('SILVER Paper')),
                          DropdownMenuItem(value: 'VOID', child: Text('VOID Film')),
                        ],
                        onChanged: (val) => setState(() => _selectedMaterialFilter = val!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _selectedArtworkFilter,
                        decoration: const InputDecoration(labelText: 'Artwork Status', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                        items: const [
                          DropdownMenuItem(value: 'All Statuses', child: Text('All Statuses')),
                          DropdownMenuItem(value: 'approved', child: Text('Approved')),
                          DropdownMenuItem(value: 'pending', child: Text('Pending Approval')),
                        ],
                        onChanged: (val) => setState(() => _selectedArtworkFilter = val!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: productsAsync.when(
              data: (products) {
                final filtered = products.where((p) {
                  if (_selectedClientFilter != 'All Clients' && !p.customerName.toLowerCase().contains(_selectedClientFilter.toLowerCase())) return false;
                  if (_selectedMaterialFilter != 'All Substrates' && !p.labelSpec.substrateMaterial.toLowerCase().contains(_selectedMaterialFilter.toLowerCase())) return false;
                  if (_selectedArtworkFilter != 'All Statuses' && p.artworkApprovalStatus.toLowerCase() != _selectedArtworkFilter.toLowerCase()) return false;
                  if (_searchQuery.isEmpty) return true;
                  return p.productName.toLowerCase().contains(_searchQuery) ||
                      p.internalSkuCode.toLowerCase().contains(_searchQuery) ||
                      p.customerName.toLowerCase().contains(_searchQuery) ||
                      p.customerProductCode.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return _EmptyProductsState(isSearching: _searchQuery.isNotEmpty);
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _ProductCard(product: filtered[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Error loading product catalog.\n$error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.danger),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyProductsState extends StatelessWidget {
  const _EmptyProductsState({required this.isSearching});

  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 56, color: AppTheme.textSecondary),
          const SizedBox(height: 12),
          Text(
            isSearching ? 'No matching products found' : 'No products/SKUs in master yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            isSearching
                ? 'Try searching with a different SKU code or product name.'
                : 'Click "New SKU" to create your first Product Master record.',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  const _ProductCard({required this.product});

  final ProductModel product;

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppTheme.danger),
            const SizedBox(width: 8),
            Text('Delete Product SKU [${product.internalSkuCode}]'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete SKU "${product.productName}" (${product.internalSkuCode}) for ${product.customerName}?\n\nThis action cannot be undone.',
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
                final repo = ref.read(productRepositoryProvider);
                await repo.deleteProduct(product.id);
                ref.invalidate(productsStreamProvider(product.customerId));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('SKU [${product.productName}] deleted successfully!'),
                      backgroundColor: Colors.green.shade800,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting SKU: $e'),
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
    final isArtworkApproved = product.artworkApprovalStatus == ArtworkApprovalStatus.approved;

    return Card(
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: product.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.internalSkuCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      product.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isArtworkApproved ? Colors.green.shade50 : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isArtworkApproved ? Colors.green : Colors.orange,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isArtworkApproved ? Icons.verified : Icons.pending_actions,
                          size: 12,
                          color: isArtworkApproved ? Colors.green.shade800 : Colors.orange.shade800,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ARTWORK: ${product.artworkApprovalStatus.toUpperCase()}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isArtworkApproved ? Colors.green.shade800 : Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.edit_note, color: AppTheme.primary, size: 22),
                    tooltip: 'Edit SKU',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ProductFormScreen(product: product)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppTheme.danger, size: 20),
                    tooltip: 'Delete SKU',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    onPressed: () => _confirmDelete(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                product.productName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  _buildChipInfo(Icons.aspect_ratio, product.labelSpec.dimensionsText),
                  _buildChipInfo(Icons.color_lens_outlined, '${product.printSpec.colorCount} Colors (${product.printSpec.printMethod})'),
                  _buildChipInfo(Icons.layers_outlined, product.labelSpec.substrateMaterial),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChipInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }
}
