import 'package:flutter/foundation.dart';

/// Roll-Level Material Inventory Model.
///
/// Implements Section 6.8 of Doc/Flexora-Master-Requirements-v1.2.md:
/// Individual rolls are traceable by Material, Width, Original RMT, Available RMT,
/// Vendor, Receipt info, Batch/Lot, and Status. Partial-return RMT becomes available stock again.
@immutable
class RollModel {
  final String id;
  final String plantId;

  final String rollCode; // e.g. ROLL-CHR-220-001
  final String substrateMaterial; // Self-adhesive Chromo, PE, PP, PET, Thermal
  final double widthMm;

  final double originalRmt;
  final double availableRmt;

  final String vendorName;
  final String vendorBatchLot;
  final DateTime receiptDate;

  final String storageLocation; // Rack / Aisle / Bin
  final String qcStatus; // Approved, Quarantine, Rejected
  final String status; // Available, Issued, Depleted

  final DateTime createdAt;
  final String createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;

  const RollModel({
    required this.id,
    required this.plantId,
    required this.rollCode,
    required this.substrateMaterial,
    required this.widthMm,
    required this.originalRmt,
    required this.availableRmt,
    required this.vendorName,
    required this.vendorBatchLot,
    required this.receiptDate,
    required this.createdAt,
    required this.createdBy,
    this.storageLocation = 'Stores Rack R-1',
    this.qcStatus = 'Approved',
    this.status = RollStatus.available,
    this.updatedAt,
    this.updatedBy,
  });

  factory RollModel.fromMap(String id, Map<String, dynamic> map) {
    return RollModel(
      id: id,
      plantId: map['plantId'] as String? ?? 'plant-1',
      rollCode: map['rollCode'] as String? ?? '',
      substrateMaterial: map['substrateMaterial'] as String? ?? '',
      widthMm: (map['widthMm'] as num?)?.toDouble() ?? 0.0,
      originalRmt: (map['originalRmt'] as num?)?.toDouble() ?? 0.0,
      availableRmt: (map['availableRmt'] as num?)?.toDouble() ?? 0.0,
      vendorName: map['vendorName'] as String? ?? '',
      vendorBatchLot: map['vendorBatchLot'] as String? ?? '',
      receiptDate: map['receiptDate'] != null
          ? DateTime.parse(map['receiptDate'] as String)
          : DateTime.now(),
      storageLocation: map['storageLocation'] as String? ?? '',
      qcStatus: map['qcStatus'] as String? ?? 'Approved',
      status: map['status'] as String? ?? RollStatus.available,
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
      'rollCode': rollCode,
      'substrateMaterial': substrateMaterial,
      'widthMm': widthMm,
      'originalRmt': originalRmt,
      'availableRmt': availableRmt,
      'vendorName': vendorName,
      'vendorBatchLot': vendorBatchLot,
      'receiptDate': receiptDate.toIso8601String(),
      'storageLocation': storageLocation,
      'qcStatus': qcStatus,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedAt': updatedAt?.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }

  String get labelText => '$rollCode — $substrateMaterial (${widthMm.toInt()}mm, ${availableRmt.toInt()}/${originalRmt.toInt()} RMT)';
}

class RollStatus {
  static const String available = 'Available';
  static const String issued = 'Issued';
  static const String depleted = 'Depleted';

  static const List<String> values = [available, issued, depleted];
}
