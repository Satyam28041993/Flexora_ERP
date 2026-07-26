/// Order/PO Intake data model.
///
/// Field set is based on:
/// - Doc/Flexora-Master-Requirements-v1.2.md (Section 2.2 — Flexora scope starts at
///   confirmed PO + advance payment received)
/// - The company's existing "New Order Detail and Status Tracking" Google Sheet
///   (Pending / Shedule / Postpress / Dispatched tabs), which is the current real-world
///   source for these fields.
///
/// OPEN QUESTIONS (do not assume — see Doc Section 10 / CLAUDE.md Golden Rule 2):
/// - The sheet has two separate columns "Approval Date" and "Approved Date" whose exact
///   meaning is not yet confirmed by the user (artwork approval vs internal PO approval).
///   Both are kept as generic, separately-named fields until clarified.
/// - No ISO-controlled PO/Order Acceptance format has been supplied yet. Document-control
///   fields (Doc No., Revision, Approved By, etc.) are intentionally NOT added until that
///   format is shared.
/// - Advance payment amount/ledger is NOT tracked here — per user, Flexora only holds a
///   reference/flag for now; the ledger of record remains Tally.
class OrderModel {
  final String id;
  final String plantId;

  // Job/document reference (existing numbering scheme, e.g. "06/021")
  final String jobDocNo;

  final String clientName;

  final DateTime? orderDate;

  // A single PO can cover multiple products/line items and can be revised
  // (confirmed by user) — see OrderLineItem below.
  final String poNumber;
  final DateTime? poDate;

  // Present in the source sheet; exact business meaning not yet confirmed.
  final DateTime? approvalDate;
  final DateTime? approvedDate;

  final String? materialDescription;
  final String? plant;

  final double? totalRequiredQty;
  final double? pendingPoQty;

  // Advance payment: reference/flag only, not a ledger (per user decision).
  final bool advancePaymentReceived;

  // PO source document, uploaded to Firebase Storage; this field stores the
  // Storage reference path only (per locked stack: Firestore never stores large files).
  final String? poFileStoragePath;

  final String status;

  final DateTime createdAt;
  final String createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;

  const OrderModel({
    required this.id,
    required this.plantId,
    required this.jobDocNo,
    required this.clientName,
    required this.poNumber,
    required this.status,
    required this.createdAt,
    required this.createdBy,
    this.orderDate,
    this.poDate,
    this.approvalDate,
    this.approvedDate,
    this.materialDescription,
    this.plant,
    this.totalRequiredQty,
    this.pendingPoQty,
    this.advancePaymentReceived = false,
    this.poFileStoragePath,
    this.updatedAt,
    this.updatedBy,
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    return OrderModel(
      id: id,
      plantId: map['plantId'] as String,
      jobDocNo: map['jobDocNo'] as String,
      clientName: map['clientName'] as String,
      poNumber: map['poNumber'] as String,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      createdBy: map['createdBy'] as String,
      orderDate: map['orderDate'] != null ? DateTime.parse(map['orderDate'] as String) : null,
      poDate: map['poDate'] != null ? DateTime.parse(map['poDate'] as String) : null,
      approvalDate: map['approvalDate'] != null ? DateTime.parse(map['approvalDate'] as String) : null,
      approvedDate: map['approvedDate'] != null ? DateTime.parse(map['approvedDate'] as String) : null,
      materialDescription: map['materialDescription'] as String?,
      plant: map['plant'] as String?,
      totalRequiredQty: (map['totalRequiredQty'] as num?)?.toDouble(),
      pendingPoQty: (map['pendingPoQty'] as num?)?.toDouble(),
      advancePaymentReceived: map['advancePaymentReceived'] as bool? ?? false,
      poFileStoragePath: map['poFileStoragePath'] as String?,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt'] as String) : null,
      updatedBy: map['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plantId': plantId,
      'jobDocNo': jobDocNo,
      'clientName': clientName,
      'poNumber': poNumber,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'orderDate': orderDate?.toIso8601String(),
      'poDate': poDate?.toIso8601String(),
      'approvalDate': approvalDate?.toIso8601String(),
      'approvedDate': approvedDate?.toIso8601String(),
      'materialDescription': materialDescription,
      'plant': plant,
      'totalRequiredQty': totalRequiredQty,
      'pendingPoQty': pendingPoQty,
      'advancePaymentReceived': advancePaymentReceived,
      'poFileStoragePath': poFileStoragePath,
      'updatedAt': updatedAt?.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }
}

/// Order status values.
/// Deliberately minimal: Golden Rule 2 (Doc/Flexora-Master-Requirements-v1.2.md, Section 0)
/// prohibits inventing workflow/business rules that haven't been confirmed. Only "active"
/// and "cancelled" are tracked here; any further status workflow (e.g. linking to Artwork
/// Approval stage) is out of scope until that module is reached and the user confirms it.
class OrderStatus {
  static const String active = 'active';
  static const String cancelled = 'cancelled';

  static const List<String> values = [active, cancelled];
}
