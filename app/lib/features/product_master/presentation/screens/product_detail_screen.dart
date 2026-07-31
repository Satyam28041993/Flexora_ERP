import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/artwork_version_model.dart';
import '../../data/models/product_model.dart';
import '../../logic/product_providers.dart';
import 'artwork_upload_dialog.dart';
import 'product_form_screen.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(productRepositoryProvider);
    final artworksAsync = ref.watch(productArtworksStreamProvider(productId));

    return FutureBuilder<ProductModel?>(
      future: repo.getProduct(productId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final product = snapshot.data;
        if (product == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Product Detail')),
            body: const Center(child: Text('Product SKU not found.')),
          );
        }

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text('${product.internalSkuCode} — Spec Sheet'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ProductFormScreen(product: product)),
                  ),
                ),
              ],
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.description_outlined), text: 'Technical Specs'),
                  Tab(icon: Icon(Icons.history_edu_outlined), text: 'Artwork Versions'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _TechnicalSpecTab(product: product),
                _ArtworkHistoryTab(
                  product: product,
                  artworksAsync: artworksAsync,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TechnicalSpecTab extends StatelessWidget {
  const _TechnicalSpecTab({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final label = product.labelSpec;
    final printSpec = product.printSpec;
    final machine = product.machineSpec;

    return ListView(
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
                      'SKU: ${product.internalSkuCode}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary),
                    ),
                    Chip(
                      label: Text('STATUS: ${product.status.toUpperCase()}'),
                      backgroundColor: product.status == ProductStatus.active
                          ? Colors.green.shade50
                          : Colors.grey.shade100,
                      labelStyle: TextStyle(
                        color: product.status == ProductStatus.active
                            ? Colors.green.shade800
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  product.productName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('Customer: ${product.customerName}',
                    style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                if (product.customerProductCode.isNotEmpty)
                  Text('Customer Product Code: ${product.customerProductCode}',
                      style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          title: '1. Label Dimensions & Material',
          icon: Icons.aspect_ratio,
          children: [
            _buildRow('Dimensions (W × H)', label.dimensionsText),
            _buildRow('Substrate / Material', label.substrateMaterial),
            if (label.gsmMicron.isNotEmpty) _buildRow('GSM / Micron', label.gsmMicron),
            _buildRow('Adhesive Type', label.adhesiveType),
            _buildRow('Release Liner', label.linerType),
          ],
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          title: '2. Printing & Finishing',
          icon: Icons.color_lens_outlined,
          children: [
            _buildRow('Printing Method', printSpec.printMethod),
            _buildRow('Number of Colors', '${printSpec.colorCount} Colors'),
            if (printSpec.pantoneCodes.isNotEmpty) _buildRow('Shades / Pantones', printSpec.pantoneCodes),
            _buildRow('Varnish', printSpec.varnishType),
            _buildRow('Lamination', printSpec.laminationType),
          ],
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          title: '3. Conversion & Machine Settings',
          icon: Icons.settings_suggest_outlined,
          children: [
            _buildRow('Web Width', '${machine.webWidthMm} mm'),
            _buildRow('Cylinder Repeat', '${machine.repeatCylinderMm} mm'),
            _buildRow('UPS Layout', '${machine.acrossUps} Across × ${machine.aroundUps} Around (Total: ${machine.totalUps} UPS)'),
            if (machine.punchDieCode.isNotEmpty) _buildRow('Punch/Die Code', machine.punchDieCode),
            _buildRow('Core Size', '${machine.coreSizeMm} mm'),
            _buildRow('Labels Per Roll', '${machine.labelsPerRoll}'),
            _buildRow('Winding Direction', machine.windingDirection),
          ],
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          title: '4. Configurable Manufacturing Route',
          icon: Icons.alt_route,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: product.processRoute.map((step) {
                return Chip(
                  avatar: const Icon(Icons.check_circle, size: 16, color: AppTheme.primary),
                  label: Text(step, style: const TextStyle(fontWeight: FontWeight.w600)),
                  backgroundColor: AppTheme.primary.withAlpha(20),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const Divider(height: 20),
            ...children,
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

class _ArtworkHistoryTab extends ConsumerWidget {
  const _ArtworkHistoryTab({
    required this.product,
    required this.artworksAsync,
  });

  final ProductModel product;
  final AsyncValue<List<ArtworkVersionModel>> artworksAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd-MM-yyyy HH:mm');

    return artworksAsync.when(
      data: (artworks) {
        final nextVersion = artworks.isEmpty ? 1 : artworks.first.versionNumber + 1;

        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => ArtworkUploadDialog(
                productId: product.id,
                nextVersionNumber: nextVersion,
              ),
            ),
            icon: const Icon(Icons.cloud_upload),
            label: Text('Upload Artwork v$nextVersion'),
          ),
          body: artworks.isEmpty
              ? _EmptyArtworkState(nextVersionNumber: nextVersion, productId: product.id)
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: artworks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final art = artworks[index];
                    final isCurrent = art.id == product.currentArtworkVersionId;
                    final isApproved = art.status == ArtworkApprovalStatus.approved;

                    return Card(
                      elevation: isCurrent ? 2 : 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isCurrent ? AppTheme.primary : Colors.transparent,
                          width: isCurrent ? 2 : 0,
                        ),
                      ),
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
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary.withAlpha(25),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        art.versionLabel,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    ),
                                    if (isCurrent) ...[
                                      const SizedBox(width: 8),
                                      const Chip(
                                        label: Text('CURRENT', style: TextStyle(fontSize: 10, color: Colors.white)),
                                        backgroundColor: AppTheme.primary,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ],
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isApproved ? Colors.green.shade50 : Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: isApproved ? Colors.green : Colors.orange),
                                  ),
                                  child: Text(
                                    art.status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isApproved ? Colors.green.shade800 : Colors.orange.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              art.fileName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text('Uploaded: ${dateFormat.format(art.createdAt)}',
                                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                            if (art.remarks != null) ...[
                              const SizedBox(height: 6),
                              Text('Remarks: ${art.remarks}',
                                  style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
                            ],
                            if (isApproved && art.approvedBy != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Approved by ${art.approvedBy} on ${art.approvalDate != null ? dateFormat.format(art.approvalDate!) : ''} (${art.approvalEvidenceRef ?? ''})',
                                style: TextStyle(fontSize: 12, color: Colors.green.shade800),
                              ),
                            ],
                            if (!isApproved) ...[
                              const Divider(height: 20),
                              Align(
                                alignment: Alignment.centerRight,
                                child: OutlinedButton.icon(
                                  onPressed: () => _showApprovalDialog(context, ref, art),
                                  icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                                  label: const Text('Record Customer Approval'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading artwork history: $err')),
    );
  }

  void _showApprovalDialog(BuildContext context, WidgetRef ref, ArtworkVersionModel art) {
    final approverController = TextEditingController(text: 'Customer Email');
    final refController = TextEditingController(text: 'Email Dated ${DateFormat('dd-MM-yyyy').format(DateTime.now())}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Record Customer Approval for ${art.versionLabel}'),
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
              decoration: const InputDecoration(
                labelText: 'Approval Evidence Reference',
                hintText: 'e.g. Email reference, signoff doc',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final repo = ref.read(productRepositoryProvider);
              await repo.updateArtworkApproval(
                productId: product.id,
                artworkId: art.id,
                status: ArtworkApprovalStatus.approved,
                approvedBy: approverController.text.trim(),
                approvalEvidenceRef: refController.text.trim(),
              );
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Approve Artwork'),
          ),
        ],
      ),
    );
  }
}

class _EmptyArtworkState extends StatelessWidget {
  const _EmptyArtworkState({
    required this.nextVersionNumber,
    required this.productId,
  });

  final int nextVersionNumber;
  final String productId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.image_not_supported_outlined, size: 56, color: AppTheme.textSecondary),
          const SizedBox(height: 12),
          Text('No Artwork uploaded yet', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          const Text(
            'Upload the first approved customer artwork file to link with this SKU.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
