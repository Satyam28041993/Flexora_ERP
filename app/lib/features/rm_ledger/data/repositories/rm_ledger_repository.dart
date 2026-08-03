import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../models/rm_transaction_model.dart';

abstract class RmLedgerRepository {
  Stream<List<RmStockInModel>> watchStockIns(String plantId);
  Stream<List<RmIssueModel>> watchIssues(String plantId);
  Stream<List<RmReturnModel>> watchReturns(String plantId);

  Future<void> addStockIn(RmStockInModel model);
  Future<void> addIssue(RmIssueModel model);
  Future<void> addReturn(RmReturnModel model);
}

class FirestoreRmLedgerRepository implements RmLedgerRepository {
  FirestoreRmLedgerRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Stream<List<RmStockInModel>> watchStockIns(String plantId) {
    return _firestore
        .collection(FirestorePaths.rmStockIns)
        .where('plantId', isEqualTo: plantId)
        .snapshots()
        .map((s) {
      final list = s.docs.map((d) => RmStockInModel.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  @override
  Stream<List<RmIssueModel>> watchIssues(String plantId) {
    return _firestore
        .collection(FirestorePaths.rmIssues)
        .where('plantId', isEqualTo: plantId)
        .snapshots()
        .map((s) {
      final list = s.docs.map((d) => RmIssueModel.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  @override
  Stream<List<RmReturnModel>> watchReturns(String plantId) {
    return _firestore
        .collection(FirestorePaths.rmReturns)
        .where('plantId', isEqualTo: plantId)
        .snapshots()
        .map((s) {
      final list = s.docs.map((d) => RmReturnModel.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  @override
  Future<void> addStockIn(RmStockInModel model) async {
    await _firestore.collection(FirestorePaths.rmStockIns).add(model.toMap());
  }

  @override
  Future<void> addIssue(RmIssueModel model) async {
    await _firestore.collection(FirestorePaths.rmIssues).add(model.toMap());
  }

  @override
  Future<void> addReturn(RmReturnModel model) async {
    await _firestore.collection(FirestorePaths.rmReturns).add(model.toMap());
  }
}
