import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../models/rm_transaction_model.dart';

abstract class RmLedgerRepository {
  Stream<List<RmStockInModel>> watchStockIns(String plantId);
  Stream<List<RmIssueModel>> watchIssues(String plantId);
  Stream<List<RmReturnModel>> watchReturns(String plantId);
  Stream<List<RmJobReconciliationModel>> watchReconciliations(String plantId);

  Future<void> addStockIn(RmStockInModel model);
  Future<void> addIssue(RmIssueModel model);
  Future<void> addReturn(RmReturnModel model);
  Future<void> addOrUpdateReconciliation(RmJobReconciliationModel model);
  Future<void> deleteReconciliation(String id);
  Future<void> deleteStockIn(String id);
  Future<void> deleteIssue(String id);
  Future<void> deleteReturn(String id);
  Future<void> deleteStockBalanceGroup({
    required String plantId,
    required String material,
    required double webSizeMm,
    required String supplier,
  });
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
  Stream<List<RmJobReconciliationModel>> watchReconciliations(String plantId) {
    return _firestore
        .collection(FirestorePaths.jobMaterialReconciliations)
        .where('plantId', isEqualTo: plantId)
        .snapshots()
        .map((s) {
      final list = s.docs.map((d) => RmJobReconciliationModel.fromMap(d.id, d.data())).toList();
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

  @override
  Future<void> addOrUpdateReconciliation(RmJobReconciliationModel model) async {
    if (model.id.isNotEmpty) {
      await _firestore.collection(FirestorePaths.jobMaterialReconciliations).doc(model.id).set(model.toMap(), SetOptions(merge: true));
    } else {
      // Check if jobDocNo already exists
      final existing = await _firestore
          .collection(FirestorePaths.jobMaterialReconciliations)
          .where('plantId', isEqualTo: model.plantId)
          .where('jobDocNo', isEqualTo: model.jobDocNo)
          .get();

      if (existing.docs.isNotEmpty) {
        await _firestore.collection(FirestorePaths.jobMaterialReconciliations).doc(existing.docs.first.id).set(model.toMap(), SetOptions(merge: true));
      } else {
        await _firestore.collection(FirestorePaths.jobMaterialReconciliations).add(model.toMap());
      }
    }
  }

  @override
  Future<void> deleteReconciliation(String id) async {
    await _firestore.collection(FirestorePaths.jobMaterialReconciliations).doc(id).delete();
  }

  @override
  Future<void> deleteStockIn(String id) async {
    await _firestore.collection(FirestorePaths.rmStockIns).doc(id).delete();
  }

  @override
  Future<void> deleteIssue(String id) async {
    await _firestore.collection(FirestorePaths.rmIssues).doc(id).delete();
  }

  @override
  Future<void> deleteReturn(String id) async {
    await _firestore.collection(FirestorePaths.rmReturns).doc(id).delete();
  }

  @override
  Future<void> deleteStockBalanceGroup({
    required String plantId,
    required String material,
    required double webSizeMm,
    required String supplier,
  }) async {
    final matClean = material.toUpperCase().trim();
    final suppClean = supplier.trim();

    // 1. Delete matching Stock-Ins
    final stockInDocs = await _firestore
        .collection(FirestorePaths.rmStockIns)
        .where('plantId', isEqualTo: plantId)
        .get();
    for (final doc in stockInDocs.docs) {
      final m = (doc.data()['material'] as String? ?? '').toUpperCase().trim();
      final s = (doc.data()['supplier'] as String? ?? 'Avery Dennison').trim();
      final w = ((doc.data()['webSizeMm'] as num?) ?? 0).toDouble();
      if (m == matClean && w.toInt() == webSizeMm.toInt() && (s.isEmpty || s.toLowerCase() == suppClean.toLowerCase() || suppClean.isEmpty)) {
        await doc.reference.delete();
      }
    }

    // 2. Delete matching Issues
    final issueDocs = await _firestore
        .collection(FirestorePaths.rmIssues)
        .where('plantId', isEqualTo: plantId)
        .get();
    for (final doc in issueDocs.docs) {
      final m = (doc.data()['material'] as String? ?? '').toUpperCase().trim();
      final s = (doc.data()['supplier'] as String? ?? 'Avery Dennison').trim();
      final w = ((doc.data()['webSizeMm'] as num?) ?? 0).toDouble();
      if (m == matClean && w.toInt() == webSizeMm.toInt() && (s.isEmpty || s.toLowerCase() == suppClean.toLowerCase() || suppClean.isEmpty)) {
        await doc.reference.delete();
      }
    }

    // 3. Delete matching Returns
    final returnDocs = await _firestore
        .collection(FirestorePaths.rmReturns)
        .where('plantId', isEqualTo: plantId)
        .get();
    for (final doc in returnDocs.docs) {
      final m = (doc.data()['material'] as String? ?? '').toUpperCase().trim();
      final s = (doc.data()['supplier'] as String? ?? 'Surya Paper').trim();
      final w = ((doc.data()['webSizeMm'] as num?) ?? 0).toDouble();
      if (m == matClean && w.toInt() == webSizeMm.toInt() && (s.isEmpty || s.toLowerCase() == suppClean.toLowerCase() || suppClean.isEmpty)) {
        await doc.reference.delete();
      }
    }
  }
}
