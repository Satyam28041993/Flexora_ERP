import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../data/models/production_job_model.dart';
import '../data/repositories/production_repository.dart';

final productionRepositoryProvider = Provider<ProductionRepository>((ref) {
  return FirestoreProductionRepository(FirebaseFirestore.instance);
});

/// Stream provider for all production jobs across all stages
final allProductionJobsStreamProvider = StreamProvider<List<ProductionJobModel>>((ref) {
  final repo = ref.watch(productionRepositoryProvider);
  return repo.watchProductionJobs(plantId: DefaultPlant.id);
});

/// Stream provider for production jobs filtered by stage and optional pending sub-status
final productionJobsStreamProvider = StreamProvider.family<List<ProductionJobModel>, ({String? stage, String? subStatus})>((ref, args) {
  final repo = ref.watch(productionRepositoryProvider);
  return repo.watchProductionJobs(
    plantId: DefaultPlant.id,
    stage: args.stage,
    pendingSubStatus: args.subStatus,
  );
});

/// Next Job Doc No future provider
final nextJobDocNoFutureProvider = FutureProvider<String>((ref) async {
  final repo = ref.watch(productionRepositoryProvider);
  return repo.generateNextJobDocNo(DefaultPlant.id);
});
