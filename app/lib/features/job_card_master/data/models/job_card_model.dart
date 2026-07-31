import 'package:flutter/foundation.dart';

/// Job Card Data Model.
///
/// Implements Section 4 & Section 8 (item 4) of Doc/Flexora-Master-Requirements-v1.2.md:
/// Pre-Press issues Job Card + Master Card for Production handover.
@immutable
class JobCardModel {
  final String id;
  final String plantId;

  final String jobCardNo; // e.g. JC-2026-001 or 06/021
  final String orderId;
  final String poNumber;

  final String customerId;
  final String customerName;

  final String productId;
  final String internalSkuCode;
  final String productName;

  final double targetOrderQty; // Order line item quantity
  final double plannedProductionQty; // Target + setup waste allowance

  final DateTime? deliveryDueDate;
  final DateTime? plannedProductionDate;

  final String plateId;
  final String plateCode;

  final String dieId;
  final String dieCode;

  /// Process Route for this specific Job Card (inherited from Product Master)
  final List<String> processRoute;

  final String status; // Draft, PrePressReady, Scheduled, InProduction, Completed, Cancelled

  final DateTime createdAt;
  final String createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;

  const JobCardModel({
    required this.id,
    required this.plantId,
    required this.jobCardNo,
    required this.orderId,
    required this.poNumber,
    required this.customerId,
    required this.customerName,
    required this.productId,
    required this.internalSkuCode,
    required this.productName,
    required this.targetOrderQty,
    required this.plannedProductionQty,
    required this.createdAt,
    required this.createdBy,
    this.deliveryDueDate,
    this.plannedProductionDate,
    this.plateId = '',
    this.plateCode = '',
    this.dieId = '',
    this.dieCode = '',
    this.processRoute = const ['Printing', 'Online Punching', 'Checking', 'Slitting', 'Packing'],
    this.status = JobCardStatus.draft,
    this.updatedAt,
    this.updatedBy,
  });

  factory JobCardModel.fromMap(String id, Map<String, dynamic> map) {
    return JobCardModel(
      id: id,
      plantId: map['plantId'] as String? ?? 'plant-1',
      jobCardNo: map['jobCardNo'] as String? ?? '',
      orderId: map['orderId'] as String? ?? '',
      poNumber: map['poNumber'] as String? ?? '',
      customerId: map['customerId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      productId: map['productId'] as String? ?? '',
      internalSkuCode: map['internalSkuCode'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      targetOrderQty: (map['targetOrderQty'] as num?)?.toDouble() ?? 0.0,
      plannedProductionQty: (map['plannedProductionQty'] as num?)?.toDouble() ?? 0.0,
      deliveryDueDate: map['deliveryDueDate'] != null
          ? DateTime.parse(map['deliveryDueDate'] as String)
          : null,
      plannedProductionDate: map['plannedProductionDate'] != null
          ? DateTime.parse(map['plannedProductionDate'] as String)
          : null,
      plateId: map['plateId'] as String? ?? '',
      plateCode: map['plateCode'] as String? ?? '',
      dieId: map['dieId'] as String? ?? '',
      dieCode: map['dieCode'] as String? ?? '',
      processRoute: (map['processRoute'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['Printing', 'Online Punching', 'Checking', 'Slitting', 'Packing'],
      status: map['status'] as String? ?? JobCardStatus.draft,
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
      'jobCardNo': jobCardNo,
      'orderId': orderId,
      'poNumber': poNumber,
      'customerId': customerId,
      'customerName': customerName,
      'productId': productId,
      'internalSkuCode': internalSkuCode,
      'productName': productName,
      'targetOrderQty': targetOrderQty,
      'plannedProductionQty': plannedProductionQty,
      'deliveryDueDate': deliveryDueDate?.toIso8601String(),
      'plannedProductionDate': plannedProductionDate?.toIso8601String(),
      'plateId': plateId,
      'plateCode': plateCode,
      'dieId': dieId,
      'dieCode': dieCode,
      'processRoute': processRoute,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedAt': updatedAt?.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }
}

class JobCardStatus {
  static const String draft = 'Draft';
  static const String prePressReady = 'PrePressReady';
  static const String scheduled = 'Scheduled';
  static const String inProduction = 'InProduction';
  static const String completed = 'Completed';
  static const String cancelled = 'Cancelled';

  static const List<String> values = [
    draft,
    prePressReady,
    scheduled,
    inProduction,
    completed,
    cancelled,
  ];
}
