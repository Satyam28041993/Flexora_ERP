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
      'primaryContact': {
        'name': 'Rajesh Sharma',
        'designation': 'Procurement Head',
        'phone': '+91 98200 12345',
        'email': 'procurement@cipla.com',
      },
      'billingAddress': {
        'addressLine1': 'Cipla House, Peninsula Business Park',
        'addressLine2': 'Lower Parel',
        'city': 'Mumbai',
        'state': 'Maharashtra',
        'pincode': '400013',
        'country': 'India',
      },
      'shippingAddresses': [
        {
          'addressLine1': 'Cipla Plant 2',
          'addressLine2': 'Verna Industrial Estate',
          'city': 'Verna',
          'state': 'Goa',
          'pincode': '403722',
          'country': 'India',
        }
      ],
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
      'primaryContact': {
        'name': 'Anand Verma',
        'designation': 'Supply Chain Manager',
        'phone': '+91 98211 67890',
        'email': 'scmapi@sunpharma.com',
      },
      'billingAddress': {
        'addressLine1': 'Sun House, CTS No. 201 B/1',
        'addressLine2': 'Goregaon East',
        'city': 'Mumbai',
        'state': 'Maharashtra',
        'pincode': '400063',
        'country': 'India',
      },
      'shippingAddresses': [
        {
          'addressLine1': 'Sun Pharma Silvassa Plant',
          'addressLine2': 'Industrial Zone',
          'city': 'Silvassa',
          'state': 'Dadra & Nagar Haveli',
          'pincode': '396230',
          'country': 'India',
        }
      ],
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
        'webUps': 4,
        'repeatUps': 2,
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

    // 9. Seed Production Orders (From New Order Detail and Status Tracking 2026-2027.xlsx)
    final pJobs = [
      {
        'id': 'pjob-06-021',
        'jobDocNo': '06/021',
        'clientName': 'TEMPLE',
        'poNumber': '5200030082',
        'materialDescription': 'LEAFLET OF ECL ZENATANE',
        'plantLocation': 'DAMAN',
        'totalReqQty': 600000.0,
        'gearTeethCount': 75,
        'ups': 4,
        'paperSizeMm': 190.0,
        'substrateMaterial': 'PP WHITE',
        'labelSize': '110 X 80',
        'pendingSubStatus': 'New Pending',
        'currentStage': 'Pending',
      },
      {
        'id': 'pjob-octa-approval',
        'jobDocNo': '07/040',
        'clientName': 'OCTAGREEN',
        'poNumber': 'PO-OCT-88',
        'materialDescription': 'ORIGINAL IMPERIAL WHISKY 750 ML EXPORT OVERSEAS FRONT',
        'plantLocation': 'GOVANDI',
        'totalReqQty': 12100.0,
        'gearTeethCount': 112,
        'ups': 5,
        'paperSizeMm': 112.0,
        'substrateMaterial': 'SILVER PAPER',
        'labelSize': '68 X 98',
        'pendingSubStatus': 'Under Approval',
        'currentStage': 'Pending',
      },
      {
        'id': 'pjob-propix-plate',
        'jobDocNo': '07/072',
        'clientName': 'PROPIX',
        'poNumber': 'PO-PRX-101',
        'materialDescription': 'MUDRANK CERTIFICATE',
        'plantLocation': 'MAIN',
        'totalReqQty': 3000.0,
        'gearTeethCount': 116,
        'ups': 1,
        'paperSizeMm': 230.0,
        'substrateMaterial': 'CHROMO',
        'labelSize': '356 X 216',
        'pendingSubStatus': 'Under Plate',
        'currentStage': 'Pending',
      },
      {
        'id': 'pjob-rallis-hold',
        'jobDocNo': '05/134',
        'clientName': 'RALLIS',
        'poNumber': 'PO PENDING',
        'materialDescription': 'RILON 10 GM',
        'plantLocation': 'AKL1',
        'totalReqQty': 50000.0,
        'gearTeethCount': 85,
        'ups': 10,
        'paperSizeMm': 170.0,
        'substrateMaterial': 'PP SILVER',
        'labelSize': '50 X 76',
        'pendingSubStatus': 'Hold Job',
        'currentStage': 'Pending',
      },
      {
        'id': 'pjob-nimish-sched',
        'jobDocNo': '07/048',
        'clientName': 'NIMISH',
        'poNumber': 'PO-NIM-2026',
        'materialDescription': 'IGLOO VODKA FRONT LABEL',
        'plantLocation': 'MAIN',
        'totalReqQty': 500.0,
        'gearTeethCount': 108,
        'ups': 3,
        'paperSizeMm': 215.0,
        'substrateMaterial': 'TEXTURE PAPER',
        'labelSize': '110 X 200',
        'pendingSubStatus': 'Approval Recd',
        'currentStage': 'Schedule',
      },
      {
        'id': 'pjob-rallis-postpress',
        'jobDocNo': '06/131',
        'clientName': 'RALLIS',
        'poNumber': '5400093969',
        'materialDescription': 'RALLIS QR CODE LABEL',
        'plantLocation': 'AKOLA',
        'totalReqQty': 100000.0,
        'gearTeethCount': 79,
        'ups': 3,
        'paperSizeMm': 100.0,
        'substrateMaterial': 'PP WHITE',
        'labelSize': '80 X 40',
        'pendingSubStatus': 'Approval Recd',
        'currentStage': 'Postpress',
      },
      {
        'id': 'pjob-birla-dispatch',
        'jobDocNo': '04/020',
        'clientName': 'BIRLA',
        'poNumber': 'PO/RM/015/26-27',
        'materialDescription': 'OPUS STICKER ( Series 6 )',
        'plantLocation': 'MAIN',
        'totalReqQty': 40000.0,
        'gearTeethCount': 72,
        'ups': 28,
        'paperSizeMm': 145.0,
        'substrateMaterial': 'CHROMO',
        'labelSize': '30 X 30',
        'pendingSubStatus': 'Approval Recd',
        'currentStage': 'Dispatched',
        'dispatchQty': 40000.0,
        'deliveryBy': 'Tempo Express',
        'billNo': 'INV-2026-04020',
      },
    ];

    for (final pj in pJobs) {
      final docRef = firestore.collection(FirestorePaths.productionOrders).doc(pj['id'] as String);
      await docRef.set({
        'plantId': DefaultPlant.id,
        'jobDocNo': pj['jobDocNo'],
        'clientName': pj['clientName'],
        'orderDate': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'poNumber': pj['poNumber'],
        'poDate': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'pendingPoQty': pj['totalReqQty'],
        'materialDescription': pj['materialDescription'],
        'plantLocation': pj['plantLocation'],
        'totalReqQty': pj['totalReqQty'],
        'gearTeethCount': pj['gearTeethCount'],
        'ups': pj['ups'],
        'paperSizeMm': pj['paperSizeMm'],
        'substrateMaterial': pj['substrateMaterial'],
        'labelSize': pj['labelSize'],
        'pendingSubStatus': pj['pendingSubStatus'],
        'paperStatus': 'Available',
        'currentStage': pj['currentStage'],
        'dispatchQty': pj['dispatchQty'] ?? 0.0,
        'balanceQty': 0.0,
        'deliveryBy': pj['deliveryBy'] ?? '',
        'billNo': pj['billNo'] ?? '',
        'createdAt': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'createdBy': 'demo_seeder',
      });
    }

    // 10. Seed RM Stock-In, Issues, and Returns (From Stock Managemaent (4).xlsx)
    final stockIns = [
      {'supplier': 'Avery', 'material': 'Chromo Paper', 'gsm': 80.0, 'web': 125.0, 'rmt': 13750.0, 'rate': 29.0},
      {'supplier': 'Avery', 'material': 'Chromo Paper', 'gsm': 80.0, 'web': 150.0, 'rmt': 6000.0, 'rate': 29.0},
      {'supplier': 'Surya', 'material': 'Silver Paper', 'gsm': 80.0, 'web': 280.0, 'rmt': 5260.0, 'rate': 41.0},
      {'supplier': 'Surya', 'material': 'Chromo Paper', 'gsm': 80.0, 'web': 160.0, 'rmt': 9000.0, 'rate': 28.5},
    ];

    for (final s in stockIns) {
      await firestore.collection(FirestorePaths.rmStockIns).add({
        'plantId': DefaultPlant.id,
        'date': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        'supplier': s['supplier'],
        'material': s['material'],
        'gsmMicron': s['gsm'],
        'webSizeMm': s['web'],
        'rmtIn': s['rmt'],
        'ratePerSqMtr': s['rate'],
        'createdAt': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        'createdBy': 'demo_seeder',
      });
    }

    final issues = [
      {'jobNo': '08/061', 'client': 'Aries Agro', 'material': 'Silver Paper', 'gsm': 80.0, 'web': 280.0, 'supplier': 'Surya', 'rmt': 4000.0, 'remarks': '2 Rolls Issued'},
      {'jobNo': '08/064', 'client': 'RALLIS', 'material': 'Chromo Paper', 'gsm': 80.0, 'web': 125.0, 'supplier': 'Avery', 'rmt': 1724.0, 'remarks': '1 Roll Issued'},
      {'jobNo': '08/067', 'client': 'RALLIS', 'material': 'Chromo Paper', 'gsm': 80.0, 'web': 330.0, 'supplier': 'Avery', 'rmt': 3150.0, 'remarks': 'Issued for Schedule'},
    ];

    for (final i in issues) {
      await firestore.collection(FirestorePaths.rmIssues).add({
        'plantId': DefaultPlant.id,
        'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'jobDocNo': i['jobNo'],
        'client': i['client'],
        'material': i['material'],
        'gsmMicron': i['gsm'],
        'webSizeMm': i['web'],
        'supplier': i['supplier'],
        'rmtIssued': i['rmt'],
        'remarks': i['remarks'],
        'createdAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'createdBy': 'demo_seeder',
      });
    }

    final returns = [
      {'jobNo': '08/061', 'client': 'Aries Agro', 'material': 'Silver Paper', 'gsm': 80.0, 'web': 280.0, 'supplier': 'Surya', 'rmt': 1000.0, 'remarks': '1 Roll Unused Returned'},
      {'jobNo': '08/064', 'client': 'RALLIS', 'material': 'Chromo Paper', 'gsm': 80.0, 'web': 125.0, 'supplier': 'Avery', 'rmt': 1015.0, 'remarks': 'Leftover Returned'},
    ];

    for (final r in returns) {
      await firestore.collection(FirestorePaths.rmReturns).add({
        'plantId': DefaultPlant.id,
        'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'jobDocNo': r['jobNo'],
        'client': r['client'],
        'material': r['material'],
        'gsmMicron': r['gsm'],
        'webSizeMm': r['web'],
        'supplier': r['supplier'],
        'rmtReturned': r['rmt'],
        'remarks': r['remarks'],
        'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'createdBy': 'demo_seeder',
      });
    }
  }

  /// Clears all dummy data (Customers, Products, PO Orders, Job Cards, Production Jobs, Ledgers)
  /// while PRESERVING RM Substrates Master & Vendor Master Constants!
  static Future<void> clearNonRmAndVendorData() async {
    final firestore = FirebaseFirestore.instance;

    final collectionsToClear = [
      FirestorePaths.customers,
      FirestorePaths.products,
      FirestorePaths.orders,
      FirestorePaths.jobCards,
      FirestorePaths.shadeCards,
      FirestorePaths.plates,
      FirestorePaths.dies,
      FirestorePaths.qcControlRecords,
      FirestorePaths.dispatchChallans,
      FirestorePaths.productionOrders,
      FirestorePaths.productionLogs,
      FirestorePaths.rmStockIns,
      FirestorePaths.rmIssues,
      FirestorePaths.rmReturns,
    ];

    for (final col in collectionsToClear) {
      final snapshot = await firestore.collection(col).get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }
  }
}
