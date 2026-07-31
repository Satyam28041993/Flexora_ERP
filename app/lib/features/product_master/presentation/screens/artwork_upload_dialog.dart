import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/artwork_version_model.dart';
import '../../logic/product_providers.dart';

class ArtworkUploadDialog extends ConsumerStatefulWidget {
  const ArtworkUploadDialog({
    super.key,
    required this.productId,
    required this.nextVersionNumber,
  });

  final String productId;
  final int nextVersionNumber;

  @override
  ConsumerState<ArtworkUploadDialog> createState() => _ArtworkUploadDialogState();
}

class _ArtworkUploadDialogState extends ConsumerState<ArtworkUploadDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fileNameController;
  late TextEditingController _storagePathController;
  late TextEditingController _remarksController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fileNameController = TextEditingController();
    _storagePathController = TextEditingController();
    _remarksController = TextEditingController();
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    _storagePathController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(productRepositoryProvider);

      final artwork = ArtworkVersionModel(
        id: '',
        productId: widget.productId,
        versionNumber: widget.nextVersionNumber,
        fileName: _fileNameController.text.trim(),
        storagePath: _storagePathController.text.trim().isNotEmpty
            ? _storagePathController.text.trim()
            : 'artworks/${widget.productId}/v${widget.nextVersionNumber}_${_fileNameController.text.trim()}',
        status: 'pending',
        remarks: _remarksController.text.trim().isEmpty ? null : _remarksController.text.trim(),
        createdAt: DateTime.now(),
        createdBy: 'system',
      );

      await repo.addArtworkVersion(widget.productId, artwork);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Artwork v${widget.nextVersionNumber} uploaded successfully')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading artwork: $e'), backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.cloud_upload_outlined, color: AppTheme.primary),
          const SizedBox(width: 8),
          Text('Upload Artwork v${widget.nextVersionNumber}'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _fileNameController,
              decoration: const InputDecoration(
                labelText: 'File Name *',
                hintText: 'e.g. Syrup_Label_v1_Final.pdf',
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _storagePathController,
              decoration: const InputDecoration(
                labelText: 'Storage Reference Path (Optional)',
                hintText: 'Custom Firebase Storage path',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _remarksController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Change Remarks / Notes',
                hintText: 'e.g. Revised ingredient text per customer email',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _isSaving ? null : _submit,
          icon: _isSaving
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.upload),
          label: Text(_isSaving ? 'Uploading...' : 'Save Artwork Version'),
        ),
      ],
    );
  }
}
