import 'package:flutter/foundation.dart';

/// Finished Roll Traceability Data Model.
///
/// Implements Section 8 (item 16) of Doc/Flexora-Master-Requirements-v1.2.md:
/// Finished Roll traceability: quantity, labels/roll, roll ID, winding direction, core size, job reference.
@immutable
class FinishedRollModel {
  final String id;
  final String plantId;

  final String rollCode; // e.g. F-ROLL-001
  final String jobCardId;
  final String jobCardNo;

  final String customerName;
  final String productName;

  final int labelsCount;
  final double coreSizeMm;
  final String windingDirection;

  final String? boxNumber;
  final String status; // InStock, Packed, Dispatched

  final DateTime createdAt;
  final String createdBy;

  const FinishedRollModel({
    required this.id,
    required this.plantId,
    required this.rollCode,
    required this.jobCardId,
    required this.jobCardNo,
    required this.customerName,
    required this.productName,
    required this.labelsCount,
    required this.createdAt,
    required this.createdBy,
    this.coreSizeMm = 76.0,
    this.windingDirection = 'Head First',
    this.boxNumber,
    this.status = 'InStock',
  });

  factory FinishedRollModel.fromMap(String id, Map<String, dynamic> map) {
    return FinishedRollModel(
      id: id,
      plantId: map['plantId'] as String? ?? 'plant-1',
      rollCode: map['rollCode'] as String? ?? '',
      jobCardId: map['jobCardId'] as String? ?? '',
      jobCardNo: map['jobCardNo'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      labelsCount: map['labelsCount'] as int? ?? 1000,
      coreSizeMm: (map['coreSizeMm'] as num?)?.toDouble() ?? 76.0,
      windingDirection: map['windingDirection'] as String? ?? 'Head First',
      boxNumber: map['boxNumber'] as String?,
      status: map['status'] as String? ?? 'InStock',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      createdBy: map['createdBy'] as String? ?? 'system',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plantId': plantId,
      'rollCode': rollCode,
      'jobCardId': jobCardId,
      'jobCardNo': jobCardNo,
      'customerName': customerName,
      'productName': productName,
      'labelsCount': labelsCount,
      'coreSizeMm': coreSizeMm,
      'windingDirection': windingDirection,
      'boxNumber': boxNumber,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }
}
