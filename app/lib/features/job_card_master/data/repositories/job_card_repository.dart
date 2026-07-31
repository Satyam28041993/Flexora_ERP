import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../models/job_card_model.dart';
import '../models/master_card_model.dart';

abstract class JobCardRepository {
  Stream<List<JobCardModel>> watchJobCards({required String plantId});
  Future<JobCardModel?> getJobCard(String id);
  Future<String> createJobCard(JobCardModel jobCard);
  Future<void> updateJobCard(JobCardModel jobCard);

  Future<MasterCardModel?> getMasterCardForJob(String jobCardId);
  Future<String> createMasterCard(MasterCardModel masterCard);
}

class FirestoreJobCardRepository implements JobCardRepository {
  FirestoreJobCardRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _jobCards =>
      _firestore.collection(FirestorePaths.jobCards);

  CollectionReference<Map<String, dynamic>> get _masterCards =>
      _firestore.collection(FirestorePaths.masterCards);

  @override
  Stream<List<JobCardModel>> watchJobCards({required String plantId}) {
    return _jobCards
        .where('plantId', isEqualTo: plantId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => JobCardModel.fromMap(doc.id, doc.data())).toList());
  }

  @override
  Future<JobCardModel?> getJobCard(String id) async {
    final doc = await _jobCards.doc(id).get();
    if (!doc.exists) return null;
    return JobCardModel.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<String> createJobCard(JobCardModel jobCard) async {
    final docRef = await _jobCards.add(jobCard.toMap());
    return docRef.id;
  }

  @override
  Future<void> updateJobCard(JobCardModel jobCard) async {
    await _jobCards.doc(jobCard.id).update(jobCard.toMap());
  }

  @override
  Future<MasterCardModel?> getMasterCardForJob(String jobCardId) async {
    final query = await _masterCards.where('jobCardId', isEqualTo: jobCardId).limit(1).get();
    if (query.docs.isEmpty) return null;
    return MasterCardModel.fromMap(query.docs.first.id, query.docs.first.data());
  }

  @override
  Future<String> createMasterCard(MasterCardModel masterCard) async {
    final docRef = await _masterCards.add(masterCard.toMap());

    // Update job card status to PrePressReady upon MasterCard creation
    await _jobCards.doc(masterCard.jobCardId).update({
      'status': JobCardStatus.prePressReady,
      'updatedAt': DateTime.now().toIso8601String(),
    });

    return docRef.id;
  }
}
