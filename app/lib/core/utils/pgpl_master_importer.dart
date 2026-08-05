import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_paths.dart';
import 'pgpl_master_import_data.dart';

/// Result of one import run, so the UI can report exactly what happened.
class ImportResult {
  ImportResult(this.label);

  final String label;
  int created = 0;
  int skipped = 0;
  final List<String> errors = [];

  @override
  String toString() =>
      '$label: $created created, $skipped already present'
      '${errors.isEmpty ? '' : ', ${errors.length} failed'}';
}

/// One-time importer for the PGPL master data held in the source workbooks.
///
/// Every method is **idempotent**: an entity that already exists is skipped,
/// never duplicated, so a re-run after a partial failure is safe.
///
/// Opening stock is written as `rm_stock_ins` transactions rather than as a
/// balance, per the project rule that stock quantities are never set directly
/// — every movement is a logged transaction carrying a reason and reference.
class PgplMasterImporter {
  PgplMasterImporter._();

  static const String _importedBy = 'excel-import';

  /// Marks the rows this importer created, so they can be identified later.
  static const String _openingStockRef = 'OPENING-STOCK-01-AUG-2026';

  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  // -------------------------------------------------------------------
  // Suppliers
  // -------------------------------------------------------------------

  static Future<ImportResult> importSuppliers() async {
    final result = ImportResult('Suppliers');
    final col = _db.collection(FirestorePaths.suppliers);

    final existing = await col.where('plantId', isEqualTo: DefaultPlant.id).get();
    final have = existing.docs
        .map((d) => (d.data()['companyName'] as String? ?? '').toUpperCase())
        .toSet();

    var seq = existing.docs.length;
    for (final name in PgplMasterImportData.supplierNames) {
      if (have.contains(name.toUpperCase())) {
        result.skipped++;
        continue;
      }
      seq++;
      try {
        await col.add({
          'plantId': DefaultPlant.id,
          'supplierCode': 'SUP-${seq.toString().padLeft(3, '0')}',
          'companyName': name,
          // Commercial details intentionally blank — user fills these in.
          'materialCategory': '',
          'contactPerson': '',
          'phone': '',
          'email': '',
          'address': '',
          'gstNo': '',
          'panNo': '',
          'isoCertification': '',
          'status': 'Active',
          'createdAt': DateTime.now().toIso8601String(),
          'createdBy': _importedBy,
        });
        result.created++;
        have.add(name.toUpperCase());
      } catch (e) {
        result.errors.add('$name: $e');
      }
    }
    return result;
  }

  // -------------------------------------------------------------------
  // Customers
  // -------------------------------------------------------------------

  static Future<ImportResult> importCustomers() async {
    final result = ImportResult('Customers');
    final col = _db.collection(FirestorePaths.customers);

    final existing = await col.where('plantId', isEqualTo: DefaultPlant.id).get();
    final have = existing.docs
        .map((d) => (d.data()['companyName'] as String? ?? '').toUpperCase())
        .toSet();

    var seq = existing.docs.length;
    for (final name in PgplMasterImportData.customerNames) {
      if (have.contains(name.toUpperCase())) {
        result.skipped++;
        continue;
      }
      seq++;
      try {
        await col.add({
          'plantId': DefaultPlant.id,
          'customerCode': 'CUST-${seq.toString().padLeft(3, '0')}',
          'companyName': name,
          // Blank contact/address — CustomerModel.fromMap tolerates these and
          // the user completes them from the Customers screen.
          'primaryContact': {
            'name': '',
            'designation': '',
            'phone': '',
            'email': '',
          },
          'billingAddress': {
            'addressLine1': '',
            'city': '',
            'state': '',
            'pincode': '',
            'country': 'India',
          },
          'shippingAddresses': <Map<String, dynamic>>[],
          'additionalContacts': <Map<String, dynamic>>[],
          'status': 'active',
          'createdAt': DateTime.now().toIso8601String(),
          'createdBy': _importedBy,
        });
        result.created++;
        have.add(name.toUpperCase());
      } catch (e) {
        result.errors.add('$name: $e');
      }
    }
    return result;
  }

  // -------------------------------------------------------------------
  // Opening stock
  // -------------------------------------------------------------------

  /// Writes each counted stock line as an opening Stock-In transaction.
  ///
  /// Rate is left at 0 — the workbook records quantities only, and a purchase
  /// rate is never invented. Stock value stays 0 until rates are entered.
  static Future<ImportResult> importOpeningStock() async {
    final result = ImportResult('Opening stock');
    final col = _db.collection(FirestorePaths.rmStockIns);

    // Re-running must not double the stock, so skip anything already carrying
    // this import's reference.
    final existing = await col
        .where('plantId', isEqualTo: DefaultPlant.id)
        .where('reference', isEqualTo: _openingStockRef)
        .get();
    if (existing.docs.isNotEmpty) {
      result.skipped = existing.docs.length;
      return result;
    }

    final date = PgplMasterImportData.openingStockDate.toIso8601String();
    final now = DateTime.now().toIso8601String();

    // Firestore caps a batch at 500 writes; 84 rows fit, but chunk anyway so
    // this keeps working if the workbook grows.
    const chunkSize = 400;
    final rows = PgplMasterImportData.openingStock;

    for (var start = 0; start < rows.length; start += chunkSize) {
      final end = (start + chunkSize).clamp(0, rows.length);
      final batch = _db.batch();
      for (final row in rows.sublist(start, end)) {
        batch.set(col.doc(), {
          'plantId': DefaultPlant.id,
          'date': date,
          'supplier': row.supplier,
          'material': row.material,
          'productCode': row.productCode,
          'gsmMicron': row.gsmMicron,
          'webSizeMm': row.webSizeMm,
          'rmtIn': row.rmt,
          'ratePerSqMtr': 0.0,
          'reference': _openingStockRef,
          'remarks': 'Opening stock as physically counted on '
              '01-Aug-2026 (source: Closing Paper Stock JULY 2026, '
              'sheet "JULY 2026 (3)"). GSM as written: "${row.gsmLabel}".',
          'createdAt': now,
          'createdBy': _importedBy,
        });
      }
      try {
        await batch.commit();
        result.created += end - start;
      } catch (e) {
        result.errors.add('rows $start-$end: $e');
      }
    }
    return result;
  }

  /// Removes only the rows this importer created, so a bad run can be undone.
  static Future<ImportResult> deleteImportedOpeningStock() async {
    final result = ImportResult('Opening stock removed');
    final snap = await _db
        .collection(FirestorePaths.rmStockIns)
        .where('plantId', isEqualTo: DefaultPlant.id)
        .where('reference', isEqualTo: _openingStockRef)
        .get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
      result.created++;
    }
    return result;
  }

  static Future<List<ImportResult>> importAll() async {
    return [
      await importSuppliers(),
      await importCustomers(),
      await importOpeningStock(),
    ];
  }
}
