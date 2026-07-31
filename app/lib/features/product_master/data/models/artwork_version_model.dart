import 'package:flutter/foundation.dart';

/// Artwork Version Control Model.
///
/// Implements Section 5.4 of Doc/Flexora-Master-Requirements-v1.2.md:
/// Never overwrite approved artwork; maintain full immutable version history.
@immutable
class ArtworkVersionModel {
  final String id;
  final String productId;

  final int versionNumber; // v1, v2, v3...
  final String fileName;
  final String storagePath; // Firebase Storage reference path

  final String status; // pending, approved, rejected
  final String? approvedBy;
  final DateTime? approvalDate;
  final String? approvalEvidenceRef; // e.g. Customer Email Date/Ref

  final String? remarks;

  final DateTime createdAt;
  final String createdBy;

  const ArtworkVersionModel({
    required this.id,
    required this.productId,
    required this.versionNumber,
    required this.fileName,
    required this.storagePath,
    required this.status,
    required this.createdAt,
    required this.createdBy,
    this.approvedBy,
    this.approvalDate,
    this.approvalEvidenceRef,
    this.remarks,
  });

  factory ArtworkVersionModel.fromMap(String id, Map<String, dynamic> map) {
    return ArtworkVersionModel(
      id: id,
      productId: map['productId'] as String? ?? '',
      versionNumber: map['versionNumber'] as int? ?? 1,
      fileName: map['fileName'] as String? ?? '',
      storagePath: map['storagePath'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      approvedBy: map['approvedBy'] as String?,
      approvalDate: map['approvalDate'] != null ? DateTime.parse(map['approvalDate'] as String) : null,
      approvalEvidenceRef: map['approvalEvidenceRef'] as String?,
      remarks: map['remarks'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      createdBy: map['createdBy'] as String? ?? 'system',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'versionNumber': versionNumber,
      'fileName': fileName,
      'storagePath': storagePath,
      'status': status,
      'approvedBy': approvedBy,
      'approvalDate': approvalDate?.toIso8601String(),
      'approvalEvidenceRef': approvalEvidenceRef,
      'remarks': remarks,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  String get versionLabel => 'v$versionNumber';
}
