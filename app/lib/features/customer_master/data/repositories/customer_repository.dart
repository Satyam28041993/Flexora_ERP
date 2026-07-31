import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../models/customer_model.dart';

abstract class CustomerRepository {
  Stream<List<CustomerModel>> watchCustomers({required String plantId});
  Future<CustomerModel?> getCustomer(String id);
  Future<String> createCustomer(CustomerModel customer);
  Future<void> updateCustomer(CustomerModel customer);
  Future<List<CustomerModel>> getActiveCustomers({required String plantId});
}

class FirestoreCustomerRepository implements CustomerRepository {
  FirestoreCustomerRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _customers =>
      _firestore.collection(FirestorePaths.customers);

  @override
  Stream<List<CustomerModel>> watchCustomers({required String plantId}) {
    return _customers
        .where('plantId', isEqualTo: plantId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => CustomerModel.fromMap(doc.id, doc.data())).toList();
      list.sort((a, b) => a.companyName.compareTo(b.companyName));
      return list;
    });
  }

  @override
  Future<CustomerModel?> getCustomer(String id) async {
    final doc = await _customers.doc(id).get();
    if (!doc.exists) return null;
    return CustomerModel.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<String> createCustomer(CustomerModel customer) async {
    final docRef = await _customers.add(customer.toMap());
    return docRef.id;
  }

  @override
  Future<void> updateCustomer(CustomerModel customer) async {
    await _customers.doc(customer.id).update(customer.toMap());
  }

  @override
  Future<List<CustomerModel>> getActiveCustomers({required String plantId}) async {
    final snapshot = await _customers.where('plantId', isEqualTo: plantId).get();
    final list = snapshot.docs
        .map((doc) => CustomerModel.fromMap(doc.id, doc.data()))
        .where((c) => c.status == CustomerStatus.active)
        .toList();
    list.sort((a, b) => a.companyName.compareTo(b.companyName));
    return list;
  }
}
