import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../models/order_line_item_model.dart';
import '../models/order_model.dart';

/// Services/Repositories layer: the only place allowed to talk to Firestore
/// for the Order Intake feature (Doc Section 0A — strict layering).
abstract class OrderRepository {
  Stream<List<OrderModel>> watchOrders({required String plantId});
  Future<OrderModel?> getOrder(String orderId);
  Future<String> createOrder(OrderModel order, List<OrderLineItemModel> lineItems);
  Future<void> updateOrder(OrderModel order);
  Stream<List<OrderLineItemModel>> watchLineItems(String orderId);
}

class FirestoreOrderRepository implements OrderRepository {
  FirestoreOrderRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection(FirestorePaths.orders);

  @override
  Stream<List<OrderModel>> watchOrders({required String plantId}) {
    return _orders
        .where('plantId', isEqualTo: plantId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => OrderModel.fromMap(doc.id, doc.data())).toList());
  }

  @override
  Future<OrderModel?> getOrder(String orderId) async {
    final doc = await _orders.doc(orderId).get();
    if (!doc.exists) return null;
    return OrderModel.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<String> createOrder(OrderModel order, List<OrderLineItemModel> lineItems) async {
    final batch = _firestore.batch();
    final orderRef = _orders.doc();

    batch.set(orderRef, order.toMap());

    final lineItemsCollection = _firestore.collection(FirestorePaths.orderLineItems(orderRef.id));
    for (final item in lineItems) {
      batch.set(lineItemsCollection.doc(), item.toMap());
    }

    await batch.commit();
    return orderRef.id;
  }

  @override
  Future<void> updateOrder(OrderModel order) async {
    await _orders.doc(order.id).update(order.toMap());
  }

  @override
  Stream<List<OrderLineItemModel>> watchLineItems(String orderId) {
    return _firestore
        .collection(FirestorePaths.orderLineItems(orderId))
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => OrderLineItemModel.fromMap(doc.id, doc.data())).toList());
  }
}
