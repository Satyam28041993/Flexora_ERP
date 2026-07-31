import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/firestore_paths.dart';
import '../data/models/customer_model.dart';
import '../data/repositories/customer_repository.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return FirestoreCustomerRepository(FirebaseFirestore.instance);
});

final customersStreamProvider = StreamProvider<List<CustomerModel>>((ref) {
  final repo = ref.watch(customerRepositoryProvider);
  return repo.watchCustomers(plantId: DefaultPlant.id);
});

final activeCustomersFutureProvider = FutureProvider<List<CustomerModel>>((ref) {
  final repo = ref.watch(customerRepositoryProvider);
  return repo.getActiveCustomers(plantId: DefaultPlant.id);
});
