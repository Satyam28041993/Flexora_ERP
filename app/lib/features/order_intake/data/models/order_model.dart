import 'package:flutter/foundation.dart';

/// Single Line Item inside a Purchase Order (PO).
///
/// Implements Real Flexo PO Structure:
/// Supports multiple label SKUs per PO with size, HSN 48211020, quantity, unit rate (Rs.), and line total.
@immutable
class OrderLineItemModel {
  final String id;
  final int itemNo;

  final String hsnCode; // 48211020 for printed labels & stickers
  final String itemName;
  final String labelDescription;

  final double sizeWidthMm;
  final double sizeHeightMm;
  final String substrateSpec;

  final double quantityPcs;
  final double unitRateRs;
  final double lineAmountRs;

  final DateTime? deliveryScheduleDate;

  const OrderLineItemModel({
    required this.id,
    required this.itemNo,
    required this.itemName,
    required this.quantityPcs,
    required this.unitRateRs,
    required this.lineAmountRs,
    this.hsnCode = '48211020',
    this.labelDescription = '',
    this.sizeWidthMm = 0.0,
    this.sizeHeightMm = 0.0,
    this.substrateSpec = 'Self-Adhesive Chromo Paper',
    this.deliveryScheduleDate,
  });

  factory OrderLineItemModel.fromMap(Map<String, dynamic> map) {
    return OrderLineItemModel(
      id: map['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      itemNo: map['itemNo'] as int? ?? 1,
      hsnCode: map['hsnCode'] as String? ?? '48211020',
      itemName: map['itemName'] as String? ?? '',
      labelDescription: map['labelDescription'] as String? ?? '',
      sizeWidthMm: (map['sizeWidthMm'] as num?)?.toDouble() ?? 0.0,
      sizeHeightMm: (map['sizeHeightMm'] as num?)?.toDouble() ?? 0.0,
      substrateSpec: map['substrateSpec'] as String? ?? 'Self-Adhesive Chromo Paper',
      quantityPcs: (map['quantityPcs'] as num?)?.toDouble() ?? 0.0,
      unitRateRs: (map['unitRateRs'] as num?)?.toDouble() ?? 0.0,
      lineAmountRs: (map['lineAmountRs'] as num?)?.toDouble() ?? 0.0,
      deliveryScheduleDate: map['deliveryScheduleDate'] != null
          ? DateTime.parse(map['deliveryScheduleDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemNo': itemNo,
      'hsnCode': hsnCode,
      'itemName': itemName,
      'labelDescription': labelDescription,
      'sizeWidthMm': sizeWidthMm,
      'sizeHeightMm': sizeHeightMm,
      'substrateSpec': substrateSpec,
      'quantityPcs': quantityPcs,
      'unitRateRs': unitRateRs,
      'lineAmountRs': lineAmountRs,
      'deliveryScheduleDate': deliveryScheduleDate?.toIso8601String(),
    };
  }

  OrderLineItemModel copyWith({
    String? itemName,
    String? labelDescription,
    double? sizeWidthMm,
    double? sizeHeightMm,
    String? substrateSpec,
    double? quantityPcs,
    double? unitRateRs,
    double? lineAmountRs,
  }) {
    return OrderLineItemModel(
      id: id,
      itemNo: itemNo,
      hsnCode: hsnCode,
      itemName: itemName ?? this.itemName,
      labelDescription: labelDescription ?? this.labelDescription,
      sizeWidthMm: sizeWidthMm ?? this.sizeWidthMm,
      sizeHeightMm: sizeHeightMm ?? this.sizeHeightMm,
      substrateSpec: substrateSpec ?? this.substrateSpec,
      quantityPcs: quantityPcs ?? this.quantityPcs,
      unitRateRs: unitRateRs ?? this.unitRateRs,
      lineAmountRs: lineAmountRs ?? (quantityPcs != null || unitRateRs != null ? ((quantityPcs ?? this.quantityPcs) * (unitRateRs ?? this.unitRateRs)) : this.lineAmountRs),
      deliveryScheduleDate: deliveryScheduleDate,
    );
  }
}

/// Purchase Order (PO) Master Data Model.
@immutable
class OrderModel {
  final String id;
  final String plantId;

  final String poNumber; // e.g. PK/MUM/155/2026-2027, BM/PGPL/26-27/051, PO:05051
  final DateTime poDate;

  final String customerId;
  final String customerName;
  final String customerGstNo;

  final String shippingAddress;
  final String? deliveryScheduleText;
  final int paymentTermsDays;
  final String? specialNotes;

  // Attached PO Document (PDF / Image)
  final String? attachmentFileName;
  final String? attachmentFilePath;
  final String? attachmentFileType; // pdf, image

  // Multiple Line Items / Label SKUs
  final List<OrderLineItemModel> lineItems;

  // Financial Breakdown (Rs.)
  final double taxableSubtotal;
  final double gstRatePercent; // default 18%
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double freightCharges;
  final double oneTimePunchCost;
  final double grandTotalAmount;

  final String status; // Pending, Verified, Processing, Completed, Cancelled

  final DateTime createdAt;
  final String createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;

  const OrderModel({
    required this.id,
    required this.plantId,
    required this.poNumber,
    required this.poDate,
    required this.customerId,
    required this.customerName,
    required this.customerGstNo,
    required this.shippingAddress,
    required this.lineItems,
    required this.taxableSubtotal,
    required this.grandTotalAmount,
    required this.createdAt,
    required this.createdBy,
    this.deliveryScheduleText,
    this.paymentTermsDays = 30,
    this.specialNotes,
    this.attachmentFileName,
    this.attachmentFilePath,
    this.attachmentFileType,
    this.gstRatePercent = 18.0,
    this.cgstAmount = 0.0,
    this.sgstAmount = 0.0,
    this.igstAmount = 0.0,
    this.freightCharges = 0.0,
    this.oneTimePunchCost = 0.0,
    this.status = 'Pending',
    this.updatedAt,
    this.updatedBy,
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    final rawItems = map['lineItems'] as List<dynamic>? ?? [];
    final items = rawItems.map((item) => OrderLineItemModel.fromMap(item as Map<String, dynamic>)).toList();

    return OrderModel(
      id: id,
      plantId: map['plantId'] as String? ?? 'plant-1',
      poNumber: map['poNumber'] as String? ?? '',
      poDate: map['poDate'] != null ? DateTime.parse(map['poDate'] as String) : DateTime.now(),
      customerId: map['customerId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      customerGstNo: map['customerGstNo'] as String? ?? '',
      shippingAddress: map['shippingAddress'] as String? ?? '',
      deliveryScheduleText: map['deliveryScheduleText'] as String?,
      paymentTermsDays: map['paymentTermsDays'] as int? ?? 30,
      specialNotes: map['specialNotes'] as String?,
      attachmentFileName: map['attachmentFileName'] as String?,
      attachmentFilePath: map['attachmentFilePath'] as String?,
      attachmentFileType: map['attachmentFileType'] as String?,
      lineItems: items,
      taxableSubtotal: (map['taxableSubtotal'] as num?)?.toDouble() ?? 0.0,
      gstRatePercent: (map['gstRatePercent'] as num?)?.toDouble() ?? 18.0,
      cgstAmount: (map['cgstAmount'] as num?)?.toDouble() ?? 0.0,
      sgstAmount: (map['sgstAmount'] as num?)?.toDouble() ?? 0.0,
      igstAmount: (map['igstAmount'] as num?)?.toDouble() ?? 0.0,
      freightCharges: (map['freightCharges'] as num?)?.toDouble() ?? 0.0,
      oneTimePunchCost: (map['oneTimePunchCost'] as num?)?.toDouble() ?? 0.0,
      grandTotalAmount: (map['grandTotalAmount'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? 'Pending',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : DateTime.now(),
      createdBy: map['createdBy'] as String? ?? 'system',
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt'] as String) : null,
      updatedBy: map['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plantId': plantId,
      'poNumber': poNumber,
      'poDate': poDate.toIso8601String(),
      'customerId': customerId,
      'customerName': customerName,
      'customerGstNo': customerGstNo,
      'shippingAddress': shippingAddress,
      'deliveryScheduleText': deliveryScheduleText,
      'paymentTermsDays': paymentTermsDays,
      'specialNotes': specialNotes,
      'attachmentFileName': attachmentFileName,
      'attachmentFilePath': attachmentFilePath,
      'attachmentFileType': attachmentFileType,
      'lineItems': lineItems.map((item) => item.toMap()).toList(),
      'taxableSubtotal': taxableSubtotal,
      'gstRatePercent': gstRatePercent,
      'cgstAmount': cgstAmount,
      'sgstAmount': sgstAmount,
      'igstAmount': igstAmount,
      'freightCharges': freightCharges,
      'oneTimePunchCost': oneTimePunchCost,
      'grandTotalAmount': grandTotalAmount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedAt': updatedAt?.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }

  double get totalQuantityPcs => lineItems.fold(0.0, (sum, item) => sum + item.quantityPcs);
}
