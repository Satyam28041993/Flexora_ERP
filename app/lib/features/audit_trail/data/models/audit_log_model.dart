import 'package:flutter/foundation.dart';

/// Immutable System-Wide Audit Log Entry Model.
///
/// Implements Section 0A & Golden Rule 7 of Doc/Flexora-Master-Requirements-v1.2.md:
/// Every critical change, approval, status change, or transaction is logged as an immutable audit entry.
@immutable
class AuditLogModel {
  final String id;
  final String plantId;

  final String module; // Orders, Customers, Products, JobCards, Tooling, Production, Stores, QC, Dispatch
  final String action; // Created, Updated, Approved, StatusChange, Issued, Returned
  final String entityId;
  final String entityCode;

  final String performedBy;
  final DateTime timestamp;
  final String details;

  const AuditLogModel({
    required this.id,
    required this.plantId,
    required this.module,
    required this.action,
    required this.entityId,
    required this.entityCode,
    required this.performedBy,
    required this.timestamp,
    required this.details,
  });

  factory AuditLogModel.fromMap(String id, Map<String, dynamic> map) {
    return AuditLogModel(
      id: id,
      plantId: map['plantId'] as String? ?? 'plant-1',
      module: map['module'] as String? ?? '',
      action: map['action'] as String? ?? '',
      entityId: map['entityId'] as String? ?? '',
      entityCode: map['entityCode'] as String? ?? '',
      performedBy: map['performedBy'] as String? ?? 'system',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.now(),
      details: map['details'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plantId': plantId,
      'module': module,
      'action': action,
      'entityId': entityId,
      'entityCode': entityCode,
      'performedBy': performedBy,
      'timestamp': timestamp.toIso8601String(),
      'details': details,
    };
  }
}
