import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_paths.dart';

class DemoDataSeeder {
  static Future<void> seedAll() async {
    final firestore = FirebaseFirestore.instance;

    // 1. Seed Customers
    final cust1 = firestore.collection(FirestorePaths.customers).doc('cust-cipla');
    await cust1.set({
      'plantId': DefaultPlant.id,
      'customerCode': 'CUST-CIPLA',
      'companyName': 'Cipla Pharmaceuticals Ltd',
      'gstNo': '27AAAAA0000A1Z5',
      'panNo': 'AAAAA0000A',
      'contactPerson': 'Rajesh Sharma (Procurement Head)',
      'contactPhone': '+91 98200 12345',
      'contactEmail': 'procurement@cipla.com',
      'billingAddress': 'Cipla House, Peninsula Business Park, Lower Parel, Mumbai 400013',
      'shippingAddress': 'Cipla Plant 2, Verna Industrial Estate, Goa 403722',
      'creditTermsDays': 45,
      'specialInstructions': 'Dust-free cleanroom packing mandatory. ISO Certificate tag on boxes.',
      'createdAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      'createdBy': 'demo_seeder',
    });

    final cust2 = firestore.collection(FirestorePaths.customers).doc('cust-sunpharma');
    await cust2.set({
      'plantId': DefaultPlant.id,
      'customerCode': 'CUST-SUNPHARMA',
      'companyName': 'Sun Pharma Laboratories Ltd',
      'gstNo': '27BBBBA1111B1Z2',
      'panNo': 'BBBBA1111B',
      'contactPerson': 'Anand Verma (Supply Chain Mgr)',
      'contactPhone': '+91 98211 67890',
      'contactEmail': 'scmapi@sunpharma.com',
      'billingAddress': 'Sun House, CTS No. 201 B/1, Goregaon East, Mumbai 400063',
      'shippingAddress': 'Sun Pharma Silvassa Plant, Dadra & Nagar Haveli 396230',
      'creditTermsDays': 60,
      'specialInstructions': 'UV varnish scratch test certificate required with dispatch challan.',
      'createdAt': DateTime.now().subtract(const Duration(days: 25)).toIso8601String(),
      'createdBy': 'demo_seeder',
    });

    // 2. Seed Product SKUs
    final prod1 = firestore.collection(FirestorePaths.products).doc('prod-paracetamol');
    await prod1.set({
      'plantId': DefaultPlant.id,
      'internalSkuCode': 'SKU-CIPLA-PARA-500',
      'productName': 'Paracetamol 500mg 100ml Syrup Bottle Flexo Label',
      'customerId': 'cust-cipla',
      'customerName': 'Cipla Pharmaceuticals Ltd',
      'customerSkuCode': 'CIP-PARA-LABEL-V2',
      'labelSpec': {
        'shape': 'Rectangle',
        'widthMm': 65.0,
        'heightLengthMm': 120.0,
        'cornerRadiusMm': 2.0,
        'substrateMaterial': 'Self-Adhesive High Gloss Chromo Paper 80 GSM',
        'linerType': 'Glassine Liner 62 GSM',
        'adhesiveType': 'Permanent Acrylic Adhesive',
        'coreSizeMm': 76.0,
        'windingDirection': 'Head First (Face Out)',
        'maxRollDiameterMm': 250.0,
        'labelsPerRoll': 1000,
      },
      'printSpec': {
        'printMethod': 'Flexographic Printing Press',
        'colorCount': 6,
        'colorsList': ['Process Cyan', 'Process Magenta', 'Process Yellow', 'Process Black', 'Pantone 286 C Blue', 'UV Gloss Varnish'],
        'varnishLaminationType': 'Full Surface UV Gloss Varnish',
        'inkType': 'Low-Migration UV Inks',
      },
      'machineSpec': {
        'targetMachineId': 'm-lombardy-01',
        'targetMachineName': 'Lombardy 8-Color Flexo Press (~430mm)',
        'cylinderCircumferenceMm': 355.6,
        'teethCountZ': 88,
        'acrossUps': 4,
        'aroundUps': 2,
        'totalUpsPerImpression': 8,
        'repeatLengthMm': 177.8,
        'dieId': 'die-rect-65x120',
        'plateId': 'plate-cipla-para-v2',
      },
      'processRoute': ['Pre-press Proofing', 'Flexo Printing', 'Inline Die-Cutting', 'Offline Slitting & Inspection', 'Cleanroom Packing'],
      'currentApprovedArtworkId': 'art-v1',
      'isActive': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
      'createdBy': 'demo_seeder',
    });

    // 3. Seed Job Cards
    final jc1 = firestore.collection(FirestorePaths.jobCards).doc('jc-2026-101');
    await jc1.set({
      'plantId': DefaultPlant.id,
      'jobCardNo': 'JC-2026-101',
      'orderId': 'po-cipla-99',
      'poNumber': 'PO-CIPLA-2026-9901',
      'customerId': 'cust-cipla',
      'customerName': 'Cipla Pharmaceuticals Ltd',
      'productId': 'prod-paracetamol',
      'internalSkuCode': 'SKU-CIPLA-PARA-500',
      'productName': 'Paracetamol 500mg 100ml Syrup Bottle Flexo Label',
      'targetOrderQty': 50000.0,
      'plannedProductionQty': 52500.0,
      'processRoute': ['Pre-press Proofing', 'Flexo Printing', 'Inline Die-Cutting', 'Offline Slitting & Inspection'],
      'status': 'InProduction',
      'createdAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      'createdBy': 'planner',
    });

    // 4. Seed Machines
    final m1 = firestore.collection(FirestorePaths.machines).doc('m-lombardy-01');
    await m1.set({
      'plantId': DefaultPlant.id,
      'machineCode': 'LOMBARDY-01',
      'machineName': 'Lombardy 8-Color Flexo Press',
      'category': 'Printing Press',
      'maxWebWidthMm': 430.0,
      'maxSpeedMetersPerMin': 150.0,
      'colorStations': 8,
      'status': 'Active',
    });

    // 5. Seed Production Schedule
    final sched1 = firestore.collection(FirestorePaths.productionSchedules).doc('sched-101');
    await sched1.set({
      'plantId': DefaultPlant.id,
      'jobCardId': 'jc-2026-101',
      'jobCardNo': 'JC-2026-101',
      'customerName': 'Cipla Pharmaceuticals Ltd',
      'productName': 'Paracetamol 500mg 100ml Syrup Bottle Flexo Label',
      'internalSkuCode': 'SKU-CIPLA-PARA-500',
      'machineId': 'm-lombardy-01',
      'machineName': 'Lombardy 8-Color Flexo Press',
      'scheduledDate': DateTime.now().toIso8601String(),
      'shift': 'Day',
      'queuePriority': 1,
      'targetQuantity': 50000.0,
      'plannedRmt': 1500.0,
      'status': 'Running',
      'createdAt': DateTime.now().toIso8601String(),
      'createdBy': 'planner',
    });

    // 6. Seed Stores Roll Inventory
    final roll1 = firestore.collection(FirestorePaths.rolls).doc('roll-chr-220-01');
    await roll1.set({
      'plantId': DefaultPlant.id,
      'rollCode': 'ROLL-CHR-220-001',
      'substrateMaterial': 'Self-Adhesive High Gloss Chromo Paper',
      'widthMm': 220.0,
      'originalRmt': 2000.0,
      'availableRmt': 1450.0,
      'vendorName': 'Avery Dennison India Ltd',
      'vendorBatchLot': 'LOT-AVD-2026-88',
      'receiptDate': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      'storageLocation': 'Rack A-02',
      'qcStatus': 'Approved',
      'status': 'Issued',
      'createdAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      'createdBy': 'stores',
    });

    // 7. Seed Shade Card (Permanent Reference Available)
    final shade1 = firestore.collection(FirestorePaths.shadeCards).doc('sc-cipla-01');
    await shade1.set({
      'plantId': DefaultPlant.id,
      'shadeCardCode': 'SC-CIPLA-PARA-STD',
      'customerId': 'cust-cipla',
      'customerName': 'Cipla Pharmaceuticals Ltd',
      'productId': 'prod-paracetamol',
      'internalSkuCode': 'SKU-CIPLA-PARA-500',
      'productName': 'Paracetamol 500mg 100ml Syrup Bottle Flexo Label',
      'jobCardId': 'jc-2026-101',
      'jobCardNo': 'JC-2026-101',
      'artworkVersionId': 'art-v1',
      'artworkVersionLabel': 'v1',
      'dateCreated': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      'productionBatchRunNo': 'BATCH-2026-01',
      'standardShadeStoragePath': 'shades/SC-CIPLA-PARA-STD_standard.jpg',
      'status': 'Approved',
      'approvedBy': 'Customer Quality Rep (Email Ref Dated 15-07-2026)',
      'approvalDate': DateTime.now().subtract(const Duration(days: 8)).toIso8601String(),
      'approvalEvidenceRef': 'EMAIL-APPROV-CIPLA-9901.pdf',
      'isPermanentReference': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      'createdBy': 'qc',
    });

    // 8. Seed QC Gate Record
    final qc1 = firestore.collection(FirestorePaths.qcControlRecords).doc('qc-gate2-101');
    await qc1.set({
      'plantId': DefaultPlant.id,
      'gateType': 'QC_Gate_2_StartUp',
      'recordCode': 'QC2-JC101-01',
      'jobCardId': 'jc-2026-101',
      'jobCardNo': 'JC-2026-101',
      'customerName': 'Cipla Pharmaceuticals Ltd',
      'productName': 'Paracetamol 500mg 100ml Syrup Bottle Flexo Label',
      'inspectionDate': DateTime.now().toIso8601String(),
      'inspectorName': 'Sunil Patil (Sr. QC Engineer)',
      'checklistResults': {
        'Text Matter & Spelling Correctness': true,
        'Artwork Content Match against Approved Proof': true,
        'Color Match against Approved Shade Card': true,
        'Rub Test & Ink Adhesion Check': true,
        'Web Tension & Die Registration': true,
        'Label Dimensions & Cutting Accuracy': true,
      },
      'disposition': 'Passed',
      'remarks': 'Start-up print sample verified against Approved Shade Reference SC-CIPLA-PARA-STD. Text matter 100% OK.',
      'isoDocNo': 'PGPL/QC/F-02',
      'isoRevisionNo': '01',
      'createdAt': DateTime.now().toIso8601String(),
      'createdBy': 'qc',
    });
  }
}
