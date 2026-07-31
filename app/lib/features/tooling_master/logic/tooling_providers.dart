import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/firestore_paths.dart';
import '../data/models/die_model.dart';
import '../data/models/plate_model.dart';
import '../data/repositories/tooling_repository.dart';

final toolingRepositoryProvider = Provider<ToolingRepository>((ref) {
  return FirestoreToolingRepository(FirebaseFirestore.instance);
});

final platesStreamProvider = StreamProvider.family<List<PlateModel>, String?>((ref, productId) {
  final repo = ref.watch(toolingRepositoryProvider);
  return repo.watchPlates(plantId: DefaultPlant.id, productId: productId);
});

final diesStreamProvider = StreamProvider<List<DieModel>>((ref) {
  final repo = ref.watch(toolingRepositoryProvider);
  return repo.watchDies(plantId: DefaultPlant.id);
});
