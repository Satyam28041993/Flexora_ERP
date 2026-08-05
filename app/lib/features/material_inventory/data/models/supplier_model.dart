import 'package:flutter/foundation.dart';

/// Approved-vendor status. Kept minimal until the Purchase module's real
/// approval workflow is supplied by the user.
class SupplierStatus {
  SupplierStatus._();

  static const String active = 'Active';
  static const String inactive = 'Inactive';

  static const List<String> values = [active, inactive];
}

/// Supplier / Vendor master record.
///
/// Only the company name is mandatory: names were imported from the PGPL
/// stock workbook, and the commercial details (GSTIN, PAN, contact, address)
/// are filled in by the user. Nothing here is defaulted to a guessed value.
@immutable
class SupplierModel {
  const SupplierModel({
    required this.id,
    required this.plantId,
    required this.supplierCode,
    required this.companyName,
    this.materialCategory = '',
    this.contactPerson = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.gstNo = '',
    this.panNo = '',
    this.isoCertification = '',
    this.status = SupplierStatus.active,
    required this.createdAt,
    required this.createdBy,
    this.updatedAt,
    this.updatedBy,
  });

  final String id;
  final String plantId;
  final String supplierCode;
  final String companyName;
  final String materialCategory;
  final String contactPerson;
  final String phone;
  final String email;
  final String address;
  final String gstNo;
  final String panNo;
  final String isoCertification;
  final String status;
  final DateTime createdAt;
  final String createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;

  /// True once the user has filled in the details needed to raise a PO.
  bool get hasCommercialDetails => gstNo.isNotEmpty && phone.isNotEmpty;

  SupplierModel copyWith({
    String? supplierCode,
    String? companyName,
    String? materialCategory,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    String? gstNo,
    String? panNo,
    String? isoCertification,
    String? status,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return SupplierModel(
      id: id,
      plantId: plantId,
      supplierCode: supplierCode ?? this.supplierCode,
      companyName: companyName ?? this.companyName,
      materialCategory: materialCategory ?? this.materialCategory,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      gstNo: gstNo ?? this.gstNo,
      panNo: panNo ?? this.panNo,
      isoCertification: isoCertification ?? this.isoCertification,
      status: status ?? this.status,
      createdAt: createdAt,
      createdBy: createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  factory SupplierModel.fromMap(String id, Map<String, dynamic> map) {
    return SupplierModel(
      id: id,
      plantId: map['plantId'] as String? ?? 'pgpl-vasai',
      supplierCode: map['supplierCode'] as String? ?? '',
      companyName: map['companyName'] as String? ?? '',
      materialCategory: map['materialCategory'] as String? ?? '',
      contactPerson: map['contactPerson'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      address: map['address'] as String? ?? '',
      gstNo: map['gstNo'] as String? ?? '',
      panNo: map['panNo'] as String? ?? '',
      isoCertification: map['isoCertification'] as String? ?? '',
      status: map['status'] as String? ?? SupplierStatus.active,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      createdBy: map['createdBy'] as String? ?? 'system',
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
      updatedBy: map['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plantId': plantId,
      'supplierCode': supplierCode,
      'companyName': companyName,
      'materialCategory': materialCategory,
      'contactPerson': contactPerson,
      'phone': phone,
      'email': email,
      'address': address,
      'gstNo': gstNo,
      'panNo': panNo,
      'isoCertification': isoCertification,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedAt': updatedAt?.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }
}
