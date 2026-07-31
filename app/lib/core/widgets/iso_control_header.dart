import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Reusable ISO Document Control Header Widget.
///
/// Implements Golden Rule 3 & Section 0A of Doc/Flexora-Master-Requirements-v1.2.md:
/// Standardized document-control header for official forms, checklists, and records.
class ISOControlHeader extends StatelessWidget {
  const ISOControlHeader({
    super.key,
    required this.docTitle,
    required this.docNo,
    required this.department,
    this.revisionNo = '00',
    this.effectiveDate = '01-08-2026',
    this.preparedBy = 'Pre-Press / QC',
    this.approvedBy = 'Plant Head',
  });

  final String docTitle;
  final String docNo;
  final String department;
  final String revisionNo;
  final String effectiveDate;
  final String preparedBy;
  final String approvedBy;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4),
        color: Colors.grey.shade50,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'PGPL / ISO',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  docTitle.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.primary),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'DOC NO: $docNo',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.primary),
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetaItem('Dept', department),
              _buildMetaItem('Rev No.', revisionNo),
              _buildMetaItem('Effective Date', effectiveDate),
              _buildMetaItem('Prepared By', preparedBy),
              _buildMetaItem('Approved By', approvedBy),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
      ],
    );
  }
}
