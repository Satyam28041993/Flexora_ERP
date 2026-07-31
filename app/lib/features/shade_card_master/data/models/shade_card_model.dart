import 'package:flutter/foundation.dart';

/// Shade Card Management Data Model.
///
/// Implements Section 4 of Doc/Flexora-Master-Requirements-v1.2.md:
/// Critical distinction between Master Card & Shade Card.
/// - Created during printing from actual production output.
/// - Standard / Dark / Light shade samples.
/// - Customer Approval -> Stored as permanent reference for customer/product.
/// - System flags "APPROVED SHADE REFERENCE AVAILABLE" on repeat jobs.
@immutable
class ShadeCardModel {
  final String id;
  final String plantId;

  final String shadeCardCode; // e.g. SC-2026-001
  final String customerId;
  final String customerName;
  final String productId;
  final String internalSkuCode;
  final String productName;

  final String jobCardId;
  final String jobCardNo;

  final String artworkVersionId;
  final String artworkVersionLabel;

  final DateTime dateCreated;
  final String productionBatchRunNo;

  // Shade Evidence storage paths (Firebase Storage references)
  final String standardShadeStoragePath;
  final String? darkShadeStoragePath;
  final String? lightShadeStoragePath;

  final String status; // Pending, CustomerApprovalPending, Approved, Rejected
  final bool isPermanentReference;

  final String? approvedBy;
  final DateTime? approvalDate;
  final String? approvalEvidenceRef; // e.g. Customer Email / Signoff Ref
  final String? remarks;

  final DateTime createdAt;
  final String createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;

  const ShadeCardModel({
    required this.id,
    required this.plantId,
    required this.shadeCardCode,
    required this.customerId,
    required this.customerName,
    required this.productId,
    required this.internalSkuCode,
    required this.productName,
    required this.jobCardId,
    required this.jobCardNo,
    required this.artworkVersionId,
    required this.artworkVersionLabel,
    required this.dateCreated,
    required this.productionBatchRunNo,
    required this.standardShadeStoragePath,
    required this.createdAt,
    required this.createdBy,
    this.darkShadeStoragePath,
    this.lightShadeStoragePath,
    this.status = ShadeCardStatus.pending,
    this.isPermanentReference = false,
    this.approvedBy,
    this.approvalDate,
    this.approvalEvidenceRef,
    this.remarks,
    this.updatedAt,
    this.updatedBy,
  });

  factory ShadeCardModel.fromMap(String id, Map<String, dynamic> map) {
    return ShadeCardModel(
      id: id,
      plantId: map['plantId'] as String? ?? 'plant-1',
      shadeCardCode: map['shadeCardCode'] as String? ?? '',
      customerId: map['customerId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      productId: map['productId'] as String? ?? '',
      internalSkuCode: map['internalSkuCode'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      jobCardId: map['jobCardId'] as String? ?? '',
      jobCardNo: map['jobCardNo'] as String? ?? '',
      artworkVersionId: map['artworkVersionId'] as String? ?? '',
      artworkVersionLabel: map['artworkVersionLabel'] as String? ?? 'v1',
      dateCreated: map['dateCreated'] != null
          ? DateTime.parse(map['dateCreated'] as String)
          : DateTime.now(),
      productionBatchRunNo: map['productionBatchRunNo'] as String? ?? '',
      standardShadeStoragePath: map['standardShadeStoragePath'] as String? ?? '',
      darkShadeStoragePath: map['darkShadeStoragePath'] as String?,
      lightShadeStoragePath: map['lightShadeStoragePath'] as String?,
      status: map['status'] as String? ?? ShadeCardStatus.pending,
      isPermanentReference: map['isPermanentReference'] as bool? ?? false,
      approvedBy: map['approvedBy'] as String?,
      approvalDate: map['approvalDate'] != null
          ? DateTime.parse(map['approvalDate'] as String)
          : null,
      approvalEvidenceRef: map['approvalEvidenceRef'] as String?,
      remarks: map['remarks'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      createdBy: map['createdBy'] as String? ?? 'system',
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt'] as String) : null,
      updatedBy: map['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plantId': plantId,
      'shadeCardCode': shadeCardCode,
      'customerId': customerId,
      'customerName': customerName,
      'productId': productId,
      'internalSkuCode': internalSkuCode,
      'productName': productName,
      'jobCardId': jobCardId,
      'jobCardNo': jobCardNo,
      'artworkVersionId': artworkVersionId,
      'artworkVersionLabel': artworkVersionLabel,
      'dateCreated': dateCreated.toIso8601String(),
      'productionBatchRunNo': productionBatchRunNo,
      'standardShadeStoragePath': standardShadeStoragePath,
      'darkShadeStoragePath': darkShadeStoragePath,
      'lightShadeStoragePath': lightShadeStoragePath,
      'status': status,
      'isPermanentReference': isPermanentReference,
      'approvedBy': approvedBy,
      'approvalDate': approvalDate?.toIso8601String(),
      'approvalEvidenceRef': approvalEvidenceRef,
      'remarks': remarks,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedAt': updatedAt?.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }
}

class ShadeCardStatus {
  static const String pending = 'Pending';
  static const String customerApprovalPending = 'CustomerApprovalPending';
  static const String approved = 'Approved';
  static const String rejected = 'Rejected';

  static const List<String> values = [
    pending,
    customerApprovalPending,
    approved,
    rejected,
  ];
}
