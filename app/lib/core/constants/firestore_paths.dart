/// Central place for Firestore collection paths so no screen ever hardcodes
/// a collection name inline (Doc/Flexora-Master-Requirements-v1.2.md, Section 0A —
/// "no screen wired directly to a random Firestore collection").
class FirestorePaths {
  static const String orders = 'orders';
  static String orderLineItems(String orderId) => 'orders/$orderId/line_items';

  static const String customers = 'customers';
  static const String products = 'products';
  static String productArtworks(String productId) => 'products/$productId/artworks';

  static const String jobCards = 'job_cards';
  static const String masterCards = 'master_cards';
  static const String plates = 'plates';
  static const String dies = 'dies';

  static const String machines = 'machines';
  static const String productionSchedules = 'production_schedules';
  static const String productionLogs = 'production_logs';
  static const String shadeCards = 'shade_cards';

  static const String rolls = 'rolls';
  static const String materialTransactions = 'material_transactions';
  static const String jobMaterialReconciliations = 'job_material_reconciliations';

  static const String qcControlRecords = 'qc_control_records';
  static const String isoDocuments = 'iso_documents';

  static const String finishedRolls = 'finished_rolls';
  static const String packingLists = 'packing_lists';
  static const String dispatchChallans = 'dispatch_challans';

  static const String auditLogs = 'audit_logs';
  static const String plants = 'plants';
}

/// Placeholder until the Plant/Multi-plant master module is designed.
/// Single plant in production today (Doc Section 1) — kept as a named constant,
/// not scattered string literals, so switching to a real Plant Master later is a
/// one-place change.
class DefaultPlant {
  static const String id = 'pgpl-vasai';
}

