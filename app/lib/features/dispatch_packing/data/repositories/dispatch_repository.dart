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
    final docRef = await _challans.add(challan.toMap());
    return docRef.id;
  }
}
