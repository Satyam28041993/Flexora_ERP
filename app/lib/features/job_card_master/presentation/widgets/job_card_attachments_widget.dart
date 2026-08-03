import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:printing/printing.dart';
import '../../../../core/theme/app_theme.dart';

/// Reusable Widget displaying downloadable PDF attachments for Job Sheet
class JobCardAttachmentsWidget extends StatefulWidget {
  const JobCardAttachmentsWidget({super.key});

  @override
  State<JobCardAttachmentsWidget> createState() => _JobCardAttachmentsWidgetState();
}

class _JobCardAttachmentsWidgetState extends State<JobCardAttachmentsWidget> {
  final Map<String, bool> _loadingMap = {};

  static const List<Map<String, String>> attachments = [
    {
      'title': 'Job Sheet Page 1 (Header & Specifications)',
      'file': 'PGPL JOB CARD PAGE 1.pdf',
      'path': 'assets/Jobcard Attachments/PGPL JOB CARD PAGE 1.pdf',
    },
    {
      'title': 'Job Sheet Page 2 (Production Details & Logs)',
      'file': 'PGPL JOB CARD PAGE 2.pdf',
      'path': 'assets/Jobcard Attachments/PGPL JOB CARD PAGE 2.pdf',
    },
    {
      'title': 'Job Sheet Page 3 (Inspection & Quality Control)',
      'file': 'PGPL JOB CARD PAGE 3.pdf',
      'path': 'assets/Jobcard Attachments/PGPL JOB CARD PAGE 3.pdf',
    },
    {
      'title': 'Job Sheet Page 4 (Despatch & Final Signoff)',
      'file': 'PGPL JOB CARD PAGE 4.pdf',
      'path': 'assets/Jobcard Attachments/PGPL JOB CARD PAGE 4.pdf',
    },
  ];

  Future<void> _downloadPdf(String assetPath, String fileName) async {
    setState(() => _loadingMap[fileName] = true);
    try {
      final bytes = await rootBundle.load(assetPath);
      await Printing.sharePdf(
        bytes: bytes.buffer.asUint8List(),
        filename: fileName,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading $fileName: $e'), backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingMap[fileName] = false);
    }
  }

  Future<void> _downloadAllPdfs() async {
    for (final item in attachments) {
      await _downloadPdf(item['path']!, item['file']!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              border: const Border(bottom: BorderSide(color: Colors.black, width: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: AppTheme.danger, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Job Card Attachments & Master Templates (4 Pages)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: _downloadAllPdfs,
                  icon: const Icon(Icons.download, size: 16, color: AppTheme.primary),
                  label: const Text('Download All Pages', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),

          // Attachment Items Grid
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: attachments.map((item) {
                final filename = item['file']!;
                final title = item['title']!;
                final path = item['path']!;
                final isLoading = _loadingMap[filename] ?? false;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border.all(color: Colors.grey.shade300, width: 0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf, color: AppTheme.danger, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            Text(filename, style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: isLoading ? null : () => _downloadPdf(path, filename),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        icon: isLoading
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.file_download_outlined, size: 16),
                        label: Text(isLoading ? 'Opening...' : 'Download PDF', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
