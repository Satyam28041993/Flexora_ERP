import 'package:flutter/foundation.dart';

/// Production Operator Log Data Model.
@immutable
class ProductionLogModel {
  final String id;
  final String plantId;

  final String scheduleId;
  final String jobCardId;
  final String jobCardNo;
  final String machineId;
  final String machineName;

  final String shift; // Day, Night
  final String operatorName;
  final double averageSpeedMpm;

  final DateTime runStartTime;
  final DateTime runEndTime;

  final double totalRmtPrinted;
  final double totalLabelsProduced;

  final int setupTimeMinutes;
  final double setupWasteRmt;
  final double runningWasteRmt;

  final int downtimeMinutes;
  final String? downtimeReason; // Mechanical Break, Ink Change, Web Break, Material Delay
  final String? rejectionRemarks;

  final DateTime createdAt;
  final String createdBy;

  const ProductionLogModel({
    required this.id,
    required this.plantId,
    required this.scheduleId,
    required this.jobCardId,
    required this.jobCardNo,
    required this.machineId,
    required this.machineName,
    required this.shift,
    required this.operatorName,
    required this.averageSpeedMpm,
    required this.runStartTime,
    required this.runEndTime,
    required this.totalRmtPrinted,
    required this.totalLabelsProduced,
    required this.setupTimeMinutes,
    required this.setupWasteRmt,
    required this.runningWasteRmt,
    required this.downtimeMinutes,
    required this.createdAt,
    required this.createdBy,
    this.downtimeReason,
    this.rejectionRemarks,
  });

  factory ProductionLogModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductionLogModel(
      id: id,
      plantId: map['plantId'] as String? ?? 'plant-1',
      scheduleId: map['scheduleId'] as String? ?? '',
      jobCardId: map['jobCardId'] as String? ?? '',
      jobCardNo: map['jobCardNo'] as String? ?? '',
      machineId: map['machineId'] as String? ?? '',
      machineName: map['machineName'] as String? ?? '',
      shift: map['shift'] as String? ?? 'Day',
      operatorName: map['operatorName'] as String? ?? '',
      averageSpeedMpm: (map['averageSpeedMpm'] as num?)?.toDouble() ?? 0.0,
      runStartTime: map['runStartTime'] != null
          ? DateTime.parse(map['runStartTime'] as String)
          : DateTime.now(),
      runEndTime: map['runEndTime'] != null
          ? DateTime.parse(map['runEndTime'] as String)
          : DateTime.now(),
      totalRmtPrinted: (map['totalRmtPrinted'] as num?)?.toDouble() ?? 0.0,
      totalLabelsProduced: (map['totalLabelsProduced'] as num?)?.toDouble() ?? 0.0,
      setupTimeMinutes: map['setupTimeMinutes'] as int? ?? 0,
      setupWasteRmt: (map['setupWasteRmt'] as num?)?.toDouble() ?? 0.0,
      runningWasteRmt: (map['runningWasteRmt'] as num?)?.toDouble() ?? 0.0,
      downtimeMinutes: map['downtimeMinutes'] as int? ?? 0,
      downtimeReason: map['downtimeReason'] as String?,
      rejectionRemarks: map['rejectionRemarks'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      createdBy: map['createdBy'] as String? ?? 'system',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plantId': plantId,
      'scheduleId': scheduleId,
      'jobCardId': jobCardId,
      'jobCardNo': jobCardNo,
      'machineId': machineId,
      'machineName': machineName,
      'shift': shift,
      'operatorName': operatorName,
      'averageSpeedMpm': averageSpeedMpm,
      'runStartTime': runStartTime.toIso8601String(),
      'runEndTime': runEndTime.toIso8601String(),
      'totalRmtPrinted': totalRmtPrinted,
      'totalLabelsProduced': totalLabelsProduced,
      'setupTimeMinutes': setupTimeMinutes,
      'setupWasteRmt': setupWasteRmt,
      'runningWasteRmt': runningWasteRmt,
      'downtimeMinutes': downtimeMinutes,
      'downtimeReason': downtimeReason,
      'rejectionRemarks': rejectionRemarks,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  double get totalWasteRmt => setupWasteRmt + runningWasteRmt;
}
