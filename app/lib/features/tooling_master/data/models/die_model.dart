import 'package:flutter/foundation.dart';

/// Punch / Die Management Data Model.
///
/// Implements Section 8 (item 6) of Doc/Flexora-Master-Requirements-v1.2.md:
/// Master registry & linkage of dies/punches to products & jobs.
@immutable
class DieModel {
  final String id;
  final String plantId;

  final String dieCode; // e.g. DIE-40x60-2AC
  final String dieType; // Flexible Magnetic Die, Solid Cylinder Die, Offline Die (Punch)
  final String shape; // Rectangle, Circle, Oval, Custom

  final String customerId;
  final String customerName;
  final String productId;
  final String internalSkuCode;
  final String productName;

  final double labelWidthMm;
  final double labelHeightMm;
  final double cornerRadiusMm;

  final double cylinderRepeatMm;
  final int gearTeethCount; // Z count (e.g. Z-96)
  final int webUps;
  final int repeatUps;

  int get acrossUps => webUps;
  int get aroundUps => repeatUps;

  final String revisionTag; // e.g. Rev 1, Rev 2 (Remade)
  final String remadeNotes; // e.g. Sharpened, Shape Correction

  final String storageRackBin;
  final String condition; // New, Good, Worn, Damaged, Scrapped, Remade
  final int totalHitsRun;

  final String status; // Available, InUse, Maintenance, Scrapped

  final DateTime createdAt;
  final String createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;

  const DieModel({
    required this.id,
    required this.plantId,
    required this.dieCode,
    required this.labelWidthMm,
    required this.labelHeightMm,
    required this.webUps,
    required this.repeatUps,
    required this.createdAt,
    required this.createdBy,
    this.customerId = '',
    this.customerName = '',
    this.productId = '',
    this.internalSkuCode = '',
    this.productName = '',
    this.dieType = 'Flexible Magnetic Die',
    this.shape = 'Rectangle',
    this.cornerRadiusMm = 2.0,
    this.cylinderRepeatMm = 300.0,
    this.gearTeethCount = 96,
    this.revisionTag = 'Rev 1',
    this.remadeNotes = '',
    this.storageRackBin = 'Rack D-1',
    this.condition = DieCondition.good,
    this.totalHitsRun = 0,
    this.status = DieStatus.available,
    this.updatedAt,
    this.updatedBy,
  });

  factory DieModel.fromMap(String id, Map<String, dynamic> map) {
    return DieModel(
      id: id,
      plantId: map['plantId'] as String? ?? 'plant-1',
      dieCode: map['dieCode'] as String? ?? '',
      dieType: map['dieType'] as String? ?? 'Flexible Magnetic Die',
      shape: map['shape'] as String? ?? 'Rectangle',
      customerId: map['customerId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      productId: map['productId'] as String? ?? '',
      internalSkuCode: map['internalSkuCode'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      labelWidthMm: (map['labelWidthMm'] as num?)?.toDouble() ?? 0.0,
      labelHeightMm: (map['labelHeightMm'] as num?)?.toDouble() ?? 0.0,
      cornerRadiusMm: (map['cornerRadiusMm'] as num?)?.toDouble() ?? 2.0,
      cylinderRepeatMm: (map['cylinderRepeatMm'] as num?)?.toDouble() ?? 300.0,
      gearTeethCount: map['gearTeethCount'] as int? ?? 96,
      webUps: map['webUps'] as int? ?? (map['acrossUps'] as int? ?? 1),
      repeatUps: map['repeatUps'] as int? ?? (map['aroundUps'] as int? ?? 1),
      revisionTag: map['revisionTag'] as String? ?? 'Rev 1',
      remadeNotes: map['remadeNotes'] as String? ?? '',
      storageRackBin: map['storageRackBin'] as String? ?? '',
      condition: map['condition'] as String? ?? DieCondition.good,
      totalHitsRun: map['totalHitsRun'] as int? ?? 0,
      status: map['status'] as String? ?? DieStatus.available,
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
      'dieCode': dieCode,
      'dieType': dieType,
      'shape': shape,
      'customerId': customerId,
      'customerName': customerName,
      'productId': productId,
      'internalSkuCode': internalSkuCode,
      'productName': productName,
      'labelWidthMm': labelWidthMm,
      'labelHeightMm': labelHeightMm,
      'cornerRadiusMm': cornerRadiusMm,
      'cylinderRepeatMm': cylinderRepeatMm,
      'gearTeethCount': gearTeethCount,
      'webUps': webUps,
      'repeatUps': repeatUps,
      'acrossUps': webUps,
      'aroundUps': repeatUps,
      'revisionTag': revisionTag,
      'remadeNotes': remadeNotes,
      'storageRackBin': storageRackBin,
      'condition': condition,
      'totalHitsRun': totalHitsRun,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedAt': updatedAt?.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }

  int get totalUps => webUps * repeatUps;
  String get specLabel => '${labelWidthMm.toStringAsFixed(1)}×${labelHeightMm.toStringAsFixed(1)} mm ($webUps Web Up × $repeatUps Repeat Up)';
}

class DieTypeOptions {
  static const String flexibleMagnetic = 'Flexible Magnetic Die';
  static const String solidCylinder = 'Solid Cylinder Die';
  static const String offlineDiePunch = 'Offline Die (Punch)';

  static const List<String> values = [flexibleMagnetic, solidCylinder, offlineDiePunch];
}

class DieCondition {
  static const String brandNew = 'New';
  static const String good = 'Good';
  static const String remade = 'Remade / Revised';
  static const String worn = 'Worn';
  static const String damaged = 'Damaged';
  static const String scrapped = 'Scrapped';

  static const List<String> values = [brandNew, good, remade, worn, damaged, scrapped];
}

class DieStatus {
  static const String available = 'Available';
  static const String inUse = 'InUse';
  static const String maintenance = 'Maintenance';
  static const String scrapped = 'Scrapped';

  static const List<String> values = [available, inUse, maintenance, scrapped];
}
