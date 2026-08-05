import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../models/job_material_reconciliation_model.dart';
import '../models/material_transaction_model.dart';
import '../models/roll_model.dart';

abstract class MaterialRepository {
  Stream<List<RollModel>> watchRolls({required String plantId});
  Future<RollModel?> getRoll(String id);
  Future<String> createRoll(RollModel roll);
  Future<void> updateRoll(RollModel roll);
  Future<void> deleteRoll(String id);

  Future<void> issueRollToJob({
    required String rollId,
    required String jobCardId,
    required String jobCardNo,
    required String customerName,
    required String productName,
    required double issuedRmt,
    required String performedBy,
  });

  Future<void> returnLeftoverRollToStores({
    required String rollId,
    required String jobCardId,
    required String jobCardNo,
    required double returnedRmt,
    required String performedBy,
    String? remarks,
  });

  Stream<List<MaterialTransactionModel>> watchTransactions({String? rollId, String? jobCardId});
  Stream<List<JobMaterialReconciliationModel>> watchJobReconciliations({required String plantId});
}

class FirestoreMaterialRepository implements MaterialRepository {
  FirestoreMaterialRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _rolls =>
      _firestore.collection(FirestorePaths.rolls);

  CollectionReference<Map<String, dynamic>> get _transactions =>
      _firestore.collection(FirestorePaths.materialTransactions);

  CollectionReference<Map<String, dynamic>> get _reconciliations =>
      _firestore.collection(FirestorePaths.jobMaterialReconciliations);

  @override
  Stream<List<RollModel>> watchRolls({required String plantId}) {
    return _rolls
        .where('plantId', isEqualTo: plantId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) => RollModel.fromMap(doc.id, doc.data())).toList();
          list.sort((a, b) => a.rollCode.compareTo(b.rollCode));
          return list;
        });
  }

  @override
  Future<RollModel?> getRoll(String id) async {
    final doc = await _rolls.doc(id).get();
    if (!doc.exists) return null;
    return RollModel.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<String> createRoll(RollModel roll) async {
    final docRef = await _rolls.add(roll.toMap());

    // Log purchase receipt transaction per Golden Rule 7
    await _transactions.add(MaterialTransactionModel(
      id: '',
      plantId: roll.plantId,
      transactionType: MaterialTransactionType.purchaseReceipt,
      rollId: docRef.id,
      rollCode: roll.rollCode,
      rmtQuantity: roll.originalRmt,
      timestamp: DateTime.now(),
      performedBy: roll.createdBy,
      remarks: 'Initial Purchase Receipt from ${roll.vendorName}',
    ).toMap());

    return docRef.id;
  }

  @override
  Future<void> updateRoll(RollModel roll) async {
    await _rolls.doc(roll.id).update(roll.toMap());
  }

  @override
  Future<void> deleteRoll(String id) async {
    await _rolls.doc(id).delete();
  }

  @override
  Future<void> issueRollToJob({
    required String rollId,
    required String jobCardId,
    required String jobCardNo,
    required String customerName,
    required String productName,
    required double issuedRmt,
    required String performedBy,
  }) async {
    final batch = _firestore.batch();
    final rollRef = _rolls.doc(rollId);
    final rollDoc = await rollRef.get();

    if (!rollDoc.exists) throw Exception('Roll not found');

    final roll = RollModel.fromMap(rollDoc.id, rollDoc.data()!);
    final newAvailableRmt = (roll.availableRmt - issuedRmt).clamp(0.0, double.infinity);
    final newStatus = newAvailableRmt == 0 ? RollStatus.depleted : RollStatus.issued;

    // Update Roll stock
    batch.update(rollRef, {
      'availableRmt': newAvailableRmt,
      'status': newStatus,
      'updatedAt': DateTime.now().toIso8601String(),
    });

    // Create Issue Transaction
    final txRef = _transactions.doc();
    batch.set(txRef, MaterialTransactionModel(
      id: '',
      plantId: roll.plantId,
      transactionType: MaterialTransactionType.issueToJob,
      rollId: rollId,
      rollCode: roll.rollCode,
      jobCardId: jobCardId,
      jobCardNo: jobCardNo,
      rmtQuantity: issuedRmt,
      timestamp: DateTime.now(),
      performedBy: performedBy,
    ).toMap());

    // Update or Create Job Reconciliation
    final reconQuery = await _reconciliations.where('jobCardId', isEqualTo: jobCardId).limit(1).get();
    if (reconQuery.docs.isNotEmpty) {
      final reconDoc = reconQuery.docs.first;
      final currentIssued = (reconDoc.data()['issuedRmt'] as num?)?.toDouble() ?? 0.0;
      batch.update(reconDoc.reference, {
        'issuedRmt': currentIssued + issuedRmt,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } else {
      final newReconRef = _reconciliations.doc();
      batch.set(newReconRef, JobMaterialReconciliationModel(
        id: '',
        plantId: roll.plantId,
        jobCardId: jobCardId,
        jobCardNo: jobCardNo,
        customerName: customerName,
        productName: productName,
        plannedRmt: issuedRmt,
        issuedRmt: issuedRmt,
        createdAt: DateTime.now(),
        createdBy: performedBy,
      ).toMap());
    }

    await batch.commit();
  }

  @override
  Future<void> returnLeftoverRollToStores({
    required String rollId,
    required String jobCardId,
    required String jobCardNo,
    required double returnedRmt,
    required String performedBy,
    String? remarks,
  }) async {
    final batch = _firestore.batch();
    final rollRef = _rolls.doc(rollId);
    final rollDoc = await rollRef.get();

    if (!rollDoc.exists) throw Exception('Roll not found');

    final roll = RollModel.fromMap(rollDoc.id, rollDoc.data()!);
    final newAvailableRmt = roll.availableRmt + returnedRmt;

    // Update Roll stock (available RMT increases again)
    batch.update(rollRef, {
      'availableRmt': newAvailableRmt,
      'status': RollStatus.available,
      'updatedAt': DateTime.now().toIso8601String(),
    });

    // Create Return Transaction
    final txRef = _transactions.doc();
    batch.set(txRef, MaterialTransactionModel(
      id: '',
      plantId: roll.plantId,
      transactionType: MaterialTransactionType.leftoverReturn,
      rollId: rollId,
      rollCode: roll.rollCode,
      jobCardId: jobCardId,
      jobCardNo: jobCardNo,
      rmtQuantity: returnedRmt,
      timestamp: DateTime.now(),
      performedBy: performedBy,
      remarks: remarks ?? 'Leftover roll returned from production to stores',
    ).toMap());

    // Update Job Reconciliation
    final reconQuery = await _reconciliations.where('jobCardId', isEqualTo: jobCardId).limit(1).get();
    if (reconQuery.docs.isNotEmpty) {
      final reconDoc = reconQuery.docs.first;
      final currentReturned = (reconDoc.data()['returnedRmt'] as num?)?.toDouble() ?? 0.0;
      batch.update(reconDoc.reference, {
        'returnedRmt': currentReturned + returnedRmt,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    }

    await batch.commit();
  }

  @override
  Stream<List<MaterialTransactionModel>> watchTransactions({String? rollId, String? jobCardId}) {
    Query<Map<String, dynamic>> query = _transactions;
    if (rollId != null && rollId.isNotEmpty) {
      query = query.where('rollId', isEqualTo: rollId);
    }
    if (jobCardId != null && jobCardId.isNotEmpty) {
      query = query.where('jobCardId', isEqualTo: jobCardId);
    }
    return query
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => MaterialTransactionModel.fromMap(doc.id, doc.data()))
              .toList();
          list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return list;
        });
  }

  @override
  Stream<List<JobMaterialReconciliationModel>> watchJobReconciliations({required String plantId}) {
    return _reconciliations
        .where('plantId', isEqualTo: plantId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => JobMaterialReconciliationModel.fromMap(doc.id, doc.data()))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }
}
