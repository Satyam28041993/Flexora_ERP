import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/firestore_paths.dart';
import '../data/models/machine_model.dart';
import '../data/models/production_log_model.dart';
import '../data/models/production_schedule_model.dart';
import '../data/repositories/production_repository.dart';

final productionRepositoryProvider = Provider<ProductionRepository>((ref) {
  return FirestoreProductionRepository(FirebaseFirestore.instance);
});

final machinesStreamProvider = StreamProvider<List<MachineModel>>((ref) {
  final repo = ref.watch(productionRepositoryProvider);
  return repo.watchMachines(plantId: DefaultPlant.id);
});

final productionSchedulesStreamProvider = StreamProvider.family<List<ProductionScheduleModel>, String?>((ref, machineId) {
  final repo = ref.watch(productionRepositoryProvider);
  return repo.watchProductionSchedules(plantId: DefaultPlant.id, machineId: machineId);
});

final productionLogsStreamProvider = StreamProvider.family<List<ProductionLogModel>, String>((ref, scheduleId) {
  final repo = ref.watch(productionRepositoryProvider);
  return repo.watchProductionLogs(scheduleId);
});
