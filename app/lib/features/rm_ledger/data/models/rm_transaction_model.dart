import 'package:flutter/foundation.dart';

/// Stock-In / Purchase Receipt Model
@immutable
class RmStockInModel {
  final String id;
  final String plantId;
  final DateTime date;
  final String supplier;
  final String material;
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
  final String jobDocNo;
  final String clientName;
  final String material;
  final double gsmMicron;
  final double webSizeMm;
  final double targetRmt;
  final double rmtIssued;
  final double rmtReturned;
  final double okQuantity;
  final int totalUps;
  final int gearTeethZ;

  const RmJobReconciliationModel({
    required this.jobDocNo,
    required this.clientName,
    required this.material,
    required this.gsmMicron,
    required this.webSizeMm,
    required this.targetRmt,
    required this.rmtIssued,
    required this.rmtReturned,
    required this.okQuantity,
    required this.totalUps,
    required this.gearTeethZ,
  });

  double get netRmtUsed => rmtIssued - rmtReturned;

  /// Formula: Ok Qty RMT = (Ok Quantity * (Gear / 8)) / (39.3 * Total Ups)
  double get okQuantityRmt {
    if (totalUps <= 0 || gearTeethZ <= 0) return 0.0;
    final repeatInches = gearTeethZ / 8.0;
    final lpMeter = (39.3 * totalUps) / repeatInches;
    if (lpMeter <= 0) return 0.0;
    return okQuantity / lpMeter;
  }

  /// Actual Net Production Wastage = Net RMT Used - Ok Qty RMT
  double get wastageRmt {
    final net = netRmtUsed;
    final okRmt = okQuantityRmt;
    final w = net - okRmt;
    return w > 0 ? w : 0.0;
  }

  double get wastageSqMtr => (webSizeMm * wastageRmt) / 1000.0;

  double get wastagePercent {
    final net = netRmtUsed;
    if (net <= 0) return 0.0;
    return (wastageRmt / net) * 100.0;
  }
}

/// On-Hand Store Roll Inventory Model
@immutable
class RmStockBalanceModel {
  final String material;
  final double gsmMicron;
  final double webSizeMm;
  final double rmtIn;
  final double rmtIssued;
  final double rmtReturned;
  final double avgRate;

  const RmStockBalanceModel({
    required this.material,
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
