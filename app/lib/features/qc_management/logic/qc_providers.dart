import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/firestore_paths.dart';
import '../data/models/qc_control_record_model.dart';
import '../data/repositories/qc_repository.dart';

final qcRepositoryProvider = Provider<QCRepository>((ref) {
  return FirestoreQCRepository(FirebaseFirestore.instance);
});

final qcRecordsStreamProvider = StreamProvider.family<List<QCControlRecordModel>, String?>((ref, gateType) {
  final repo = ref.watch(qcRepositoryProvider);
  return repo.watchQCRecords(plantId: DefaultPlant.id, gateType: gateType);
});
