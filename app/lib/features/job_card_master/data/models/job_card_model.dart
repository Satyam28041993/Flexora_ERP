import 'package:flutter/foundation.dart';

/// Job Card Data Model.
///
/// Implements Section 4 & Section 8 (item 4) of Doc/Flexora-Master-Requirements-v1.2.md:
/// PGPL Excel-exact Job Sheet model with auto-increment job sheet numbering.
@immutable
class JobCardModel {
  final String id;
  final String plantId;

  // Header Details
  final String jobCardNo; // e.g. 07/001 or 08/001 (Job Sheet No)
  final String dateStr; // e.g. 01-07-2026
  final String machineName; // e.g. LOMBARDI 430
  final String orderId;
  final String poNumber;
  final String poDateStr;

  // Customer & Product Info
  final String customerId;
  final String customerName;
  final String productId;
  final String internalSkuCode;
  final String productName; // Job Name
  final String jobCode; // e.g. 208280
  final String cqalNo;

  // Size & Layout Specs
  final String labelSize; // e.g. 280 X 143
  final double labelPerMtr; // e.g. 3.53
  final double stockLabelQty;
  final String artWorkNo;
  final String rollWindingDirection; // e.g. F1, F2, F3, F4, R1, R2, R3, R4
  final String gearSize; // e.g. 89

  // Printing & Tooling Specs
  final String numbering; // Yes/No
  final String punchOnline; // Yes/No
  final String punchType; // ONLINE/OFFLINE
  final String specialInfo; // Yes/No
  final String plateOldNew; // OLD/NEW
  final String reslamDelam; // Yes/No
  final String noOfColors; // e.g. CMYK
  final String materialAndCode; // e.g. AVERY
  final String asPerShadeCard; // Yes/No
  final String specialColors; // e.g. P 353 C / P 2727 C
  final String productMaterialType; // e.g. C-MIRRORCOAT

  // Finishing & Quantities
  final String uvGlossLamination; // e.g. VARNISH
  final String uvMat; // Yes/No
  final String textureVarnish; // Yes/No
  final double targetOrderQty; // Order Qty (e.g. 22900)
  final double plannedProductionQty; // Target + setup waste allowance
  final String screenDetails; // Yes/No
  final String stampingDetails; // Yes/No
  final double paperSize; // e.g. 160 mm
  final int ups; // e.g. 1
  final double rmt; // e.g. 6483
  final String remarks;

  // Core References
  final String plateId;
  final String plateCode;
  final String dieId;
  final String dieCode;

  /// Process Route for this specific Job Card
  final List<String> processRoute;
  final String status; // Draft, PrePressReady, Scheduled, InProduction, Completed, Cancelled

  final DateTime createdAt;
  final String createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;

  const JobCardModel({
    required this.id,
    required this.plantId,
    required this.jobCardNo,
    required this.orderId,
    required this.poNumber,
    required this.customerId,
    required this.customerName,
    required this.productId,
    required this.internalSkuCode,
    required this.productName,
    required this.targetOrderQty,
    required this.plannedProductionQty,
    required this.createdAt,
    required this.createdBy,
    this.dateStr = '',
    this.machineName = 'LOMBARDI 430',
    this.poDateStr = '',
    this.jobCode = '',
    this.cqalNo = '',
    this.labelSize = '',
    this.labelPerMtr = 1.0,
    this.stockLabelQty = 0.0,
    this.artWorkNo = '',
    this.rollWindingDirection = 'F4',
    this.gearSize = '',
    this.numbering = 'No',
    this.punchOnline = 'No',
    this.punchType = 'ONLINE',
    this.specialInfo = 'No',
    this.plateOldNew = 'NEW',
    this.reslamDelam = 'No',
    this.noOfColors = 'CMYK',
    this.materialAndCode = 'AVERY',
    this.asPerShadeCard = 'Yes',
    this.specialColors = '',
    this.productMaterialType = 'C-MIRRORCOAT',
    this.uvGlossLamination = 'VARNISH',
    this.uvMat = 'No',
    this.textureVarnish = 'No',
    this.screenDetails = 'No',
    this.stampingDetails = 'No',
    this.paperSize = 0.0,
    this.ups = 1,
    this.rmt = 0.0,
    this.remarks = '',
    this.deliveryDueDate,
    this.plannedProductionDate,
    this.plateId = '',
    this.plateCode = '',
    this.dieId = '',
    this.dieCode = '',
    this.processRoute = const ['Printing', 'Online Punching', 'Checking', 'Slitting', 'Packing'],
    this.status = JobCardStatus.draft,
    this.updatedAt,
    this.updatedBy,
  });

  final DateTime? deliveryDueDate;
  final DateTime? plannedProductionDate;

  factory JobCardModel.fromMap(String id, Map<String, dynamic> map) {
    return JobCardModel(
      id: id,
      plantId: map['plantId'] as String? ?? 'plant-1',
      jobCardNo: map['jobCardNo'] as String? ?? '',
      dateStr: map['dateStr'] as String? ?? '',
      machineName: map['machineName'] as String? ?? 'LOMBARDI 430',
      orderId: map['orderId'] as String? ?? '',
      poNumber: map['poNumber'] as String? ?? '',
      poDateStr: map['poDateStr'] as String? ?? '',
      customerId: map['customerId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      productId: map['productId'] as String? ?? '',
      internalSkuCode: map['internalSkuCode'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      jobCode: map['jobCode'] as String? ?? '',
      cqalNo: map['cqalNo'] as String? ?? '',
      labelSize: map['labelSize'] as String? ?? '',
      labelPerMtr: (map['labelPerMtr'] as num?)?.toDouble() ?? 1.0,
      stockLabelQty: (map['stockLabelQty'] as num?)?.toDouble() ?? 0.0,
      artWorkNo: map['artWorkNo'] as String? ?? '',
      rollWindingDirection: map['rollWindingDirection'] as String? ?? 'F4',
      gearSize: map['gearSize'] as String? ?? '',
      numbering: map['numbering'] as String? ?? 'No',
      punchOnline: map['punchOnline'] as String? ?? 'No',
      punchType: map['punchType'] as String? ?? 'ONLINE',
      specialInfo: map['specialInfo'] as String? ?? 'No',
      plateOldNew: map['plateOldNew'] as String? ?? 'NEW',
      reslamDelam: map['reslamDelam'] as String? ?? 'No',
      noOfColors: map['noOfColors'] as String? ?? 'CMYK',
      materialAndCode: map['materialAndCode'] as String? ?? 'AVERY',
      asPerShadeCard: map['asPerShadeCard'] as String? ?? 'Yes',
      specialColors: map['specialColors'] as String? ?? '',
      productMaterialType: map['productMaterialType'] as String? ?? 'C-MIRRORCOAT',
      uvGlossLamination: map['uvGlossLamination'] as String? ?? 'VARNISH',
      uvMat: map['uvMat'] as String? ?? 'No',
      textureVarnish: map['textureVarnish'] as String? ?? 'No',
      targetOrderQty: (map['targetOrderQty'] as num?)?.toDouble() ?? 0.0,
      plannedProductionQty: (map['plannedProductionQty'] as num?)?.toDouble() ?? 0.0,
      screenDetails: map['screenDetails'] as String? ?? 'No',
      stampingDetails: map['stampingDetails'] as String? ?? 'No',
      paperSize: (map['paperSize'] as num?)?.toDouble() ?? 0.0,
      ups: (map['ups'] as num?)?.toInt() ?? 1,
      rmt: (map['rmt'] as num?)?.toDouble() ?? 0.0,
      remarks: map['remarks'] as String? ?? '',
      deliveryDueDate: map['deliveryDueDate'] != null
          ? DateTime.parse(map['deliveryDueDate'] as String)
          : null,
      plannedProductionDate: map['plannedProductionDate'] != null
          ? DateTime.parse(map['plannedProductionDate'] as String)
          : null,
      plateId: map['plateId'] as String? ?? '',
      plateCode: map['plateCode'] as String? ?? '',
      dieId: map['dieId'] as String? ?? '',
      dieCode: map['dieCode'] as String? ?? '',
      processRoute: (map['processRoute'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['Printing', 'Online Punching', 'Checking', 'Slitting', 'Packing'],
      status: map['status'] as String? ?? JobCardStatus.draft,
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
      'jobCardNo': jobCardNo,
      'dateStr': dateStr,
      'machineName': machineName,
      'orderId': orderId,
      'poNumber': poNumber,
      'poDateStr': poDateStr,
      'customerId': customerId,
      'customerName': customerName,
      'productId': productId,
      'internalSkuCode': internalSkuCode,
      'productName': productName,
      'jobCode': jobCode,
      'cqalNo': cqalNo,
      'labelSize': labelSize,
      'labelPerMtr': labelPerMtr,
      'stockLabelQty': stockLabelQty,
      'artWorkNo': artWorkNo,
      'rollWindingDirection': rollWindingDirection,
      'gearSize': gearSize,
      'numbering': numbering,
      'punchOnline': punchOnline,
      'punchType': punchType,
      'specialInfo': specialInfo,
      'plateOldNew': plateOldNew,
      'reslamDelam': reslamDelam,
      'noOfColors': noOfColors,
      'materialAndCode': materialAndCode,
      'asPerShadeCard': asPerShadeCard,
      'specialColors': specialColors,
      'productMaterialType': productMaterialType,
      'uvGlossLamination': uvGlossLamination,
      'uvMat': uvMat,
      'textureVarnish': textureVarnish,
      'targetOrderQty': targetOrderQty,
      'plannedProductionQty': plannedProductionQty,
      'screenDetails': screenDetails,
      'stampingDetails': stampingDetails,
      'paperSize': paperSize,
      'ups': ups,
      'rmt': rmt,
      'remarks': remarks,
      'deliveryDueDate': deliveryDueDate?.toIso8601String(),
      'plannedProductionDate': plannedProductionDate?.toIso8601String(),
      'plateId': plateId,
      'plateCode': plateCode,
      'dieId': dieId,
      'dieCode': dieCode,
      'processRoute': processRoute,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedAt': updatedAt?.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }
}

class JobCardStatus {
  static const String draft = 'Draft';
  static const String prePressReady = 'PrePressReady';
  static const String scheduled = 'Scheduled';
  static const String inProduction = 'InProduction';
  static const String completed = 'Completed';
  static const String cancelled = 'Cancelled';

  static const List<String> values = [
    draft,
    prePressReady,
    scheduled,
    inProduction,
    completed,
    cancelled,
  ];
}

