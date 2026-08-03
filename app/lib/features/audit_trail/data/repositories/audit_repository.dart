import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../models/audit_log_model.dart';

abstract class AuditRepository {
  Stream<List<AuditLogModel>> watchAuditLogs({required String plantId, String? module});
  Future<void> logAction(AuditLogModel log);
}

class FirestoreAuditRepository implements AuditRepository {
  FirestoreAuditRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _logs =>
      _firestore.collection(FirestorePaths.auditLogs);

  @override
  Stream<List<AuditLogModel>> watchAuditLogs({required String plantId, String? module}) {
    Query<Map<String, dynamic>> query = _logs.where('plantId', isEqualTo: plantId);
    if (module != null && module.isNotEmpty) {
      query = query.where('module', isEqualTo: module);
    }
    return query
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) => AuditLogModel.fromMap(doc.id, doc.data())).toList();
          list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return list;
        });
  }

  @override
  Future<void> logAction(AuditLogModel log) async {
    await _logs.add(log.toMap());
  }
}
