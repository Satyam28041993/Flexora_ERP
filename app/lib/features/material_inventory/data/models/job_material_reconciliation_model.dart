import 'package:flutter/foundation.dart';

/// Job-Wise Material Reconciliation Model.
///
/// Implements Section 6.5 & 6.7 of Doc/Flexora-Master-Requirements-v1.2.md:
/// FIVE DISTINCT VALUES (never treat as the same number):
/// 1. Planned Material (theoretical requirement)
/// 2. Issued Material (what Stores physically issued)
/// 3. Actual Consumption (what was used in production)
/// 4. Returned Material (usable leftover returned to Stores)
/// 5. Wastage (Issued - Returned - Actual Consumption)
///
/// Confirmed Formula: Net Material Taken = Issued - Returned
@immutable
class JobMaterialReconciliationModel {
  final String id;
  final String plantId;

  final String jobCardId;
  final String jobCardNo;
  final String customerName;
  final String productName;

  final double plannedRmt;
  final double issuedRmt;
  final double actualConsumptionRmt;
  final double returnedRmt;

  final DateTime createdAt;
  final String createdBy;
  final DateTime? updatedAt;

  const JobMaterialReconciliationModel({
    required this.id,
    required this.plantId,
    required this.jobCardId,
    required this.jobCardNo,
    required this.customerName,
    required this.productName,
    required this.plannedRmt,
    required this.createdAt,
    required this.createdBy,
    this.issuedRmt = 0.0,
    this.actualConsumptionRmt = 0.0,
    this.returnedRmt = 0.0,
    this.updatedAt,
  });

  factory JobMaterialReconciliationModel.fromMap(String id, Map<String, dynamic> map) {
    return JobMaterialReconciliationModel(
      id: id,
      plantId: map['plantId'] as String? ?? 'plant-1',
      jobCardId: map['jobCardId'] as String? ?? '',
      jobCardNo: map['jobCardNo'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      plannedRmt: (map['plannedRmt'] as num?)?.toDouble() ?? 0.0,
      issuedRmt: (map['issuedRmt'] as num?)?.toDouble() ?? 0.0,
      actualConsumptionRmt: (map['actualConsumptionRmt'] as num?)?.toDouble() ?? 0.0,
      returnedRmt: (map['returnedRmt'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      createdBy: map['createdBy'] as String? ?? 'system',
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plantId': plantId,
      'jobCardId': jobCardId,
      'jobCardNo': jobCardNo,
      'customerName': customerName,
      'productName': productName,
      'plannedRmt': plannedRmt,
      'issuedRmt': issuedRmt,
      'actualConsumptionRmt': actualConsumptionRmt,
      'returnedRmt': returnedRmt,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Confirmed Formula: Net Material Taken from Stock = Issued - Returned
  double get netMaterialTakenRmt => issuedRmt - returnedRmt;

  /// Wastage Formula: Issued - Returned - Actual Consumption
  double get wastageRmt => (issuedRmt - returnedRmt - actualConsumptionRmt).clamp(0.0, double.infinity);
}
