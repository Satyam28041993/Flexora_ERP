import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../models/shade_card_model.dart';

abstract class ShadeCardRepository {
  Stream<List<ShadeCardModel>> watchShadeCards({required String plantId, String? productId});
  Future<ShadeCardModel?> getShadeCard(String id);
  Future<ShadeCardModel?> getApprovedShadeForProduct(String productId);
  Future<String> createShadeCard(ShadeCardModel shadeCard);
  Future<void> updateShadeCardApproval({
    required String shadeCardId,
    required String status,
    required String approvedBy,
    required String approvalEvidenceRef,
    required bool setAsPermanentReference,
  });
}

class FirestoreShadeCardRepository implements ShadeCardRepository {
  FirestoreShadeCardRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _shadeCards =>
      _firestore.collection(FirestorePaths.shadeCards);

  @override
  Stream<List<ShadeCardModel>> watchShadeCards({required String plantId, String? productId}) {
    Query<Map<String, dynamic>> query = _shadeCards.where('plantId', isEqualTo: plantId);
    if (productId != null && productId.isNotEmpty) {
      query = query.where('productId', isEqualTo: productId);
    }
    return query
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) => ShadeCardModel.fromMap(doc.id, doc.data())).toList();
          list.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
          return list;
        });
  }

  @override
  Future<ShadeCardModel?> getShadeCard(String id) async {
    final doc = await _shadeCards.doc(id).get();
    if (!doc.exists) return null;
    return ShadeCardModel.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<ShadeCardModel?> getApprovedShadeForProduct(String productId) async {
    final query = await _shadeCards
        .where('productId', isEqualTo: productId)
        .where('status', isEqualTo: ShadeCardStatus.approved)
        .where('isPermanentReference', isEqualTo: true)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return ShadeCardModel.fromMap(query.docs.first.id, query.docs.first.data());
  }

  @override
  Future<String> createShadeCard(ShadeCardModel shadeCard) async {
    final docRef = await _shadeCards.add(shadeCard.toMap());
    return docRef.id;
  }

  @override
  Future<void> updateShadeCardApproval({
    required String shadeCardId,
    required String status,
    required String approvedBy,
    required String approvalEvidenceRef,
    required bool setAsPermanentReference,
  }) async {
    final now = DateTime.now();
    await _shadeCards.doc(shadeCardId).update({
      'status': status,
      'approvedBy': approvedBy,
      'approvalDate': now.toIso8601String(),
      'approvalEvidenceRef': approvalEvidenceRef,
      'isPermanentReference': setAsPermanentReference,
      'updatedAt': now.toIso8601String(),
    });
  }
}
