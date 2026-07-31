import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../models/die_model.dart';
import '../models/plate_model.dart';

abstract class ToolingRepository {
  // Plate operations
  Stream<List<PlateModel>> watchPlates({required String plantId, String? productId});
  Future<PlateModel?> getPlate(String id);
  Future<String> createPlate(PlateModel plate);
  Future<void> updatePlate(PlateModel plate);

  // Die operations
  Stream<List<DieModel>> watchDies({required String plantId});
  Future<DieModel?> getDie(String id);
  Future<String> createDie(DieModel die);
  Future<void> updateDie(DieModel die);
}

class FirestoreToolingRepository implements ToolingRepository {
  FirestoreToolingRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _plates =>
      _firestore.collection(FirestorePaths.plates);

  CollectionReference<Map<String, dynamic>> get _dies =>
      _firestore.collection(FirestorePaths.dies);

  @override
  Stream<List<PlateModel>> watchPlates({required String plantId, String? productId}) {
    Query<Map<String, dynamic>> query = _plates.where('plantId', isEqualTo: plantId);
    if (productId != null && productId.isNotEmpty) {
      query = query.where('productId', isEqualTo: productId);
    }
    return query
        .orderBy('plateCode')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PlateModel.fromMap(doc.id, doc.data())).toList());
  }

  @override
  Future<PlateModel?> getPlate(String id) async {
    final doc = await _plates.doc(id).get();
    if (!doc.exists) return null;
    return PlateModel.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<String> createPlate(PlateModel plate) async {
    final docRef = await _plates.add(plate.toMap());
    return docRef.id;
  }

  @override
  Future<void> updatePlate(PlateModel plate) async {
    await _plates.doc(plate.id).update(plate.toMap());
  }

  @override
  Stream<List<DieModel>> watchDies({required String plantId}) {
    return _dies
        .where('plantId', isEqualTo: plantId)
        .orderBy('dieCode')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => DieModel.fromMap(doc.id, doc.data())).toList());
  }

  @override
  Future<DieModel?> getDie(String id) async {
    final doc = await _dies.doc(id).get();
    if (!doc.exists) return null;
    return DieModel.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<String> createDie(DieModel die) async {
    final docRef = await _dies.add(die.toMap());
    return docRef.id;
  }

  @override
  Future<void> updateDie(DieModel die) async {
    await _dies.doc(die.id).update(die.toMap());
  }
}
