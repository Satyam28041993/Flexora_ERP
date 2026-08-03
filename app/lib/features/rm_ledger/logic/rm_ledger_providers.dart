import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../data/models/rm_transaction_model.dart';
import '../data/repositories/rm_ledger_repository.dart';

final rmLedgerRepositoryProvider = Provider<RmLedgerRepository>((ref) {
  return FirestoreRmLedgerRepository(FirebaseFirestore.instance);
});

final rmStockInsStreamProvider = StreamProvider<List<RmStockInModel>>((ref) {
  final repo = ref.watch(rmLedgerRepositoryProvider);
  return repo.watchStockIns(DefaultPlant.id);
});

final rmIssuesStreamProvider = StreamProvider<List<RmIssueModel>>((ref) {
  final repo = ref.watch(rmLedgerRepositoryProvider);
  return repo.watchIssues(DefaultPlant.id);
});

final rmReturnsStreamProvider = StreamProvider<List<RmReturnModel>>((ref) {
  final repo = ref.watch(rmLedgerRepositoryProvider);
  return repo.watchReturns(DefaultPlant.id);
});

/// Calculated Provider for Store Roll Stock Balances (OnHand = In - Issued + Returned)
final rmStockBalancesProvider = Provider<List<RmStockBalanceModel>>((ref) {
  final stockIns = ref.watch(rmStockInsStreamProvider).value ?? [];
  final issues = ref.watch(rmIssuesStreamProvider).value ?? [];
  final returns = ref.watch(rmReturnsStreamProvider).value ?? [];

  final Map<String, ({double inRmt, double issuedRmt, double returnedRmt, double totalCost, double totalSqMtrIn})> map = {};

  for (final item in stockIns) {
    final key = '${item.material.toUpperCase().trim()}_${item.webSizeMm.toInt()}';
    final existing = map[key] ?? (inRmt: 0.0, issuedRmt: 0.0, returnedRmt: 0.0, totalCost: 0.0, totalSqMtrIn: 0.0);
    map[key] = (
      inRmt: existing.inRmt + item.rmtIn,
      issuedRmt: existing.issuedRmt,
      returnedRmt: existing.returnedRmt,
      totalCost: existing.totalCost + item.valueIn,
      totalSqMtrIn: existing.totalSqMtrIn + item.sqMtrIn,
    );
  }

  for (final item in issues) {
    final key = '${item.material.toUpperCase().trim()}_${item.webSizeMm.toInt()}';
    final existing = map[key] ?? (inRmt: 0.0, issuedRmt: 0.0, returnedRmt: 0.0, totalCost: 0.0, totalSqMtrIn: 0.0);
    map[key] = (
      inRmt: existing.inRmt,
      issuedRmt: existing.issuedRmt + item.rmtIssued,
      returnedRmt: existing.returnedRmt,
      totalCost: existing.totalCost,
      totalSqMtrIn: existing.totalSqMtrIn,
    );
  }

  for (final item in returns) {
    final key = '${item.material.toUpperCase().trim()}_${item.webSizeMm.toInt()}';
    final existing = map[key] ?? (inRmt: 0.0, issuedRmt: 0.0, returnedRmt: 0.0, totalCost: 0.0, totalSqMtrIn: 0.0);
    map[key] = (
      inRmt: existing.inRmt,
      issuedRmt: existing.issuedRmt,
      returnedRmt: existing.returnedRmt + item.rmtReturned,
      totalCost: existing.totalCost,
      totalSqMtrIn: existing.totalSqMtrIn,
    );
  }

  final List<RmStockBalanceModel> result = [];
  map.forEach((key, val) {
    final parts = key.split('_');
    final matName = parts.first;
    final webSize = double.tryParse(parts.last) ?? 100.0;
    final avgRate = val.totalSqMtrIn > 0 ? val.totalCost / val.totalSqMtrIn : 29.0;

    result.add(RmStockBalanceModel(
      material: matName,
      gsmMicron: 80.0,
      webSizeMm: webSize,
      rmtIn: val.inRmt,
      rmtIssued: val.issuedRmt,
      rmtReturned: val.returnedRmt,
      avgRate: avgRate,
    ));
  });

  return result;
});
