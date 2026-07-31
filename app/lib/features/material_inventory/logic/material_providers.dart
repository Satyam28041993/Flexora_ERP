import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/firestore_paths.dart';
import '../data/models/job_material_reconciliation_model.dart';
import '../data/models/material_transaction_model.dart';
import '../data/models/roll_model.dart';
import '../data/repositories/material_repository.dart';

final materialRepositoryProvider = Provider<MaterialRepository>((ref) {
  return FirestoreMaterialRepository(FirebaseFirestore.instance);
});

final rollsStreamProvider = StreamProvider<List<RollModel>>((ref) {
  final repo = ref.watch(materialRepositoryProvider);
  return repo.watchRolls(plantId: DefaultPlant.id);
});

final materialTransactionsStreamProvider = StreamProvider.family<List<MaterialTransactionModel>, ({String? rollId, String? jobCardId})>((ref, arg) {
  final repo = ref.watch(materialRepositoryProvider);
  return repo.watchTransactions(rollId: arg.rollId, jobCardId: arg.jobCardId);
});

final jobReconciliationsStreamProvider = StreamProvider<List<JobMaterialReconciliationModel>>((ref) {
  final repo = ref.watch(materialRepositoryProvider);
  return repo.watchJobReconciliations(plantId: DefaultPlant.id);
});
