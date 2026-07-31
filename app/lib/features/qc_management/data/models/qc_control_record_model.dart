import 'package:flutter/foundation.dart';

/// 3 QC Gates Data Model.
///
/// Implements Section 3 of Doc/Flexora-Master-Requirements-v1.2.md:
/// - Gate 1: Incoming Material Release (Material received from vendor -> Available for production)
/// - Gate 2: Production Start-Up Release (Setting done, sample approved -> Production run starts)
/// - Gate 3: Finished Goods Release (After checking & slitting -> Packing/Dispatch allowed)
@immutable
class QCControlRecordModel {
  final String id;
  final String plantId;

  final String gateType; // QC_Gate_1_Incoming, QC_Gate_2_StartUp, QC_Gate_3_Final
  final String recordCode; // e.g. QC1-2026-001, QC2-JC-101

  final String? jobCardId;
  final String? jobCardNo;
  final String? rollId;
  final String? rollCode;

  final String customerName;
  final String productName;

  final DateTime inspectionDate;
  final String inspectorName;

  /// Inspection Checklist Items (e.g. {'Text Matter': true, 'Colour Match': true, 'Rub Test': true})
  final Map<String, bool> checklistResults;

  final String disposition; // Passed, Hold, Rework, Rejected
  final String? rejectionReason;
  final String? remarks;

  // ISO Document Control reference
  final String isoDocNo;
  final String isoRevisionNo;

  final DateTime createdAt;
  final String createdBy;

  const QCControlRecordModel({
    required this.id,
    required this.plantId,
    required this.gateType,
    required this.recordCode,
    required this.customerName,
    required this.productName,
    required this.inspectionDate,
    required this.inspectorName,
    required this.checklistResults,
    required this.disposition,
    required this.createdAt,
    required this.createdBy,
    this.jobCardId,
    this.jobCardNo,
    this.rollId,
    this.rollCode,
    this.rejectionReason,
    this.remarks,
    this.isoDocNo = 'PGPL/QC/F-01',
    this.isoRevisionNo = '01',
  });

  factory QCControlRecordModel.fromMap(String id, Map<String, dynamic> map) {
    return QCControlRecordModel(
      id: id,
      plantId: map['plantId'] as String? ?? 'plant-1',
      gateType: map['gateType'] as String? ?? QCGateType.gate1Incoming,
      recordCode: map['recordCode'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      inspectionDate: map['inspectionDate'] != null
          ? DateTime.parse(map['inspectionDate'] as String)
          : DateTime.now(),
      inspectorName: map['inspectorName'] as String? ?? '',
      checklistResults: (map['checklistResults'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as bool)) ??
          const {},
      disposition: map['disposition'] as String? ?? QCDisposition.passed,
      jobCardId: map['jobCardId'] as String?,
      jobCardNo: map['jobCardNo'] as String?,
      rollId: map['rollId'] as String?,
      rollCode: map['rollCode'] as String?,
      rejectionReason: map['rejectionReason'] as String?,
      remarks: map['remarks'] as String?,
      isoDocNo: map['isoDocNo'] as String? ?? 'PGPL/QC/F-01',
      isoRevisionNo: map['isoRevisionNo'] as String? ?? '01',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      createdBy: map['createdBy'] as String? ?? 'system',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plantId': plantId,
      'gateType': gateType,
      'recordCode': recordCode,
      'customerName': customerName,
      'productName': productName,
      'inspectionDate': inspectionDate.toIso8601String(),
      'inspectorName': inspectorName,
      'checklistResults': checklistResults,
      'disposition': disposition,
      'jobCardId': jobCardId,
      'jobCardNo': jobCardNo,
      'rollId': rollId,
      'rollCode': rollCode,
      'rejectionReason': rejectionReason,
      'remarks': remarks,
      'isoDocNo': isoDocNo,
      'isoRevisionNo': isoRevisionNo,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  String get gateTitle {
    switch (gateType) {
      case QCGateType.gate1Incoming:
        return 'QC Gate 1 — Incoming Material Release';
      case QCGateType.gate2StartUp:
        return 'QC Gate 2 — Production Release (Start-Up)';
      case QCGateType.gate3Final:
        return 'QC Gate 3 — Finished Goods Release (Final)';
      default:
        return 'QC Release Gate';
    }
  }
}

class QCGateType {
  static const String gate1Incoming = 'QC_Gate_1_Incoming';
  static const String gate2StartUp = 'QC_Gate_2_StartUp';
  static const String gate3Final = 'QC_Gate_3_Final';

  static const List<String> values = [gate1Incoming, gate2StartUp, gate3Final];
}

class QCDisposition {
  static const String passed = 'Passed';
  static const String hold = 'Hold';
  static const String rework = 'Rework';
  static const String rejected = 'Rejected';

  static const List<String> values = [passed, hold, rework, rejected];
}
