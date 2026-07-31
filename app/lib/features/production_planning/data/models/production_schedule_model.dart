import 'package:flutter/foundation.dart';

/// Production Schedule & Machine Queue Data Model.
@immutable
class ProductionScheduleModel {
  final String id;
  final String plantId;

  final String jobCardId;
  final String jobCardNo;
  final String customerName;
  final String productName;
  final String internalSkuCode;

  final String machineId;
  final String machineName;

  final DateTime scheduledDate;
  final String shift; // Day, Night
  final int queuePriority; // Position in queue

  final double targetQuantity;
  final double plannedRmt;

  final String status; // Scheduled, InSetup, Running, OnHold, Completed, Cancelled

  final DateTime createdAt;
  final String createdBy;

  const ProductionScheduleModel({
    required this.id,
    required this.plantId,
    required this.jobCardId,
    required this.jobCardNo,
    required this.customerName,
    required this.productName,
    required this.internalSkuCode,
    required this.machineId,
    required this.machineName,
    required this.scheduledDate,
    required this.shift,
    required this.queuePriority,
    required this.targetQuantity,
    required this.plannedRmt,
    required this.status,
    required this.createdAt,
    required this.createdBy,
  });

  factory ProductionScheduleModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductionScheduleModel(
      id: id,
      plantId: map['plantId'] as String? ?? 'plant-1',
      jobCardId: map['jobCardId'] as String? ?? '',
      jobCardNo: map['jobCardNo'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      internalSkuCode: map['internalSkuCode'] as String? ?? '',
      machineId: map['machineId'] as String? ?? '',
      machineName: map['machineName'] as String? ?? '',
      scheduledDate: map['scheduledDate'] != null
          ? DateTime.parse(map['scheduledDate'] as String)
          : DateTime.now(),
      shift: map['shift'] as String? ?? 'Day',
      queuePriority: map['queuePriority'] as int? ?? 1,
      targetQuantity: (map['targetQuantity'] as num?)?.toDouble() ?? 0.0,
      plannedRmt: (map['plannedRmt'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? 'Scheduled',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      createdBy: map['createdBy'] as String? ?? 'system',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plantId': plantId,
      'jobCardId': jobCardId,
      'jobCardNo': jobCardNo,
      'customerName': customerName,
      'productName': productName,
      'internalSkuCode': internalSkuCode,
      'machineId': machineId,
      'machineName': machineName,
      'scheduledDate': scheduledDate.toIso8601String(),
      'shift': shift,
      'queuePriority': queuePriority,
      'targetQuantity': targetQuantity,
      'plannedRmt': plannedRmt,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }
}
