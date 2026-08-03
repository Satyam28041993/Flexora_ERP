import 'package:flutter/foundation.dart';

/// Production Job Sub-Statuses for Pending Stage.
class PendingSubStatus {
  static const String newPending = 'New Pending';
  static const String underApproval = 'Under Approval';
  static const String approvalReceived = 'Approval Recd';
  static const String underPlate = 'Under Plate';
  static const String holdJob = 'Hold Job';

  static const List<String> values = [
    newPending,
    underApproval,
    approvalReceived,
    underPlate,
    holdJob,
  ];
}

/// Main Production Stage Lifecycle.
class ProductionStage {
  static const String pending = 'Pending';
  static const String schedule = 'Schedule';
  static const String postpress = 'Postpress';
  static const String dispatched = 'Dispatched';
  static const String fgStock = 'FG Stock';

  static const List<String> values = [
    pending,
    schedule,
    postpress,
    dispatched,
    fgStock,
  ];
}

/// Production Job Master Data Model.
///
/// Implements full 30+ columns and exact formulas from:
/// `New Order Detail and Status Tracking 2026-2027.xlsx`
@immutable
class ProductionJobModel {
  final String id;
  final String plantId;

  // Header & Order Details
  final String jobDocNo; // e.g. 06/021, 07/048
  final String clientName;
  final DateTime orderDate;
  final String poNumber;
  final DateTime? poDate;
  final double pendingPoQty;
  final DateTime? approvalDate;
  final DateTime? approvedDate;
  final String materialDescription; // Product Name / SKU Description
  final String plantLocation; // e.g. DAMAN, AKOLA, GOVANDI

  // Specifications
  final double totalReqQty;
  final int gearTeethCount; // Gear Z (e.g. 75, 81, 108)
  final int ups; // Across / Around total UPS
  final double paperSizeMm; // Web width in mm
  final String substrateMaterial; // e.g. PP WHITE, CHROMO, PVC CAST FILM
  final String labelSize; // e.g. 110 X 80

  // Pre-press & Purchase Tracking Statuses
  final String pendingSubStatus; // New Pending, Under Approval, Approval Recd, Under Plate, Hold Job
  final String paperStatus; // Available, Ordered, Pending
  final String fromOrder;
  final String stockRm;
  final String remarkFromPurchase;
  final String lamination; // e.g. YES, Gloss, Mat, None
  final String foil; // e.g. Gold Foil 40mm, Silver Foil, None
  final String plateStatus; // Ready, Under Plate, Pending
  final String punchStatus; // Ready, Under Punch, Pending
  final String remark;

  final double wastageRmt; // Default 300.0 RMT

  // Lifecycle Stage
  final String currentStage; // Pending, Schedule, Postpress, Dispatched, FG Stock

  // Postpress & Dispatch Specific Fields
  final double dispatchQty;
  final double balanceQty;
  final DateTime? dispatchDate;
  final String deliveryBy; // Transporter / Delivery Person
  final double shortQty;
  final double boxQty;
  final String billNo;

  final DateTime createdAt;
  final String createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;

  const ProductionJobModel({
    required this.id,
    required this.plantId,
    required this.jobDocNo,
    required this.clientName,
    required this.orderDate,
    required this.materialDescription,
    required this.totalReqQty,
    required this.gearTeethCount,
    required this.ups,
    required this.paperSizeMm,
    required this.substrateMaterial,
    required this.labelSize,
    required this.createdAt,
    required this.createdBy,
    this.wastageRmt = 300.0,
    this.poNumber = '',
    this.poDate,
    this.pendingPoQty = 0.0,
    this.approvalDate,
    this.approvedDate,
    this.plantLocation = 'MAIN',
    this.pendingSubStatus = PendingSubStatus.newPending,
    this.paperStatus = 'Available',
    this.fromOrder = '',
    this.stockRm = '',
    this.remarkFromPurchase = '',
    this.lamination = 'No',
    this.foil = 'No',
    this.plateStatus = 'Pending',
    this.punchStatus = 'Pending',
    this.remark = '',
    this.currentStage = ProductionStage.pending,
    this.dispatchQty = 0.0,
    this.balanceQty = 0.0,
    this.dispatchDate,
    this.deliveryBy = '',
    this.shortQty = 0.0,
    this.boxQty = 0.0,
    this.billNo = '',
    this.updatedAt,
    this.updatedBy,
  });

  /// Mathematical Formula 1: Repeat in Inches = Gear Teeth Z / 8
  double get repeatInches => gearTeethCount > 0 ? gearTeethCount / 8.0 : 0.0;

  /// Mathematical Formula 2: Labels Per Meter (L.P. Meter) = (39.3 * Ups) / RepeatInches
  double get lpMeter {
    if (gearTeethCount <= 0 || ups <= 0) return 0.0;
    return (39.3 * 8.0 * ups) / gearTeethCount;
  }

  /// Mathematical Formula 3: Required RMT = Total Req Qty / L.P. Meter
  double get reqRmt {
    final lp = lpMeter;
    if (lp <= 0) return 0.0;
    return totalReqQty / lp;
  }

  /// Mathematical Formula 4: Total RMT with Wastage = Req RMT + Wastage RMT
  double get totalRmtWithWastage => reqRmt + wastageRmt;

  factory ProductionJobModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductionJobModel(
      id: id,
      plantId: map['plantId'] as String? ?? 'plant-1',
      jobDocNo: map['jobDocNo'] as String? ?? '',
      clientName: map['clientName'] as String? ?? '',
      orderDate: map['orderDate'] != null ? DateTime.parse(map['orderDate'] as String) : DateTime.now(),
      poNumber: map['poNumber'] as String? ?? '',
      poDate: map['poDate'] != null ? DateTime.parse(map['poDate'] as String) : null,
      pendingPoQty: (map['pendingPoQty'] as num?)?.toDouble() ?? 0.0,
      approvalDate: map['approvalDate'] != null ? DateTime.parse(map['approvalDate'] as String) : null,
      approvedDate: map['approvedDate'] != null ? DateTime.parse(map['approvedDate'] as String) : null,
      materialDescription: map['materialDescription'] as String? ?? '',
      plantLocation: map['plantLocation'] as String? ?? 'MAIN',
      totalReqQty: (map['totalReqQty'] as num?)?.toDouble() ?? 0.0,
      gearTeethCount: map['gearTeethCount'] as int? ?? 96,
      ups: map['ups'] as int? ?? 1,
      paperSizeMm: (map['paperSizeMm'] as num?)?.toDouble() ?? 100.0,
      substrateMaterial: map['substrateMaterial'] as String? ?? 'CHROMO',
      labelSize: map['labelSize'] as String? ?? '',
      wastageRmt: (map['wastageRmt'] as num?)?.toDouble() ?? 300.0,
      pendingSubStatus: map['pendingSubStatus'] as String? ?? PendingSubStatus.newPending,
      paperStatus: map['paperStatus'] as String? ?? 'Available',
      fromOrder: map['fromOrder'] as String? ?? '',
      stockRm: map['stockRm'] as String? ?? '',
      remarkFromPurchase: map['remarkFromPurchase'] as String? ?? '',
      lamination: map['lamination'] as String? ?? 'No',
      foil: map['foil'] as String? ?? 'No',
      plateStatus: map['plateStatus'] as String? ?? 'Pending',
      punchStatus: map['punchStatus'] as String? ?? 'Pending',
      remark: map['remark'] as String? ?? '',
      currentStage: map['currentStage'] as String? ?? ProductionStage.pending,
      dispatchQty: (map['dispatchQty'] as num?)?.toDouble() ?? 0.0,
      balanceQty: (map['balanceQty'] as num?)?.toDouble() ?? 0.0,
      dispatchDate: map['dispatchDate'] != null ? DateTime.parse(map['dispatchDate'] as String) : null,
      deliveryBy: map['deliveryBy'] as String? ?? '',
      shortQty: (map['shortQty'] as num?)?.toDouble() ?? 0.0,
      boxQty: (map['boxQty'] as num?)?.toDouble() ?? 0.0,
      billNo: map['billNo'] as String? ?? '',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : DateTime.now(),
      createdBy: map['createdBy'] as String? ?? 'system',
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt'] as String) : null,
      updatedBy: map['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plantId': plantId,
      'jobDocNo': jobDocNo,
      'clientName': clientName,
      'orderDate': orderDate.toIso8601String(),
      'poNumber': poNumber,
      'poDate': poDate?.toIso8601String(),
      'pendingPoQty': pendingPoQty,
      'approvalDate': approvalDate?.toIso8601String(),
      'approvedDate': approvedDate?.toIso8601String(),
      'materialDescription': materialDescription,
      'plantLocation': plantLocation,
      'totalReqQty': totalReqQty,
      'gearTeethCount': gearTeethCount,
      'ups': ups,
      'paperSizeMm': paperSizeMm,
      'substrateMaterial': substrateMaterial,
      'labelSize': labelSize,
      'wastageRmt': wastageRmt,
      'pendingSubStatus': pendingSubStatus,
      'paperStatus': paperStatus,
      'fromOrder': fromOrder,
      'stockRm': stockRm,
      'remarkFromPurchase': remarkFromPurchase,
      'lamination': lamination,
      'foil': foil,
      'plateStatus': plateStatus,
      'punchStatus': punchStatus,
      'remark': remark,
      'currentStage': currentStage,
      'dispatchQty': dispatchQty,
      'balanceQty': balanceQty,
      'dispatchDate': dispatchDate?.toIso8601String(),
      'deliveryBy': deliveryBy,
      'shortQty': shortQty,
      'boxQty': boxQty,
      'billNo': billNo,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedAt': updatedAt?.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }
}
