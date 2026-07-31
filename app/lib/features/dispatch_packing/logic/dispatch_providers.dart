import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/firestore_paths.dart';
import '../data/models/dispatch_challan_model.dart';
import '../data/models/finished_roll_model.dart';
import '../data/models/packing_list_model.dart';
import '../data/repositories/dispatch_repository.dart';

final dispatchRepositoryProvider = Provider<DispatchRepository>((ref) {
  return FirestoreDispatchRepository(FirebaseFirestore.instance);
});

final finishedRollsStreamProvider = StreamProvider.family<List<FinishedRollModel>, String?>((ref, jobCardId) {
  final repo = ref.watch(dispatchRepositoryProvider);
  return repo.watchFinishedRolls(plantId: DefaultPlant.id, jobCardId: jobCardId);
});

final packingListsStreamProvider = StreamProvider<List<PackingListModel>>((ref) {
  final repo = ref.watch(dispatchRepositoryProvider);
  return repo.watchPackingLists(plantId: DefaultPlant.id);
});

final dispatchChallansStreamProvider = StreamProvider<List<DispatchChallanModel>>((ref) {
  final repo = ref.watch(dispatchRepositoryProvider);
  return repo.watchDispatchChallans(plantId: DefaultPlant.id);
});
