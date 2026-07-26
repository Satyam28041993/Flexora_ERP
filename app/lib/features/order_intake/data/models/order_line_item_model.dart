/// A single product/job line under an Order/PO.
///
/// User confirmed one PO can cover multiple products/jobs, and that a PO can be revised.
/// Stored as a subcollection of the parent Order document so each line keeps its own
/// Job Doc. No. and quantity, and PO revisions can be appended without losing history
/// (Golden Rule 5 — revision/change control, never silently overwritten).
class OrderLineItemModel {
  final String id;
  final String orderId;

  final String jobDocNo;
  final String? materialDescription;
  final double? orderQty;
  final double? pendingQty;

  // PO revision this line was recorded/last amended under.
  final int revisionNo;

  final DateTime createdAt;
  final String createdBy;

  const OrderLineItemModel({
    required this.id,
    required this.orderId,
    required this.jobDocNo,
    required this.revisionNo,
    required this.createdAt,
    required this.createdBy,
    this.materialDescription,
    this.orderQty,
    this.pendingQty,
  });

  factory OrderLineItemModel.fromMap(String id, Map<String, dynamic> map) {
    return OrderLineItemModel(
      id: id,
      orderId: map['orderId'] as String,
      jobDocNo: map['jobDocNo'] as String,
      revisionNo: map['revisionNo'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
      createdBy: map['createdBy'] as String,
      materialDescription: map['materialDescription'] as String?,
      orderQty: (map['orderQty'] as num?)?.toDouble(),
      pendingQty: (map['pendingQty'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'jobDocNo': jobDocNo,
      'revisionNo': revisionNo,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'materialDescription': materialDescription,
      'orderQty': orderQty,
      'pendingQty': pendingQty,
    };
  }
}
