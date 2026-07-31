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
  final String dieType; // Flexible Magnetic Die, Solid Cylinder Die
  final String shape; // Rectangle, Circle, Oval, Custom

  final double labelWidthMm;
  final double labelHeightMm;
  final double cornerRadiusMm;

  final double cylinderRepeatMm;
  final int gearTeethCount; // Z count (e.g. Z-96)
  final int acrossUps;
  final int aroundUps;

  final String storageRackBin;
  final String condition; // New, Good, Worn, Damaged, Scrapped
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
    required this.acrossUps,
    required this.aroundUps,
    required this.createdAt,
    required this.createdBy,
    this.dieType = 'Flexible Magnetic Die',
    this.shape = 'Rectangle',
    this.cornerRadiusMm = 2.0,
    this.cylinderRepeatMm = 300.0,
    this.gearTeethCount = 96,
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
      labelWidthMm: (map['labelWidthMm'] as num?)?.toDouble() ?? 0.0,
      labelHeightMm: (map['labelHeightMm'] as num?)?.toDouble() ?? 0.0,
      cornerRadiusMm: (map['cornerRadiusMm'] as num?)?.toDouble() ?? 2.0,
      cylinderRepeatMm: (map['cylinderRepeatMm'] as num?)?.toDouble() ?? 300.0,
      gearTeethCount: map['gearTeethCount'] as int? ?? 96,
      acrossUps: map['acrossUps'] as int? ?? 1,
      aroundUps: map['aroundUps'] as int? ?? 1,
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
      'labelWidthMm': labelWidthMm,
      'labelHeightMm': labelHeightMm,
      'cornerRadiusMm': cornerRadiusMm,
      'cylinderRepeatMm': cylinderRepeatMm,
      'gearTeethCount': gearTeethCount,
      'acrossUps': acrossUps,
      'aroundUps': aroundUps,
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

  int get totalUps => acrossUps * aroundUps;
  String get specLabel => '${labelWidthMm.toStringAsFixed(1)}×${labelHeightMm.toStringAsFixed(1)} mm ($acrossUps×$aroundUps UPS)';
}

class DieCondition {
  static const String brandNew = 'New';
  static const String good = 'Good';
  static const String worn = 'Worn';
  static const String damaged = 'Damaged';
  static const String scrapped = 'Scrapped';

  static const List<String> values = [brandNew, good, worn, damaged, scrapped];
}

class DieStatus {
  static const String available = 'Available';
  static const String inUse = 'InUse';
  static const String maintenance = 'Maintenance';
  static const String scrapped = 'Scrapped';

  static const List<String> values = [available, inUse, maintenance, scrapped];
}
