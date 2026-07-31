import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../models/machine_model.dart';
import '../models/production_log_model.dart';
import '../models/production_schedule_model.dart';

abstract class ProductionRepository {
  Stream<List<MachineModel>> watchMachines({required String plantId});
  Stream<List<ProductionScheduleModel>> watchProductionSchedules({required String plantId, String? machineId});
  Future<String> createProductionSchedule(ProductionScheduleModel schedule);
  Future<void> updateScheduleStatus(String scheduleId, String status);

  Stream<List<ProductionLogModel>> watchProductionLogs(String scheduleId);
  Future<String> createProductionLog(ProductionLogModel log);
}

class FirestoreProductionRepository implements ProductionRepository {
  FirestoreProductionRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _machines =>
      _firestore.collection(FirestorePaths.machines);

  CollectionReference<Map<String, dynamic>> get _schedules =>
      _firestore.collection(FirestorePaths.productionSchedules);

  CollectionReference<Map<String, dynamic>> get _logs =>
      _firestore.collection(FirestorePaths.productionLogs);

  @override
  Stream<List<MachineModel>> watchMachines({required String plantId}) {
    return _machines
        .where('plantId', isEqualTo: plantId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MachineModel.fromMap(doc.id, doc.data())).toList());
  }

  @override
  Stream<List<ProductionScheduleModel>> watchProductionSchedules({required String plantId, String? machineId}) {
    Query<Map<String, dynamic>> query = _schedules.where('plantId', isEqualTo: plantId);
    if (machineId != null && machineId.isNotEmpty) {
      query = query.where('machineId', isEqualTo: machineId);
    }
    return query
        .orderBy('queuePriority')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductionScheduleModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  @override
  Future<String> createProductionSchedule(ProductionScheduleModel schedule) async {
    final docRef = await _schedules.add(schedule.toMap());
    return docRef.id;
  }

  @override
  Future<void> updateScheduleStatus(String scheduleId, String status) async {
    await _schedules.doc(scheduleId).update({'status': status});
  }

  @override
  Stream<List<ProductionLogModel>> watchProductionLogs(String scheduleId) {
    return _logs
        .where('scheduleId', isEqualTo: scheduleId)
        .orderBy('runStartTime', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ProductionLogModel.fromMap(doc.id, doc.data())).toList());
  }

  @override
  Future<String> createProductionLog(ProductionLogModel log) async {
    final docRef = await _logs.add(log.toMap());
    return docRef.id;
  }
}
