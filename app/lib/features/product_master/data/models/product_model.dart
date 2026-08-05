import 'package:flutter/foundation.dart';

/// Label Specification model.
@immutable
class LabelSpecModel {
  final double widthMm;
  final double heightMm;
  final String shape; // Rectangle, Circle, Oval, Custom
  final String substrateMaterial; // Self-adhesive Chromo, PE, PP, PET, Thermal, etc.
  final String gsmMicron;
  final String adhesiveType; // Acrylic, Hotmelt, Permanent, Removable
  final String linerType; // Glassine, PET, Kraft
  final String faceMaterial;

  const LabelSpecModel({
    required this.widthMm,
    required this.heightMm,
    this.shape = 'Rectangle',
    required this.substrateMaterial,
    this.gsmMicron = '',
    this.adhesiveType = 'Permanent',
    this.linerType = 'Glassine',
    this.faceMaterial = '',
  });

  factory LabelSpecModel.fromMap(Map<String, dynamic> map) {
    return LabelSpecModel(
      widthMm: (map['widthMm'] as num?)?.toDouble() ?? 0.0,
      heightMm: (map['heightMm'] as num?)?.toDouble() ?? 0.0,
      shape: map['shape'] as String? ?? 'Rectangle',
      substrateMaterial: map['substrateMaterial'] as String? ?? '',
      gsmMicron: map['gsmMicron'] as String? ?? '',
      adhesiveType: map['adhesiveType'] as String? ?? 'Permanent',
      linerType: map['linerType'] as String? ?? 'Glassine',
      faceMaterial: map['faceMaterial'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'widthMm': widthMm,
      'heightMm': heightMm,
      'shape': shape,
      'substrateMaterial': substrateMaterial,
      'gsmMicron': gsmMicron,
      'adhesiveType': adhesiveType,
      'linerType': linerType,
      'faceMaterial': faceMaterial,
    };
  }

  String get dimensionsText => '${widthMm.toStringAsFixed(1)} mm × ${heightMm.toStringAsFixed(1)} mm ($shape)';
}

/// Printing Specification model.
@immutable
class PrintSpecModel {
  final int colorCount;
  final List<String> colorDetails;
  final String pantoneCodes;
  final String printMethod; // Flexo 8-Color, UV Flexo
  final String varnishType; // Matt, Gloss, Drip Off, UV, None
  final String laminationType; // Thermal Gloss, Thermal Matt, Cold Foil, None
  final String specialCoating;
  final bool hasNumbering;

  const PrintSpecModel({
    required this.colorCount,
    this.colorDetails = const [],
    this.pantoneCodes = '',
    this.printMethod = 'Flexo 8-Color',
    this.varnishType = 'None',
    this.laminationType = 'None',
    this.specialCoating = '',
    this.hasNumbering = false,
  });

  factory PrintSpecModel.fromMap(Map<String, dynamic> map) {
    return PrintSpecModel(
      colorCount: map['colorCount'] as int? ?? 1,
      colorDetails: (map['colorDetails'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      pantoneCodes: map['pantoneCodes'] as String? ?? '',
      printMethod: map['printMethod'] as String? ?? 'Flexo 8-Color',
      varnishType: map['varnishType'] as String? ?? 'None',
      laminationType: map['laminationType'] as String? ?? 'None',
      specialCoating: map['specialCoating'] as String? ?? '',
      hasNumbering: map['hasNumbering'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'colorCount': colorCount,
      'colorDetails': colorDetails,
      'pantoneCodes': pantoneCodes,
      'printMethod': printMethod,
      'varnishType': varnishType,
      'laminationType': laminationType,
      'specialCoating': specialCoating,
      'hasNumbering': hasNumbering,
    };
  }
}

/// Machine & Conversion Specification model.
@immutable
class MachineSpecModel {
  final double webWidthMm;
  final double repeatCylinderMm;
  final int gearTeethCount; // Teeth Z count e.g. 89, 96, 75
  final int webUps;
  final int repeatUps;

  int get acrossUps => webUps;
  int get aroundUps => repeatUps;

  final String punchDieCode;
  final double coreSizeMm; // 25mm (1"), 76mm (3")
  final int labelsPerRoll;
  final String windingDirection; // Head First, Foot First, Left First, Right First
  final String labelOrientation; // Face Out, Face In
  final String slittingSpec;

  const MachineSpecModel({
    required this.webWidthMm,
    required this.repeatCylinderMm,
    required this.webUps,
    required this.repeatUps,
    this.gearTeethCount = 89,
    this.punchDieCode = '',
    this.coreSizeMm = 76.0,
    this.labelsPerRoll = 1000,
    this.windingDirection = 'Head First',
    this.labelOrientation = 'Face Out',
    this.slittingSpec = '',
  });

  factory MachineSpecModel.fromMap(Map<String, dynamic> map) {
    final repeatMm = (map['repeatCylinderMm'] as num?)?.toDouble() ?? 0.0;
    final teeth = map['gearTeethCount'] as int? ?? (repeatMm > 0 ? (repeatMm / 3.175).round() : 89);
    final calculatedRepeat = repeatMm > 0 ? repeatMm : (teeth * 3.175);

    return MachineSpecModel(
      webWidthMm: (map['webWidthMm'] as num?)?.toDouble() ?? 0.0,
      repeatCylinderMm: calculatedRepeat,
      gearTeethCount: teeth,
      webUps: map['webUps'] as int? ?? (map['acrossUps'] as int? ?? 1),
      repeatUps: map['repeatUps'] as int? ?? (map['aroundUps'] as int? ?? 1),
      punchDieCode: map['punchDieCode'] as String? ?? '',
      coreSizeMm: (map['coreSizeMm'] as num?)?.toDouble() ?? 76.0,
      labelsPerRoll: map['labelsPerRoll'] as int? ?? 1000,
      windingDirection: map['windingDirection'] as String? ?? 'Head First',
      labelOrientation: map['labelOrientation'] as String? ?? 'Face Out',
      slittingSpec: map['slittingSpec'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'webWidthMm': webWidthMm,
      'repeatCylinderMm': repeatCylinderMm,
      'gearTeethCount': gearTeethCount,
      'webUps': webUps,
      'repeatUps': repeatUps,
      'acrossUps': webUps,
      'aroundUps': repeatUps,
      'punchDieCode': punchDieCode,
      'coreSizeMm': coreSizeMm,
      'labelsPerRoll': labelsPerRoll,
      'windingDirection': windingDirection,
      'labelOrientation': labelOrientation,
      'slittingSpec': slittingSpec,
    };
  }

  int get totalUps => webUps * repeatUps;
}

/// Standard Process Step options for Flexographic Label Manufacturing.
class StandardProcessSteps {
  static const String printing = 'Printing';
  static const String onlinePunching = 'Online Punching';
  static const String offlinePunching = 'Offline Punching';
  static const String hotFoilStamping = 'Hot Foil Stamping';
  static const String coldFoiling = 'Cold Foiling';
  static const String screenPrinting = 'Screen Printing';
  static const String blindEmbossing = 'Blind Embossing';
  static const String uvEmbossing = 'UV Embossing';
  static const String lamination = 'Lamination';
  static const String checking = 'Checking';
  static const String slitting = 'Slitting';
  static const String packing = 'Packing';

  static const List<String> allSteps = [
    printing,
    onlinePunching,
    offlinePunching,
    hotFoilStamping,
    coldFoiling,
    screenPrinting,
    blindEmbossing,
    uvEmbossing,
    lamination,
    checking,
    slitting,
    packing,
  ];

  static const List<String> defaultRoute = [
    printing,
    onlinePunching,
    checking,
    slitting,
    packing,
  ];
}

/// Product / SKU Master Data Model.
///
/// Implements Section 5.2, 5.3 of Doc/Flexora-Master-Requirements-v1.2.md:
/// Core master data for label SKU manufacturing parameters.
@immutable
class ProductModel {
  final String id;
  final String plantId;

  final String internalSkuCode;
  final String customerId;
  final String customerName;
  final String customerProductCode;
  final String productName;
  final String? description;

  final LabelSpecModel labelSpec;
  final PrintSpecModel printSpec;
  final MachineSpecModel machineSpec;

  /// Configurable production route (Section 2.2 of Master Doc)
  final List<String> processRoute;

  /// Artwork status tracking
  final String? currentArtworkVersionId;
  final String? currentArtworkStoragePath;
  final String artworkApprovalStatus; // pending, approved, rejected
  final DateTime? artworkApprovalDate;

  final String status; // active, inactive

  final DateTime createdAt;
  final String createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;

  const ProductModel({
    required this.id,
    required this.plantId,
    required this.internalSkuCode,
    required this.customerId,
    required this.customerName,
    required this.customerProductCode,
    required this.productName,
    required this.labelSpec,
    required this.printSpec,
    required this.machineSpec,
    required this.createdAt,
    required this.createdBy,
    this.description,
    this.processRoute = StandardProcessSteps.defaultRoute,
    this.currentArtworkVersionId,
    this.currentArtworkStoragePath,
    this.artworkApprovalStatus = ArtworkApprovalStatus.pending,
    this.artworkApprovalDate,
    this.status = ProductStatus.active,
    this.updatedAt,
    this.updatedBy,
  });

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      plantId: map['plantId'] as String? ?? 'plant-1',
      internalSkuCode: map['internalSkuCode'] as String? ?? '',
      customerId: map['customerId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      customerProductCode: map['customerProductCode'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      description: map['description'] as String?,
      labelSpec: map['labelSpec'] != null
          ? LabelSpecModel.fromMap(map['labelSpec'] as Map<String, dynamic>)
          : const LabelSpecModel(widthMm: 0, heightMm: 0, substrateMaterial: ''),
      printSpec: map['printSpec'] != null
          ? PrintSpecModel.fromMap(map['printSpec'] as Map<String, dynamic>)
          : const PrintSpecModel(colorCount: 1),
      machineSpec: map['machineSpec'] != null
          ? MachineSpecModel.fromMap(map['machineSpec'] as Map<String, dynamic>)
          : const MachineSpecModel(webWidthMm: 0, repeatCylinderMm: 0, webUps: 1, repeatUps: 1),
      processRoute: (map['processRoute'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          StandardProcessSteps.defaultRoute,
      currentArtworkVersionId: map['currentArtworkVersionId'] as String?,
      currentArtworkStoragePath: map['currentArtworkStoragePath'] as String?,
      artworkApprovalStatus: map['artworkApprovalStatus'] as String? ?? ArtworkApprovalStatus.pending,
      artworkApprovalDate: map['artworkApprovalDate'] != null
          ? DateTime.parse(map['artworkApprovalDate'] as String)
          : null,
      status: map['status'] as String? ?? ProductStatus.active,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      createdBy: map['createdBy'] as String? ?? 'system',
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt'] as String) : null,
      updatedBy: map['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plantId': plantId,
      'internalSkuCode': internalSkuCode,
      'customerId': customerId,
      'customerName': customerName,
      'customerProductCode': customerProductCode,
      'productName': productName,
      'description': description,
      'labelSpec': labelSpec.toMap(),
      'printSpec': printSpec.toMap(),
      'machineSpec': machineSpec.toMap(),
      'processRoute': processRoute,
      'currentArtworkVersionId': currentArtworkVersionId,
      'currentArtworkStoragePath': currentArtworkStoragePath,
      'artworkApprovalStatus': artworkApprovalStatus,
      'artworkApprovalDate': artworkApprovalDate?.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedAt': updatedAt?.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }
}

class ProductStatus {
  static const String active = 'active';
  static const String inactive = 'inactive';

  static const List<String> values = [active, inactive];
}

class ArtworkApprovalStatus {
  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String rejected = 'rejected';

  static const List<String> values = [pending, approved, rejected];
}
