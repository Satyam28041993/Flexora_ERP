import 'package:flutter/foundation.dart';

/// Packing List Data Model.
///
/// Implements Section 8 (item 17) of Doc/Flexora-Master-Requirements-v1.2.md:
/// Packing list: boxes/rolls breakdown, total pcs, packed date & inspector.
@immutable
class PackingListModel {
  final String id;
  final String plantId;

  final String packingListNo; // e.g. PL-2026-001
  final String jobCardId;
  final String jobCardNo;

  final String customerName;
  final String productName;

  final int totalBoxes;
  final int totalRolls;
  final double totalQuantityPcs;

  final String packedBy;
  final DateTime packingDate;

  final DateTime createdAt;
  final String createdBy;

  const PackingListModel({
    required this.id,
    required this.plantId,
    required this.packingListNo,
    required this.jobCardId,
    required this.jobCardNo,
    required this.customerName,
    required this.productName,
    required this.totalBoxes,
    required this.totalRolls,
    required this.totalQuantityPcs,
    required this.packedBy,
    required this.packingDate,
    required this.createdAt,
    required this.createdBy,
  });

  factory PackingListModel.fromMap(String id, Map<String, dynamic> map) {
    return PackingListModel(
      id: id,
      plantId: map['plantId'] as String? ?? 'plant-1',
      packingListNo: map['packingListNo'] as String? ?? '',
      jobCardId: map['jobCardId'] as String? ?? '',
      jobCardNo: map['jobCardNo'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      totalBoxes: map['totalBoxes'] as int? ?? 1,
      totalRolls: map['totalRolls'] as int? ?? 1,
      totalQuantityPcs: (map['totalQuantityPcs'] as num?)?.toDouble() ?? 0.0,
      packedBy: map['packedBy'] as String? ?? '',
      packingDate: map['packingDate'] != null
          ? DateTime.parse(map['packingDate'] as String)
          : DateTime.now(),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      createdBy: map['createdBy'] as String? ?? 'system',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plantId': plantId,
      'packingListNo': packingListNo,
      'jobCardId': jobCardId,
      'jobCardNo': jobCardNo,
      'customerName': customerName,
      'productName': productName,
      'totalBoxes': totalBoxes,
      'totalRolls': totalRolls,
      'totalQuantityPcs': totalQuantityPcs,
      'packedBy': packedBy,
      'packingDate': packingDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }
}
