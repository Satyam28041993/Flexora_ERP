import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/firestore_paths.dart';
import '../data/models/audit_log_model.dart';
import '../data/repositories/audit_repository.dart';

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  return FirestoreAuditRepository(FirebaseFirestore.instance);
});

final auditLogsStreamProvider = StreamProvider.family<List<AuditLogModel>, String?>((ref, module) {
  final repo = ref.watch(auditRepositoryProvider);
  return repo.watchAuditLogs(plantId: DefaultPlant.id, module: module);
});
