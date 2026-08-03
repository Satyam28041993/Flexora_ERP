import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../models/production_job_model.dart';

abstract class ProductionRepository {
  Stream<List<ProductionJobModel>> watchProductionJobs({
    required String plantId,
    String? stage,
    String? pendingSubStatus,
  });

  Future<ProductionJobModel?> getProductionJob(String id);
  Future<String> createProductionJob(ProductionJobModel job);
  Future<void> updateProductionJob(ProductionJobModel job);
  Future<void> updateJobStage(String id, String newStage);
  Future<void> updateJobPendingSubStatus(String id, String newSubStatus);
  Future<String> generateNextJobDocNo(String plantId);
}

class FirestoreProductionRepository implements ProductionRepository {
  FirestoreProductionRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _jobs =>
      _firestore.collection(FirestorePaths.productionOrders);

  @override
  Stream<List<ProductionJobModel>> watchProductionJobs({
    required String plantId,
    String? stage,
    String? pendingSubStatus,
  }) {
    Query<Map<String, dynamic>> query = _jobs.where('plantId', isEqualTo: plantId);

    if (stage != null && stage.isNotEmpty) {
      query = query.where('currentStage', isEqualTo: stage);
    }
    if (pendingSubStatus != null && pendingSubStatus.isNotEmpty) {
      query = query.where('pendingSubStatus', isEqualTo: pendingSubStatus);
    }

    return query.snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => ProductionJobModel.fromMap(doc.id, doc.data()))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  @override
  Future<ProductionJobModel?> getProductionJob(String id) async {
    final doc = await _jobs.doc(id).get();
    if (!doc.exists) return null;
    return ProductionJobModel.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<String> createProductionJob(ProductionJobModel job) async {
    final docRef = await _jobs.add(job.toMap());
    return docRef.id;
  }

  @override
  Future<void> updateProductionJob(ProductionJobModel job) async {
    final data = job.toMap();
    data['updatedAt'] = DateTime.now().toIso8601String();
    await _jobs.doc(job.id).update(data);
  }

  @override
  Future<void> updateJobStage(String id, String newStage) async {
    await _jobs.doc(id).update({
      'currentStage': newStage,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> updateJobPendingSubStatus(String id, String newSubStatus) async {
    await _jobs.doc(id).update({
      'pendingSubStatus': newSubStatus,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<String> generateNextJobDocNo(String plantId) async {
    final now = DateTime.now();
    final monthStr = now.month.toString().padLeft(2, '0');

    final snapshot = await _jobs.where('plantId', isEqualTo: plantId).get();
    int highestSeq = 0;

    for (final doc in snapshot.docs) {
      final docNo = doc.data()['jobDocNo'] as String? ?? '';
      if (docNo.contains('/')) {
        final parts = docNo.split('/');
        final seq = int.tryParse(parts.last);
        if (seq != null && seq > highestSeq) {
          highestSeq = seq;
        }
      }
    }

    final nextSeq = (highestSeq + 1).toString().padLeft(3, '0');
    return '$monthStr/$nextSeq';
  }
}
