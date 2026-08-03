import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/firestore_paths.dart';
import '../data/models/artwork_version_model.dart';
import '../data/models/product_model.dart';
import '../data/repositories/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return FirestoreProductRepository(FirebaseFirestore.instance);
});

final productsStreamProvider = StreamProvider.family<List<ProductModel>, String?>((ref, customerId) {
  final repo = ref.watch(productRepositoryProvider);
  return repo.watchProducts(plantId: DefaultPlant.id, customerId: customerId);
});

final productArtworksStreamProvider = StreamProvider.family<List<ArtworkVersionModel>, String>((ref, productId) {
  final repo = ref.watch(productRepositoryProvider);
  return repo.watchArtworks(productId);
});

final nextSkuCodeFutureProvider = FutureProvider.autoDispose<String>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getNextSkuCode(plantId: DefaultPlant.id);
});
