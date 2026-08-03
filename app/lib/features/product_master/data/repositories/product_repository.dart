import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../models/artwork_version_model.dart';
import '../models/product_model.dart';

abstract class ProductRepository {
  Stream<List<ProductModel>> watchProducts({required String plantId, String? customerId});
  Future<ProductModel?> getProduct(String id);
  Future<String> createProduct(ProductModel product);
  Future<void> updateProduct(ProductModel product);
  Future<String> getNextSkuCode({required String plantId});

  Stream<List<ArtworkVersionModel>> watchArtworks(String productId);
  Future<String> addArtworkVersion(String productId, ArtworkVersionModel artwork);
  Future<void> updateArtworkApproval({
    required String productId,
    required String artworkId,
    required String status,
    required String approvedBy,
    required String approvalEvidenceRef,
  });
}

class FirestoreProductRepository implements ProductRepository {
  FirestoreProductRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _products =>
      _firestore.collection(FirestorePaths.products);

  @override
  Stream<List<ProductModel>> watchProducts({required String plantId, String? customerId}) {
    Query<Map<String, dynamic>> query = _products.where('plantId', isEqualTo: plantId);
    if (customerId != null && customerId.isNotEmpty) {
      query = query.where('customerId', isEqualTo: customerId);
    }
    return query
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) => ProductModel.fromMap(doc.id, doc.data())).toList();
          list.sort((a, b) => a.productName.compareTo(b.productName));
          return list;
        });
  }

  @override
  Future<ProductModel?> getProduct(String id) async {
    final doc = await _products.doc(id).get();
    if (!doc.exists) return null;
    return ProductModel.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<String> createProduct(ProductModel product) async {
    final docRef = await _products.add(product.toMap());
    return docRef.id;
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    await _products.doc(product.id).update(product.toMap());
  }

  @override
  Future<String> getNextSkuCode({required String plantId}) async {
    try {
      final querySnapshot = await _products
          .where('internalSkuCode', isGreaterThanOrEqualTo: 'PG/SKU/')
          .where('internalSkuCode', isLessThan: 'PG/SKU/\uf8ff')
          .orderBy('internalSkuCode', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final code = querySnapshot.docs.first.data()['internalSkuCode'] as String?;
        if (code != null && code.startsWith('PG/SKU/')) {
          final numberString = code.replaceFirst('PG/SKU/', '');
          final number = int.tryParse(numberString);
          if (number != null) {
            final nextNumber = number + 1;
            return 'PG/SKU/${nextNumber.toString().padLeft(3, '0')}';
          }
        }
      }
    } catch (e) {
      // Fallback if query fails
      print('Error in getNextSkuCode query: $e');
    }

    // Default if no documents found or error
    return 'PG/SKU/001';
  }

  @override
  Stream<List<ArtworkVersionModel>> watchArtworks(String productId) {
    return _firestore
        .collection(FirestorePaths.productArtworks(productId))
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => ArtworkVersionModel.fromMap(doc.id, doc.data()))
              .toList();
          list.sort((a, b) => b.versionNumber.compareTo(a.versionNumber));
          return list;
        });
  }

  @override
  Future<String> addArtworkVersion(String productId, ArtworkVersionModel artwork) async {
    final docRef = await _firestore
        .collection(FirestorePaths.productArtworks(productId))
        .add(artwork.toMap());

    // Update current artwork reference on product document
    await _products.doc(productId).update({
      'currentArtworkVersionId': docRef.id,
      'currentArtworkStoragePath': artwork.storagePath,
      'artworkApprovalStatus': artwork.status,
      'updatedAt': DateTime.now().toIso8601String(),
    });

    return docRef.id;
  }

  @override
  Future<void> updateArtworkApproval({
    required String productId,
    required String artworkId,
    required String status,
    required String approvedBy,
    required String approvalEvidenceRef,
  }) async {
    final now = DateTime.now();

    final batch = _firestore.batch();
    final artworkRef = _firestore
        .collection(FirestorePaths.productArtworks(productId))
        .doc(artworkId);

    batch.update(artworkRef, {
      'status': status,
      'approvedBy': approvedBy,
      'approvalDate': now.toIso8601String(),
      'approvalEvidenceRef': approvalEvidenceRef,
    });

    final productRef = _products.doc(productId);
    batch.update(productRef, {
      'artworkApprovalStatus': status,
      'artworkApprovalDate': status == ArtworkApprovalStatus.approved ? now.toIso8601String() : null,
      'updatedAt': now.toIso8601String(),
    });

    await batch.commit();
  }
}
