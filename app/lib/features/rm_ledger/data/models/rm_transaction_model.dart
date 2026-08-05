import 'package:flutter/foundation.dart';

import '../../../../core/constants/production_formulas.dart';

/// Stock-In / Purchase Receipt Model
@immutable
class RmStockInModel {
  final String id;
  final String plantId;
  final DateTime date;
  final String supplier;
  final String material;
  final String productCode; // Vendor Product Code (e.g. FASSON FL201)
  final double gsmMicron;
  final double webSizeMm;
  final double rmtIn;
  final double ratePerSqMtr;
  final DateTime createdAt;
  final String createdBy;

  const RmStockInModel({
    required this.id,
    required this.plantId,
    required this.date,
    required this.supplier,
    required this.material,
    this.productCode = '',
    required this.gsmMicron,
    required this.webSizeMm,
    required this.rmtIn,
    required this.ratePerSqMtr,
    required this.createdAt,
    required this.createdBy,
  });

  double get sqMtrIn => (webSizeMm * rmtIn) / 1000.0;
  double get valueIn => sqMtrIn * ratePerSqMtr;

  factory RmStockInModel.fromMap(String id, Map<String, dynamic> map) {
    return RmStockInModel(
      id: id,
      plantId: map['plantId'] as String? ?? 'plant-1',
      date: map['date'] != null ? DateTime.parse(map['date'] as String) : DateTime.now(),
      supplier: map['supplier'] as String? ?? '',
      material: map['material'] as String? ?? '',
      productCode: map['productCode'] as String? ?? '',
      gsmMicron: (map['gsmMicron'] as num?)?.toDouble() ?? 80.0,
      webSizeMm: (map['webSizeMm'] as num?)?.toDouble() ?? 100.0,
      rmtIn: (map['rmtIn'] as num?)?.toDouble() ?? 0.0,
      ratePerSqMtr: (map['ratePerSqMtr'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : DateTime.now(),
      createdBy: map['createdBy'] as String? ?? 'system',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plantId': plantId,
      'date': date.toIso8601String(),
      'supplier': supplier,
      'material': material,
      'productCode': productCode,
      'gsmMicron': gsmMicron,
      'webSizeMm': webSizeMm,
      'rmtIn': rmtIn,
      'ratePerSqMtr': ratePerSqMtr,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }
}

/// Paper Roll Issuance to Press Model
@immutable
class RmIssueModel {
  final String id;
  final String plantId;
  final DateTime date;
  final String jobDocNo;
  final String material;
  final double gsmMicron;
  final double webSizeMm;
  final String supplier;
  final String client;
  final double rmtIssued;
  final String remarks;
  final DateTime createdAt;
  final String createdBy;

  const RmIssueModel({
    required this.id,
    required this.plantId,
    required this.date,
    required this.jobDocNo,
    required this.material,
    required this.gsmMicron,
    required this.webSizeMm,
    required this.supplier,
    required this.client,
    required this.rmtIssued,
    this.remarks = '',
    required this.createdAt,
    required this.createdBy,
  });

  double get sqMtrIssued => (webSizeMm * rmtIssued) / 1000.0;

  factory RmIssueModel.fromMap(String id, Map<String, dynamic> map) {
    return RmIssueModel(
      id: id,
      plantId: map['plantId'] as String? ?? 'plant-1',
      date: map['date'] != null ? DateTime.parse(map['date'] as String) : DateTime.now(),
      jobDocNo: map['jobDocNo'] as String? ?? '',
      material: map['material'] as String? ?? '',
      gsmMicron: (map['gsmMicron'] as num?)?.toDouble() ?? 80.0,
      webSizeMm: (map['webSizeMm'] as num?)?.toDouble() ?? 100.0,
      supplier: map['supplier'] as String? ?? '',
      client: map['client'] as String? ?? '',
      rmtIssued: (map['rmtIssued'] as num?)?.toDouble() ?? 0.0,
      remarks: map['remarks'] as String? ?? '',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : DateTime.now(),
      createdBy: map['createdBy'] as String? ?? 'system',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plantId': plantId,
      'date': date.toIso8601String(),
      'jobDocNo': jobDocNo,
      'material': material,
      'gsmMicron': gsmMicron,
      'webSizeMm': webSizeMm,
      'supplier': supplier,
      'client': client,
      'rmtIssued': rmtIssued,
      'remarks': remarks,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }
}

/// Paper Roll Return from Press Model
@immutable
class RmReturnModel {
  final String id;
  final String plantId;
  final DateTime date;
  final String jobDocNo;
  final String material;
  final double gsmMicron;
  final double webSizeMm;
  final String supplier;
  final String client;
  final double rmtReturned;
  final String remarks;
  final DateTime createdAt;
  final String createdBy;

  const RmReturnModel({
    required this.id,
    required this.plantId,
    required this.date,
    required this.jobDocNo,
    required this.material,
    required this.gsmMicron,
    required this.webSizeMm,
    required this.supplier,
    required this.client,
    required this.rmtReturned,
    this.remarks = '',
    required this.createdAt,
    required this.createdBy,
  });

  double get sqMtrReturned => (webSizeMm * rmtReturned) / 1000.0;

  factory RmReturnModel.fromMap(String id, Map<String, dynamic> map) {
    return RmReturnModel(
      id: id,
      plantId: map['plantId'] as String? ?? 'plant-1',
      date: map['date'] != null ? DateTime.parse(map['date'] as String) : DateTime.now(),
      jobDocNo: map['jobDocNo'] as String? ?? '',
      material: map['material'] as String? ?? '',
      gsmMicron: (map['gsmMicron'] as num?)?.toDouble() ?? 80.0,
      webSizeMm: (map['webSizeMm'] as num?)?.toDouble() ?? 100.0,
      supplier: map['supplier'] as String? ?? '',
      client: map['client'] as String? ?? '',
      rmtReturned: (map['rmtReturned'] as num?)?.toDouble() ?? 0.0,
      remarks: map['remarks'] as String? ?? '',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : DateTime.now(),
      createdBy: map['createdBy'] as String? ?? 'system',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plantId': plantId,
      'date': date.toIso8601String(),
      'jobDocNo': jobDocNo,
      'material': material,
      'gsmMicron': gsmMicron,
      'webSizeMm': webSizeMm,
      'supplier': supplier,
      'client': client,
      'rmtReturned': rmtReturned,
      'remarks': remarks,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }
}

/// Job-wise RM Usage & Wastage Reconciliation Model
@immutable
class RmJobReconciliationModel {
  final String id;
  final String plantId;
  final DateTime date;
  final String jobDocNo;
  final String clientName;
  final String material;
  final String supplier;
  final double gsmMicron;
  final double webSizeMm;
  final double targetRmt;
  final double rmtIssued;
  final double rmtReturned;
  final double okQuantity;
  final int totalUps;
  final int gearTeethZ;

  /// Actual metres printed on the press (`Wastage Report`!O - PRINT RMT).
  /// Manually recorded on the shop floor; 0 until entered.
  final double printRmt;

  /// Labels actually dispatched (`Wastage Report`!R - DISPATCH).
  /// 0 until the job is dispatched.
  final double dispatchQty;

  final DateTime createdAt;
  final String createdBy;

  RmJobReconciliationModel({
    this.id = '',
    this.plantId = 'pgpl-vasai',
    DateTime? date,
    required this.jobDocNo,
    required this.clientName,
    required this.material,
    this.supplier = 'Avery Dennison',
    this.gsmMicron = 80.0,
    required this.webSizeMm,
    this.targetRmt = 0.0,
    required this.rmtIssued,
    required this.rmtReturned,
    required this.okQuantity,
    required this.totalUps,
    required this.gearTeethZ,
    this.printRmt = 0.0,
    this.dispatchQty = 0.0,
    DateTime? createdAt,
    this.createdBy = 'system',
  })  : date = date ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  double get netRmtUsed => rmtIssued - rmtReturned;

  /// Ok Qty RMT — running metres represented by the good labels produced.
  /// Excel equivalent: `Job usage`!L = `(OkQty * (Gear / 8)) / (39.3 * Ups)`
  double get okQuantityRmt => ProductionFormulas.rmtForLabelQty(
        labelQty: okQuantity,
        gearTeethZ: gearTeethZ,
        ups: totalUps,
      );

  // ---------------------------------------------------------------------
  // Wastage definition 1 — RM WASTAGE (stock reconciliation view)
  // Source: `Stock Managemaent.xlsx` → `Job usage` sheet.
  // Answers: "material store se nikla, usme se kitna barbaad hua?"
  // ---------------------------------------------------------------------

  /// Excel equivalent: `Job usage`!N = `MAX(0, Issued - Returned - OkQtyRMT)`
  double get rmWastageRmt {
    final w = netRmtUsed - okQuantityRmt;
    return w > 0 ? w : 0.0;
  }

  /// Excel equivalent: `Job usage`!O = `(WebSizeMm * WastageRMT) / 1000`
  double get rmWastageSqMtr =>
      ProductionFormulas.sqMtr(webSizeMm: webSizeMm, rmt: rmWastageRmt);

  /// RM wastage as a share of net material drawn from stock.
  /// NOTE: the Excel `Job usage` sheet has no percentage column — this base
  /// (net RMT used) was confirmed by the user, not derived from the workbook.
  double get rmWastagePercent {
    final net = netRmtUsed;
    if (net <= 0) return 0.0;
    return (rmWastageRmt / net) * 100.0;
  }

  // ---------------------------------------------------------------------
  // Wastage definition 2 — PRODUCTION WASTAGE (monthly report view)
  // Source: `07. Wastage Report ... .xlsx` columns U and V.
  // Answers: "jitna print hua, usme se kitna actually dispatch hua?"
  // Stays NEGATIVE when dispatch falls short of print — matching the Excel.
  // ---------------------------------------------------------------------

  /// Dispatch quantity converted to running metres.
  /// Excel equivalent: `DISPATCH IN METER` = `(DispatchQty * (Gear / 8)) / (39.37 * Ups)`
  double get dispatchRmt => ProductionFormulas.rmtForLabelQty(
        labelQty: dispatchQty,
        gearTeethZ: gearTeethZ,
        ups: totalUps,
      );

  /// Excel equivalent: `Wastage Report`!U = `DispatchMtr - PrintRmt`
  /// Negative means less was dispatched than printed, i.e. production loss.
  double get productionWastageRmt => dispatchRmt - printRmt;

  /// Excel equivalent: `Wastage Report`!V = `(DispatchMtr - PrintRmt) / PrintRmt * 100`
  double get productionWastagePercent {
    if (printRmt <= 0) return 0.0;
    return (productionWastageRmt / printRmt) * 100.0;
  }

  factory RmJobReconciliationModel.fromMap(String id, Map<String, dynamic> map) {
    return RmJobReconciliationModel(
      id: id,
      plantId: map['plantId'] as String? ?? 'pgpl-vasai',
      date: map['date'] != null ? DateTime.parse(map['date'] as String) : DateTime.now(),
      jobDocNo: map['jobDocNo'] as String? ?? '',
      clientName: map['clientName'] as String? ?? '',
      material: map['material'] as String? ?? '',
      supplier: map['supplier'] as String? ?? 'Avery Dennison',
      gsmMicron: (map['gsmMicron'] as num?)?.toDouble() ?? 80.0,
      webSizeMm: (map['webSizeMm'] as num?)?.toDouble() ?? 100.0,
      targetRmt: (map['targetRmt'] as num?)?.toDouble() ?? 0.0,
      rmtIssued: (map['rmtIssued'] as num?)?.toDouble() ?? 0.0,
      rmtReturned: (map['rmtReturned'] as num?)?.toDouble() ?? 0.0,
      okQuantity: (map['okQuantity'] as num?)?.toDouble() ?? 0.0,
      totalUps: (map['totalUps'] as num?)?.toInt() ?? 1,
      gearTeethZ: (map['gearTeethZ'] as num?)?.toInt() ?? 100,
      printRmt: (map['printRmt'] as num?)?.toDouble() ?? 0.0,
      dispatchQty: (map['dispatchQty'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : DateTime.now(),
      createdBy: map['createdBy'] as String? ?? 'system',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plantId': plantId,
      'date': date.toIso8601String(),
      'jobDocNo': jobDocNo,
      'clientName': clientName,
      'material': material,
      'supplier': supplier,
      'gsmMicron': gsmMicron,
      'webSizeMm': webSizeMm,
      'targetRmt': targetRmt,
      'rmtIssued': rmtIssued,
      'rmtReturned': rmtReturned,
      'okQuantity': okQuantity,
      'totalUps': totalUps,
      'gearTeethZ': gearTeethZ,
      'printRmt': printRmt,
      'dispatchQty': dispatchQty,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }
}

/// On-Hand Store Roll Inventory Model (Grouped by Material, Web Size, AND Supplier)
@immutable
class RmStockBalanceModel {
  final String material;
  final String supplier;
  final double gsmMicron;
  final double webSizeMm;
  final double rmtIn;
  final double rmtIssued;
  final double rmtReturned;
  final double avgRate;

  const RmStockBalanceModel({
    required this.material,
    required this.supplier,
    required this.gsmMicron,
    required this.webSizeMm,
    required this.rmtIn,
    required this.rmtIssued,
    required this.rmtReturned,
    required this.avgRate,
  });

  double get rmtOnHand => rmtIn - rmtIssued + rmtReturned;
  double get sqMtrOnHand => (webSizeMm * rmtOnHand) / 1000.0;
  double get stockValue => sqMtrOnHand * avgRate;
}
