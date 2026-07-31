import 'package:flutter/foundation.dart';

/// Transaction-Based Inventory Movement Model.
///
/// Implements Golden Rule 7 & Section 6.11 of Doc/Flexora-Master-Requirements-v1.2.md:
/// Stock quantities are never manually edited; every movement is a logged transaction.
@immutable
class MaterialTransactionModel {
  final String id;
  final String plantId;

  final String transactionType; // PurchaseReceipt, IssueToJob, LeftoverReturn, ProductionConsumption, Adjustment
  final String rollId;
  final String rollCode;

  final String? jobCardId;
  final String? jobCardNo;

  final double rmtQuantity;
  final String? remarks;

  final DateTime timestamp;
  final String performedBy;

  const MaterialTransactionModel({
    required this.id,
    required this.plantId,
    required this.transactionType,
    required this.rollId,
    required this.rollCode,
    required this.rmtQuantity,
    required this.timestamp,
    required this.performedBy,
    this.jobCardId,
    this.jobCardNo,
    this.remarks,
  });

  factory MaterialTransactionModel.fromMap(String id, Map<String, dynamic> map) {
    return MaterialTransactionModel(
      id: id,
      plantId: map['plantId'] as String? ?? 'plant-1',
      transactionType: map['transactionType'] as String? ?? '',
      rollId: map['rollId'] as String? ?? '',
      rollCode: map['rollCode'] as String? ?? '',
      rmtQuantity: (map['rmtQuantity'] as num?)?.toDouble() ?? 0.0,
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.now(),
      performedBy: map['performedBy'] as String? ?? 'system',
      jobCardId: map['jobCardId'] as String?,
      jobCardNo: map['jobCardNo'] as String?,
      remarks: map['remarks'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plantId': plantId,
      'transactionType': transactionType,
      'rollId': rollId,
      'rollCode': rollCode,
      'rmtQuantity': rmtQuantity,
      'timestamp': timestamp.toIso8601String(),
      'performedBy': performedBy,
      'jobCardId': jobCardId,
      'jobCardNo': jobCardNo,
      'remarks': remarks,
    };
  }
}

class MaterialTransactionType {
  static const String purchaseReceipt = 'PurchaseReceipt';
  static const String issueToJob = 'IssueToJob';
  static const String leftoverReturn = 'LeftoverReturn';
  static const String productionConsumption = 'ProductionConsumption';
  static const String adjustment = 'Adjustment';
}
