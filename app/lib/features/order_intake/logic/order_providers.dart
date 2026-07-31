import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/firestore_paths.dart';
import '../data/models/order_model.dart';
import '../data/repositories/order_repository.dart';

/// Business Logic layer: screens depend on these providers, never on
/// FirebaseFirestore or the repository directly (Doc Section 0A — strict layering).
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return FirestoreOrderRepository(FirebaseFirestore.instance);
});

final ordersStreamProvider = StreamProvider.autoDispose<List<OrderModel>>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.watchOrders(plantId: DefaultPlant.id);
});
