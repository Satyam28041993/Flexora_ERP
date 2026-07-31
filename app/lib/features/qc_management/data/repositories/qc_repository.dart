import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../models/qc_control_record_model.dart';

abstract class QCRepository {
  Stream<List<QCControlRecordModel>> watchQCRecords({required String plantId, String? gateType});
  Future<QCControlRecordModel?> getQCRecord(String id);
  Future<String> createQCRecord(QCControlRecordModel record);
}

class FirestoreQCRepository implements QCRepository {
  FirestoreQCRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _records =>
      _firestore.collection(FirestorePaths.qcControlRecords);

  @override
  Stream<List<QCControlRecordModel>> watchQCRecords({required String plantId, String? gateType}) {
    Query<Map<String, dynamic>> query = _records.where('plantId', isEqualTo: plantId);
    if (gateType != null && gateType.isNotEmpty) {
      query = query.where('gateType', isEqualTo: gateType);
    }
    return query
        .orderBy('inspectionDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => QCControlRecordModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  @override
  Future<QCControlRecordModel?> getQCRecord(String id) async {
    final doc = await _records.doc(id).get();
    if (!doc.exists) return null;
    return QCControlRecordModel.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<String> createQCRecord(QCControlRecordModel record) async {
    final docRef = await _records.add(record.toMap());
    return docRef.id;
  }
}
