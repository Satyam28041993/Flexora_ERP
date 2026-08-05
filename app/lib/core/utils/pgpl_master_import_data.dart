// GENERATED FROM PGPL SOURCE WORKBOOKS - DO NOT HAND-EDIT.
// Regenerate with scripts/gen_master_data.py after the workbooks change.
//
//   Stock     : '1. Closing Paper Stock JULY  2026 - Copy - Copy.xlsx'
//               sheet 'JULY 2026 (3)', column EF 'Closing Stock in RMT'.
//               That column is a hardcoded physical stock-take, not a
//               roll-forward, and is carried as the 01-Aug-2026 opening.
//   Customers : 'New Order Detail and Status Tracking 2026-2027.xlsx'
//   Suppliers : COMPANY NAME column of the stock workbook.
//
// Names only - GST / phone / address are deliberately left blank for the
// user to fill in; nothing here is invented.

/// One opening-stock line exactly as counted in the source workbook.
class OpeningStockRow {
  const OpeningStockRow(
    this.supplier,
    this.material,
    this.gsmMicron,
    this.productCode,
    this.webSizeMm,
    this.rmt,
    this.gsmLabel,
  );

  final String supplier;
  final String material;
  final double gsmMicron;
  final String productCode;
  final double webSizeMm;
  final double rmt;

  /// Raw GSM text from the sheet (e.g. '80/60'), kept verbatim so the
  /// parsed numeric value can always be traced back to the source.
  final String gsmLabel;
}

class PgplMasterImportData {
  PgplMasterImportData._();

  /// The date the physical stock count represents.
  static final DateTime openingStockDate = DateTime(2026, 8, 1);

  static const List<String> supplierNames = [
    'ALLIED',
    'ARJOBEX POLYART',
    'AVERY',
    'MANGAL ENTERPRISES',
    'MANISH PACK',
    'MITSUBISHI',
    'MUDRA',
    'NARA INFINITY PVT LTD',
    'PRESEN BONTEK PVT LTD',
    'SURYA',
    'UPM',
    'V - TECH',
    'ZALAK',
  ];

  static const List<String> customerNames = [
    'ANU IND',
    'ARIES',
    'ARMOUR ME',
    'BENCHMARK',
    'BIRLA',
    'BLOSSOM',
    'COLOR PACK',
    'DAILY PHARMA',
    'GLOBAL CROP CARE',
    'HAYAT PHARMA',
    'HERBAL HILLS',
    'IGLOO',
    'KRISHNA ART',
    'METRO PACKAGING',
    'MICRO PACK',
    'NAVLAI PRINT',
    'NIMISH',
    'OCTAGREEN',
    'OXITEC',
    'PARIMAN',
    'PREGNA',
    'PROPIX',
    'PURE IMP',
    'RALLIS',
    'SAI DHUDH',
    'SEEJAR PHARMA',
    'SHREE PRINT',
    'SHUBHASHREE ARTS',
    'TEMPLE',
    'TEMPLE PKG',
    'TRICIL',
    'VIMONI',
    'WYNK',
  ];

  static const List<OpeningStockRow> openingStock = [
    OpeningStockRow('AVERY', 'CHROMO GUMMING PAPER', 80.0, 'LMBO123', 125.0, 12730.0, '80/60'),
    OpeningStockRow('AVERY', 'CHROMO GUMMING PAPER', 80.0, 'LMBO123', 150.0, 8000.0, '80/60'),
    OpeningStockRow('AVERY', 'CHROMO GUMMING PAPER', 80.0, 'LMBO123', 160.0, 6000.0, '80/60'),
    OpeningStockRow('AVERY', 'PP WHITE', 80.0, 'AM09070', 167.0, 200.0, '80/60'),
    OpeningStockRow('AVERY', 'CHROMO GUMMING PAPER', 80.0, 'LMBO123', 170.0, 8030.0, '80/60'),
    OpeningStockRow('AVERY', 'CHROMO GUMMING PAPER', 80.0, 'LMBO123', 180.0, 3950.0, '80/60'),
    OpeningStockRow('AVERY', 'CHROMO GUMMING PAPER', 80.0, 'LMBO123', 210.0, 7200.0, '80/60'),
    OpeningStockRow('AVERY', 'CHROMO GUMMING PAPER', 80.0, '', 250.0, 9300.0, '80/60'),
    OpeningStockRow('AVERY', 'CHROMO GUMMING PAPER', 80.0, 'LMBO123', 280.0, 5700.0, '80/60'),
    OpeningStockRow('AVERY', 'CHROMO GUMMING PAPER', 80.0, 'LMBO123', 290.0, 24600.0, '80/60'),
    OpeningStockRow('AVERY', 'CHROMO GUMMING PAPER', 80.0, 'LMBO123', 300.0, 2000.0, '80/60'),
    OpeningStockRow('AVERY', 'CHROMO GUMMING PAPER', 80.0, 'LMBO123', 310.0, 6200.0, '80/60'),
    OpeningStockRow('AVERY', 'CHROMO GUMMING PAPER', 80.0, 'LMBO123', 320.0, 9900.0, '80/60'),
    OpeningStockRow('AVERY', 'CHROMO GUMMING PAPER', 80.0, 'LMBO123', 330.0, 6000.0, '80/60'),
    OpeningStockRow('AVERY', 'CHROMO GUMMING PAPER', 80.0, 'LMBO123', 395.0, 10800.0, '80/60'),
    OpeningStockRow('AVERY', 'MIRRORCOAT', 80.0, 'AM13060', 290.0, 4000.0, '80/60'),
    OpeningStockRow('AVERY', 'PP WHITE', 0.0, '', 100.0, 37000.0, ''),
    OpeningStockRow('AVERY', 'PP WHITE', 0.0, 'AMF1601', 190.0, 22000.0, ''),
    OpeningStockRow('AVERY', 'PP CLEAR', 0.0, '', 100.0, 960.0, ''),
    OpeningStockRow('AVERY', 'DOUBLE SILICON (P G BACK)', 0.0, '', 200.0, 2200.0, ''),
    OpeningStockRow('ZALAK', 'CHROMO', 0.0, '', 195.0, 180.0, ''),
    OpeningStockRow('SURYA', 'ONLY ART PAPER 120 GSM', 0.0, '120 GSM', 115.0, 1250.0, ''),
    OpeningStockRow('SURYA', 'SILVER PAPER', 0.0, '', 125.0, 1000.0, ''),
    OpeningStockRow('SURYA', 'SILVER PAPER', 0.0, '', 130.0, 300.0, ''),
    OpeningStockRow('SURYA', 'SILVER PAPER', 0.0, '', 140.0, 1800.0, ''),
    OpeningStockRow('SURYA', 'SILVER PAPER', 0.0, '', 167.0, 4310.0, ''),
    OpeningStockRow('SURYA', 'SILVER PAPER', 0.0, '', 170.0, 400.0, ''),
    OpeningStockRow('SURYA', 'SILVER PAPER', 0.0, '', 250.0, 300.0, ''),
    OpeningStockRow('SURYA', 'CHROMO GUMMING PAPER', 0.0, '', 140.0, 4560.0, ''),
    OpeningStockRow('SURYA', 'CHROMO GUMMING PAPER', 0.0, '', 160.0, 6770.0, ''),
    OpeningStockRow('SURYA', 'CHROMO GUMMING PAPER', 0.0, '', 185.0, 5890.0, ''),
    OpeningStockRow('SURYA', 'CHROMO GUMMING PAPER', 0.0, '', 200.0, 6600.0, ''),
    OpeningStockRow('SURYA', 'CHROMO GUMMING PAPER', 0.0, '', 220.0, 9150.0, ''),
    OpeningStockRow('SURYA', 'CHROMO GUMMING PAPER', 0.0, '', 230.0, 8390.0, ''),
    OpeningStockRow('SURYA', 'ONLY CHROMO ( THIN )', 0.0, '', 245.0, 2070.0, ''),
    OpeningStockRow('SURYA', 'CHROMO GUMMING PAPER', 0.0, '', 260.0, 4700.0, ''),
    OpeningStockRow('SURYA', 'CHROMO GUMMING PAPER', 0.0, '', 305.0, 450.0, ''),
    OpeningStockRow('SURYA', 'PP CLEAR ( REMOVABLE )', 0.0, '', 510.0, 1520.0, ''),
    OpeningStockRow('SURYA', 'ONLY CHROMO 120 GSM', 120.0, '', 195.0, 1600.0, '120 GSM'),
    OpeningStockRow('SURYA', 'ONLY CHROMO 120 GSM', 120.0, '', 340.0, 550.0, '120 GSM'),
    OpeningStockRow('SURYA', 'ONLY CHROMO 120 GSM', 120.0, '', 130.0, 2000.0, '120 GSM'),
    OpeningStockRow('SURYA', 'ONLY CHROMO 80 GSM', 80.0, '', 340.0, 2000.0, '80 GSM'),
    OpeningStockRow('SURYA', 'ONLY CHROMO 120 GSM', 120.0, '', 230.0, 235.0, '120 GSM'),
    OpeningStockRow('SURYA', 'CHROMO SHEETS', 0.0, '', 0.0, 125.0, ''),
    OpeningStockRow('SURYA', 'PP WHITE', 0.0, '', 125.0, 10500.0, ''),
    OpeningStockRow('SURYA', 'PP CLEAR', 0.0, '', 125.0, 13500.0, ''),
    OpeningStockRow('SURYA', 'PP CLEAR REMOVABLE', 0.0, '', 125.0, 810.0, ''),
    OpeningStockRow('SURYA', 'CHROMO SPECIAL VSP WHITE', 0.0, '', 126.0, 2800.0, ''),
    OpeningStockRow('SURYA', 'PP CLEAR', 0.0, '', 140.0, 1000.0, ''),
    OpeningStockRow('SURYA', 'PP CLEAR', 0.0, '', 143.0, 5750.0, ''),
    OpeningStockRow('SURYA', 'PP CLEAR', 0.0, '', 180.0, 3850.0, ''),
    OpeningStockRow('SURYA', 'PP CLEAR', 0.0, '', 270.0, 940.0, ''),
    OpeningStockRow('ALLIED', 'PP WHITE', 0.0, '', 110.0, 7300.0, ''),
    OpeningStockRow('ALLIED', 'PP WHITE', 0.0, '', 255.0, 1000.0, ''),
    OpeningStockRow('ALLIED', 'PP WHITE', 0.0, '', 230.0, 2000.0, ''),
    OpeningStockRow('ALLIED', 'PP CLEAR', 0.0, '', 91.0, 1100.0, ''),
    OpeningStockRow('ALLIED', 'PP CLEAR', 0.0, '', 90.0, 46060.0, ''),
    OpeningStockRow('ALLIED', 'PP WHITE', 0.0, '', 170.0, 15400.0, ''),
    OpeningStockRow('ALLIED', 'PP CLEAR', 0.0, '', 180.0, 21520.0, ''),
    OpeningStockRow('ALLIED', 'PP CLEAR', 0.0, '', 115.0, 300.0, ''),
    OpeningStockRow('ALLIED', 'PP CLEAR', 0.0, '', 280.0, 1670.0, ''),
    OpeningStockRow('ALLIED', 'SILVER PAPER', 0.0, '', 245.0, 600.0, ''),
    OpeningStockRow('ALLIED', 'CHROMO PAPER', 0.0, '', 210.0, 800.0, ''),
    OpeningStockRow('ALLIED', 'PP MATT', 0.0, '', 172.0, 400.0, ''),
    OpeningStockRow('MUDRA', 'SILVER PAPER', 0.0, '', 280.0, 500.0, ''),
    OpeningStockRow('MUDRA', 'SILVER PAPER', 0.0, '', 300.0, 200.0, ''),
    OpeningStockRow('V - TECH', 'PP CLEAR', 0.0, '', 125.0, 11300.0, ''),
    OpeningStockRow('V - TECH', 'PP SILVER', 0.0, '', 125.0, 4890.0, ''),
    OpeningStockRow('V - TECH', 'PP SILVER', 0.0, '', 165.0, 600.0, ''),
    OpeningStockRow('V - TECH', 'PP WHITE', 0.0, '', 135.0, 650.0, ''),
    OpeningStockRow('MANISH PACK', 'PVC', 0.0, '', 240.0, 6420.0, ''),
    OpeningStockRow('MANGAL ENTERPRISES', 'PVC', 0.0, '', 195.0, 900.0, ''),
    OpeningStockRow('UPM', 'RAFLACOAT  NXT (CHROMO PAPER)', 0.0, '', 160.0, 5600.0, ''),
    OpeningStockRow('UPM', 'CLEAR ON CLEAR', 0.0, '', 335.0, 400.0, ''),
    OpeningStockRow('UPM', 'CLEAR ON CLEAR', 0.0, '', 215.0, 2000.0, '(335M  PAPER WAS CUT 215MM)'),
    OpeningStockRow('UPM', 'MIRRORCOAT', 0.0, '', 290.0, 4600.0, ''),
    OpeningStockRow('MITSUBISHI', 'YUPO IML ( ISF 105 )', 0.0, '', 205.0, 580.0, ''),
    OpeningStockRow('MITSUBISHI', 'YUPO IML ( ISF 105 )', 0.0, '', 210.0, 600.0, ''),
    OpeningStockRow('MITSUBISHI', 'YUPO IML ( ISF 105 )', 0.0, '', 140.0, 6000.0, ''),
    OpeningStockRow('MITSUBISHI', 'YUPO IML ( ISF 105 )', 0.0, '', 130.0, 5000.0, ''),
    OpeningStockRow('MITSUBISHI', 'YUPO IML ( ISF 105 )', 0.0, '', 190.0, 3300.0, ''),
    OpeningStockRow('ARJOBEX POLYART', 'IML', 0.0, '', 380.0, 1500.0, ''),
    OpeningStockRow('NARA INFINITY PVT LTD', 'DURA 110', 0.0, '', 240.0, 200.0, ''),
    OpeningStockRow('PRESEN BONTEK PVT LTD', 'SPECIAL SDV GRADE SECURITY FILM', 0.0, '', 300.0, 1800.0, ''),
  ];
}
