import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../models/order_model.dart';

abstract class OrderRepository {
  Stream<List<OrderModel>> watchOrders({required String plantId});
  Future<OrderModel?> getOrder(String orderId);
  Future<String> createOrder(OrderModel order);
  Future<void> updateOrder(OrderModel order);
  Future<void> deleteOrder(String id);
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
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => OrderModel.fromMap(doc.id, doc.data())).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  @override
  Future<OrderModel?> getOrder(String orderId) async {
    final doc = await _orders.doc(orderId).get();
    if (!doc.exists) return null;
    return OrderModel.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<String> createOrder(OrderModel order) async {
    final docRef = await _orders.add(order.toMap());
    return docRef.id;
  }

  @override
  Future<void> updateOrder(OrderModel order) async {
    await _orders.doc(order.id).update(order.toMap());
  }

  @override
  Future<void> deleteOrder(String id) async {
    await _orders.doc(id).delete();
  }
}
