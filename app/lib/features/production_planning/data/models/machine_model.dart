import 'package:flutter/foundation.dart';

/// Machine Master Data Model.
@immutable
class MachineModel {
  final String id;
  final String plantId;

  final String machineCode; // e.g. LOMBARDY-01
  final String machineName; // Lombardy 8-colour Flexo Press (~430mm max web width)
  final String category; // Printing Press, Slitter, Offline Punch, Hot Foil, Lamination

  final double maxWebWidthMm;
  final double maxSpeedMetersPerMin;
  final int colorStations;

  final String status; // Active, Maintenance, Offline

  const MachineModel({
    required this.id,
    required this.plantId,
    required this.machineCode,
    required this.machineName,
    required this.category,
    this.maxWebWidthMm = 430.0,
    this.maxSpeedMetersPerMin = 150.0,
    this.colorStations = 8,
    this.status = 'Active',
  });

  factory MachineModel.fromMap(String id, Map<String, dynamic> map) {
    return MachineModel(
      id: id,
      plantId: map['plantId'] as String? ?? 'plant-1',
      machineCode: map['machineCode'] as String? ?? '',
      machineName: map['machineName'] as String? ?? '',
      category: map['category'] as String? ?? 'Printing Press',
      maxWebWidthMm: (map['maxWebWidthMm'] as num?)?.toDouble() ?? 430.0,
      maxSpeedMetersPerMin: (map['maxSpeedMetersPerMin'] as num?)?.toDouble() ?? 150.0,
      colorStations: map['colorStations'] as int? ?? 8,
      status: map['status'] as String? ?? 'Active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plantId': plantId,
      'machineCode': machineCode,
      'machineName': machineName,
      'category': category,
      'maxWebWidthMm': maxWebWidthMm,
      'maxSpeedMetersPerMin': maxSpeedMetersPerMin,
      'colorStations': colorStations,
      'status': status,
    };
  }
}
