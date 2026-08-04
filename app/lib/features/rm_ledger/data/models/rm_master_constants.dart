/// Master Raw Material Substrates, Suppliers, and GSM/Micron lists
/// Extracted directly from `Stock Managemaent (4).xlsx` -> `Masters` tab.
class RmMasterConstants {
  static final List<String> materials = [
    'Chromo',
    'PP WHITE',
    'SILVER PAPER',
    'C-MIRRORCOAT',
    'PP CLEAR',
    'PE WHITE',
    'PE CLEAR',
    'P G BACK',
    'IML Blow Mould',
    'OPAQUE MATTE',
    'PET MATT',
    'PP WHITE MATT',
    'PVC Cast Film',
    'SGL Hologram',
    'Self Adhesive Film',
    'Void',
    'clear on clear',
    'ONLY CHROMO ( GLOSS PAPER ) RAHAT HD',
    'ONLY CHROMO ( THIN )',
    'Only ART Paper Without Gumming',
    'DOUBLE SILICON (P G BACK)',
    'RAFLACOAT NXT (CHROMO PAPER)',
    'Special SDV Grade Security Film',
    'U- CHROMO 80/60 WGL (HM)',
    'Paper - Chromo TRP1',
    'Paper- AMA5050 ( PIGGYBACK)',
    'Paper- ISF- IOF 105 Blow Mould',
    'CHROMO ( SHINE )',
    'Blochum Blue Paper Sheet',
    'Tape',
    'silicon sheet',
  ];

  static final List<String> suppliers = [
    'Avery',
    'Surya',
    'Allied',
    'Papier',
    'Raflatech',
    'Zalak',
    'V - TECH',
    'Tackify',
    'UPM',
    'MPS Industries',
    'Arjobex Polyart',
    'Technova',
    'DEE DEE LABEL',
    'Manish Pack',
    'Mitsubishi Chemical India Private Limited',
    'Mudra Arts',
    'Presen Bontek Private Limited',
    'Sonafine Corporation Pvt Ltd',
    'Stick Tapes',
    'Verifys',
    'Yupo',
  ];

  static void addSupplier(String supplierName) {
    final s = supplierName.trim();
    if (s.isNotEmpty && !suppliers.contains(s)) {
      suppliers.insert(0, s);
    }
  }

  static void addMaterial(String materialName) {
    final m = materialName.trim();
    if (m.isNotEmpty && !materials.contains(m)) {
      materials.insert(0, m);
    }
  }

  static const List<double> gsmMicrons = [
    50.0,
    60.0,
    70.0,
    80.0,
    105.0,
    120.0,
    125.0,
    150.0,
    230.0,
    250.0,
  ];

  static const List<double> commonWebSizesMm = [
    100.0,
    125.0,
    140.0,
    150.0,
    160.0,
    170.0,
    180.0,
    190.0,
    195.0,
    210.0,
    220.0,
    250.0,
    280.0,
    290.0,
    300.0,
    330.0,
  ];
}
