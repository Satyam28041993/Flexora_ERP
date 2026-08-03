import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../models/dispatch_challan_model.dart';
import '../models/finished_roll_model.dart';
import '../models/packing_list_model.dart';

abstract class DispatchRepository {
  Stream<List<FinishedRollModel>> watchFinishedRolls({required String plantId, String? jobCardId});
  Future<String> createFinishedRoll(FinishedRollModel roll);

  Stream<List<PackingListModel>> watchPackingLists({required String plantId});
  Future<String> createPackingList(PackingListModel packingList);

  Stream<List<DispatchChallanModel>> watchDispatchChallans({required String plantId});
  Future<String> createDispatchChallan(DispatchChallanModel challan);
}

class FirestoreDispatchRepository implements DispatchRepository {
  FirestoreDispatchRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _finishedRolls =>
      _firestore.collection(FirestorePaths.finishedRolls);

  CollectionReference<Map<String, dynamic>> get _packingLists =>
      _firestore.collection(FirestorePaths.packingLists);

  CollectionReference<Map<String, dynamic>> get _challans =>
      _firestore.collection(FirestorePaths.dispatchChallans);

  CollectionReference<Map<String, dynamic>> get _jobCards =>
      _firestore.collection(FirestorePaths.jobCards);

  CollectionReference<Map<String, dynamic>> get _auditLogs =>
      _firestore.collection(FirestorePaths.auditLogs);

  @override
  Stream<List<FinishedRollModel>> watchFinishedRolls({required String plantId, String? jobCardId}) {
    Query<Map<String, dynamic>> query = _finishedRolls.where('plantId', isEqualTo: plantId);
    if (jobCardId != null && jobCardId.isNotEmpty) {
      query = query.where('jobCardId', isEqualTo: jobCardId);
    }
    return query
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) => FinishedRollModel.fromMap(doc.id, doc.data())).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  @override
  Future<String> createFinishedRoll(FinishedRollModel roll) async {
    final docRef = await _finishedRolls.add(roll.toMap());
    return docRef.id;
  }

  @override
  Stream<List<PackingListModel>> watchPackingLists({required String plantId}) {
    return _packingLists
        .where('plantId', isEqualTo: plantId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) => PackingListModel.fromMap(doc.id, doc.data())).toList();
          list.sort((a, b) => b.packingDate.compareTo(a.packingDate));
          return list;
        });
  }

  @override
  Future<String> createPackingList(PackingListModel packingList) async {
    final docRef = await _packingLists.add(packingList.toMap());
    return docRef.id;
  }

  @override
  Stream<List<DispatchChallanModel>> watchDispatchChallans({required String plantId}) {
    return _challans
        .where('plantId', isEqualTo: plantId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) => DispatchChallanModel.fromMap(doc.id, doc.data())).toList();
          list.sort((a, b) => b.dispatchDate.compareTo(a.dispatchDate));
          return list;
        });
  }

  @override
  Future<String> createDispatchChallan(DispatchChallanModel challan) async {
    // 1. Create Dispatch Challan Document
    final docRef = await _challans.add(challan.toMap());

    final batch = _firestore.batch();

    // 2. Update Finished Rolls status for this Job Card to 'Dispatched'
    final rollDocs = await _finishedRolls
        .where('jobCardId', isEqualTo: challan.jobCardId)
        .where('plantId', isEqualTo: challan.plantId)
        .get();

    for (final doc in rollDocs.docs) {
      if (doc.data()['status'] != 'Dispatched') {
        batch.update(doc.reference, {
          'status': 'Dispatched',
          'challanNo': challan.challanNo,
          'dispatchedAt': FieldValue.serverTimestamp(),
        });
      }
    }

    // 3. Update Job Card status & Dispatched Quantities
    if (challan.jobCardId.isNotEmpty) {
      final jobDocRef = _jobCards.doc(challan.jobCardId);
      final newStatus = challan.isFullyDispatched ? 'Dispatched' : 'Partially Dispatched';

      batch.set(
        jobDocRef,
        {
          'status': newStatus,
          'dispatchedQtyPcs': FieldValue.increment(challan.dispatchedQtyPcs),
          'lastDispatchedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    // 4. Record Audit Trail
    final auditRef = _auditLogs.doc();
    batch.set(auditRef, {
      'plantId': challan.plantId,
      'action': 'DISPATCH_CHALLAN_ISSUED',
      'entity': 'dispatch_challan',
      'entityId': docRef.id,
      'details': {
        'challanNo': challan.challanNo,
        'jobCardNo': challan.jobCardNo,
        'customerName': challan.customerName,
        'dispatchedQtyPcs': challan.dispatchedQtyPcs,
        'balanceQtyPcs': challan.balanceQtyPcs,
        'vehicleNo': challan.vehicleNo,
      },
      'performedBy': challan.dispatchedBy,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    return docRef.id;
  }
}
