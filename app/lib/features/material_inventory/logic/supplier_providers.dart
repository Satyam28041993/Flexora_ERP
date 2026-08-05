import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/firestore_paths.dart';
import '../data/models/supplier_model.dart';
import '../data/repositories/supplier_repository.dart';

final supplierRepositoryProvider = Provider<SupplierRepository>((ref) {
  return FirestoreSupplierRepository(FirebaseFirestore.instance);
});

final suppliersStreamProvider = StreamProvider<List<SupplierModel>>((ref) {
  final repo = ref.watch(supplierRepositoryProvider);
  return repo.watchSuppliers(plantId: DefaultPlant.id);
});
