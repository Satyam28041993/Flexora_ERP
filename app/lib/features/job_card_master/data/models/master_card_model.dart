import 'package:flutter/foundation.dart';

/// Master Card Data Model.
///
/// Implements Section 4 & Section 8 (item 3) of Doc/Flexora-Master-Requirements-v1.2.md:
/// Created before printing as part of Pre-Press verification package
/// (Master Card + Job Card + Plate + Punch/Die).
@immutable
class MasterCardModel {
  final String id;
  final String plantId;

  final String masterCardNo; // e.g. MC-2026-001
  final String jobCardId;
  final String jobCardNo;

  final String customerName;
  final String internalSkuCode;
  final String productName;

  // Pre-Press Sign-off & Handover verification
  final bool artworkVerified;
  final bool plateVerified;
  final bool dieVerified;
  final bool shadeReferenceVerified;

  final String verifiedBy;
  final DateTime verificationDate;

  final String colorSequenceNotes;
  final String machineTargetSpeed;
  final String specialHandoverInstructions;

  final DateTime createdAt;
  final String createdBy;

  const MasterCardModel({
    required this.id,
    required this.plantId,
    required this.masterCardNo,
    required this.jobCardId,
    required this.jobCardNo,
    required this.customerName,
    required this.internalSkuCode,
    required this.productName,
    required this.verifiedBy,
    required this.verificationDate,
    required this.createdAt,
    required this.createdBy,
    this.artworkVerified = true,
    this.plateVerified = true,
    this.dieVerified = true,
    this.shadeReferenceVerified = true,
    this.colorSequenceNotes = '',
    this.machineTargetSpeed = '40 m/min',
    this.specialHandoverInstructions = '',
  });

  factory MasterCardModel.fromMap(String id, Map<String, dynamic> map) {
    return MasterCardModel(
      id: id,
      plantId: map['plantId'] as String? ?? 'plant-1',
      masterCardNo: map['masterCardNo'] as String? ?? '',
      jobCardId: map['jobCardId'] as String? ?? '',
      jobCardNo: map['jobCardNo'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      internalSkuCode: map['internalSkuCode'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      verifiedBy: map['verifiedBy'] as String? ?? '',
      verificationDate: map['verificationDate'] != null
          ? DateTime.parse(map['verificationDate'] as String)
          : DateTime.now(),
      artworkVerified: map['artworkVerified'] as bool? ?? true,
      plateVerified: map['plateVerified'] as bool? ?? true,
      dieVerified: map['dieVerified'] as bool? ?? true,
      shadeReferenceVerified: map['shadeReferenceVerified'] as bool? ?? true,
      colorSequenceNotes: map['colorSequenceNotes'] as String? ?? '',
      machineTargetSpeed: map['machineTargetSpeed'] as String? ?? '',
      specialHandoverInstructions: map['specialHandoverInstructions'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      createdBy: map['createdBy'] as String? ?? 'system',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plantId': plantId,
      'masterCardNo': masterCardNo,
      'jobCardId': jobCardId,
      'jobCardNo': jobCardNo,
      'customerName': customerName,
      'internalSkuCode': internalSkuCode,
      'productName': productName,
      'verifiedBy': verifiedBy,
      'verificationDate': verificationDate.toIso8601String(),
      'artworkVerified': artworkVerified,
      'plateVerified': plateVerified,
      'dieVerified': dieVerified,
      'shadeReferenceVerified': shadeReferenceVerified,
      'colorSequenceNotes': colorSequenceNotes,
      'machineTargetSpeed': machineTargetSpeed,
      'specialHandoverInstructions': specialHandoverInstructions,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }
}
