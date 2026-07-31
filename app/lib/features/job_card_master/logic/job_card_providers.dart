import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/firestore_paths.dart';
import '../data/models/job_card_model.dart';
import '../data/models/master_card_model.dart';
import '../data/repositories/job_card_repository.dart';

final jobCardRepositoryProvider = Provider<JobCardRepository>((ref) {
  return FirestoreJobCardRepository(FirebaseFirestore.instance);
});

final jobCardsStreamProvider = StreamProvider<List<JobCardModel>>((ref) {
  final repo = ref.watch(jobCardRepositoryProvider);
  return repo.watchJobCards(plantId: DefaultPlant.id);
});

final masterCardFutureProvider = FutureProvider.family<MasterCardModel?, String>((ref, jobCardId) {
  final repo = ref.watch(jobCardRepositoryProvider);
  return repo.getMasterCardForJob(jobCardId);
});
