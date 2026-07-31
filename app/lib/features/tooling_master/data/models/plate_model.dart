import 'package:flutter/foundation.dart';

/// Plate Management Data Model.
///
/// Implements Section 8 (item 5) of Doc/Flexora-Master-Requirements-v1.2.md:
/// Track plates against Customer / Product SKU / Artwork Version.
@immutable
class PlateModel {
  final String id;
  final String plantId;

  final String plateCode;
  final String customerId;
  final String customerName;
  final String productId;
  final String internalSkuCode;
  final String productName;
  final String artworkVersionId;
  final String artworkVersionLabel;

  final int colorCount;
  final String colorDetails;
  final double polymerThicknessMm; // e.g. 1.14mm, 1.70mm
  final double cylinderRepeatMm;

  final String storageRackBin;
  final String condition; // New, Good, Worn, Damaged, Scrapped
  final int totalImpressionsRun;

  final String status; // Available, InUse, Maintenance, Retired

  final DateTime createdAt;
  final String createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;

  const PlateModel({
    required this.id,
    required this.plantId,
    required this.plateCode,
    required this.customerId,
    required this.customerName,
    required this.productId,
    required this.internalSkuCode,
    required this.productName,
    required this.artworkVersionId,
    required this.artworkVersionLabel,
    required this.colorCount,
    required this.createdAt,
    required this.createdBy,
    this.colorDetails = '',
    this.polymerThicknessMm = 1.14,
    this.cylinderRepeatMm = 300.0,
    this.storageRackBin = 'Rack A-1',
    this.condition = PlateCondition.good,
    this.totalImpressionsRun = 0,
    this.status = PlateStatus.available,
    this.updatedAt,
    this.updatedBy,
  });

  factory PlateModel.fromMap(String id, Map<String, dynamic> map) {
    return PlateModel(
      id: id,
      plantId: map['plantId'] as String? ?? 'plant-1',
      plateCode: map['plateCode'] as String? ?? '',
      customerId: map['customerId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      productId: map['productId'] as String? ?? '',
      internalSkuCode: map['internalSkuCode'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      artworkVersionId: map['artworkVersionId'] as String? ?? '',
      artworkVersionLabel: map['artworkVersionLabel'] as String? ?? 'v1',
      colorCount: map['colorCount'] as int? ?? 1,
      colorDetails: map['colorDetails'] as String? ?? '',
      polymerThicknessMm: (map['polymerThicknessMm'] as num?)?.toDouble() ?? 1.14,
      cylinderRepeatMm: (map['cylinderRepeatMm'] as num?)?.toDouble() ?? 300.0,
      storageRackBin: map['storageRackBin'] as String? ?? '',
      condition: map['condition'] as String? ?? PlateCondition.good,
      totalImpressionsRun: map['totalImpressionsRun'] as int? ?? 0,
      status: map['status'] as String? ?? PlateStatus.available,
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
      'plateCode': plateCode,
      'customerId': customerId,
      'customerName': customerName,
      'productId': productId,
      'internalSkuCode': internalSkuCode,
      'productName': productName,
      'artworkVersionId': artworkVersionId,
      'artworkVersionLabel': artworkVersionLabel,
      'colorCount': colorCount,
      'colorDetails': colorDetails,
      'polymerThicknessMm': polymerThicknessMm,
      'cylinderRepeatMm': cylinderRepeatMm,
      'storageRackBin': storageRackBin,
      'condition': condition,
      'totalImpressionsRun': totalImpressionsRun,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedAt': updatedAt?.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }
}

class PlateCondition {
  static const String brandNew = 'New';
  static const String good = 'Good';
  static const String worn = 'Worn';
  static const String damaged = 'Damaged';
  static const String scrapped = 'Scrapped';

  static const List<String> values = [brandNew, good, worn, damaged, scrapped];
}

class PlateStatus {
  static const String available = 'Available';
  static const String inUse = 'InUse';
  static const String maintenance = 'Maintenance';
  static const String retired = 'Retired';

  static const List<String> values = [available, inUse, maintenance, retired];
}
