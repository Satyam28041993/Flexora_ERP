import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../models/supplier_model.dart';

abstract class SupplierRepository {
  Stream<List<SupplierModel>> watchSuppliers({required String plantId});
  Future<SupplierModel?> getSupplier(String id);
  Future<String> createSupplier(SupplierModel supplier);
  Future<void> updateSupplier(SupplierModel supplier);
  Future<void> deleteSupplier(String id);
  Future<List<SupplierModel>> getSuppliers({required String plantId});
}

class FirestoreSupplierRepository implements SupplierRepository {
  FirestoreSupplierRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _suppliers =>
      _firestore.collection(FirestorePaths.suppliers);

  @override
  Stream<List<SupplierModel>> watchSuppliers({required String plantId}) {
    return _suppliers
        .where('plantId', isEqualTo: plantId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => SupplierModel.fromMap(doc.id, doc.data()))
          .toList();
      list.sort((a, b) => a.companyName.compareTo(b.companyName));
      return list;
    });
  }

  @override
  Future<SupplierModel?> getSupplier(String id) async {
    final doc = await _suppliers.doc(id).get();
    if (!doc.exists) return null;
    return SupplierModel.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<String> createSupplier(SupplierModel supplier) async {
    final docRef = await _suppliers.add(supplier.toMap());
    return docRef.id;
  }

  @override
  Future<void> updateSupplier(SupplierModel supplier) async {
    await _suppliers.doc(supplier.id).update(supplier.toMap());
  }

  @override
  Future<void> deleteSupplier(String id) async {
    await _suppliers.doc(id).delete();
  }

  @override
  Future<List<SupplierModel>> getSuppliers({required String plantId}) async {
    final snapshot = await _suppliers.where('plantId', isEqualTo: plantId).get();
    final list = snapshot.docs
        .map((doc) => SupplierModel.fromMap(doc.id, doc.data()))
        .toList();
    list.sort((a, b) => a.companyName.compareTo(b.companyName));
    return list;
  }
}
