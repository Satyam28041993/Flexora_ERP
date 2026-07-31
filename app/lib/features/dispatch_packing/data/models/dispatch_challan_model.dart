import 'package:flutter/foundation.dart';

/// Dispatch Challan Data Model.
///
/// Implements Section 8 (item 17) of Doc/Flexora-Master-Requirements-v1.2.md:
/// Dispatch Challan, Vehicle No, Dispatched Qty vs Balance Qty tracking.
@immutable
class DispatchChallanModel {
  final String id;
  final String plantId;

  final String challanNo; // e.g. DC-2026-001
  final String jobCardId;
  final String jobCardNo;
  final String poNumber;

  final String customerName;
  final String shippingAddress;
  final String vehicleNo;

  final double targetOrderQtyPcs;
  final double dispatchedQtyPcs;
  final double balanceQtyPcs;

  final DateTime dispatchDate;
  final String dispatchedBy;

  final DateTime createdAt;
  final String createdBy;

  const DispatchChallanModel({
    required this.id,
    required this.plantId,
    required this.challanNo,
    required this.jobCardId,
    required this.jobCardNo,
    required this.poNumber,
    required this.customerName,
    required this.shippingAddress,
    required this.vehicleNo,
    required this.targetOrderQtyPcs,
    required this.dispatchedQtyPcs,
    required this.balanceQtyPcs,
    required this.dispatchDate,
    required this.dispatchedBy,
    required this.createdAt,
    required this.createdBy,
  });

  factory DispatchChallanModel.fromMap(String id, Map<String, dynamic> map) {
    return DispatchChallanModel(
      id: id,
      plantId: map['plantId'] as String? ?? 'plant-1',
      challanNo: map['challanNo'] as String? ?? '',
      jobCardId: map['jobCardId'] as String? ?? '',
      jobCardNo: map['jobCardNo'] as String? ?? '',
      poNumber: map['poNumber'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      shippingAddress: map['shippingAddress'] as String? ?? '',
      vehicleNo: map['vehicleNo'] as String? ?? '',
      targetOrderQtyPcs: (map['targetOrderQtyPcs'] as num?)?.toDouble() ?? 0.0,
      dispatchedQtyPcs: (map['dispatchedQtyPcs'] as num?)?.toDouble() ?? 0.0,
      balanceQtyPcs: (map['balanceQtyPcs'] as num?)?.toDouble() ?? 0.0,
      dispatchDate: map['dispatchDate'] != null
          ? DateTime.parse(map['dispatchDate'] as String)
          : DateTime.now(),
      dispatchedBy: map['dispatchedBy'] as String? ?? 'system',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      createdBy: map['createdBy'] as String? ?? 'system',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plantId': plantId,
      'challanNo': challanNo,
      'jobCardId': jobCardId,
      'jobCardNo': jobCardNo,
      'poNumber': poNumber,
      'customerName': customerName,
      'shippingAddress': shippingAddress,
      'vehicleNo': vehicleNo,
      'targetOrderQtyPcs': targetOrderQtyPcs,
      'dispatchedQtyPcs': dispatchedQtyPcs,
      'balanceQtyPcs': balanceQtyPcs,
      'dispatchDate': dispatchDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  bool get isFullyDispatched => balanceQtyPcs <= 0;
}
