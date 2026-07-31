import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/firestore_paths.dart';
import '../data/models/shade_card_model.dart';
import '../data/repositories/shade_card_repository.dart';

final shadeCardRepositoryProvider = Provider<ShadeCardRepository>((ref) {
  return FirestoreShadeCardRepository(FirebaseFirestore.instance);
});

final shadeCardsStreamProvider = StreamProvider.family<List<ShadeCardModel>, String?>((ref, productId) {
  final repo = ref.watch(shadeCardRepositoryProvider);
  return repo.watchShadeCards(plantId: DefaultPlant.id, productId: productId);
});

final approvedShadeForProductFutureProvider = FutureProvider.family<ShadeCardModel?, String>((ref, productId) {
  final repo = ref.watch(shadeCardRepositoryProvider);
  return repo.getApprovedShadeForProduct(productId);
});
