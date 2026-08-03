import 'package:flutter/foundation.dart';

/// Address model for Billing & Shipping addresses.
@immutable
class AddressModel {
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String pincode;
  final String country;

  const AddressModel({
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.pincode,
    this.country = 'India',
  });

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      addressLine1: map['addressLine1'] as String? ?? '',
      addressLine2: map['addressLine2'] as String?,
      city: map['city'] as String? ?? '',
      state: map['state'] as String? ?? '',
      pincode: map['pincode'] as String? ?? '',
      country: map['country'] as String? ?? 'India',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'pincode': pincode,
      'country': country,
    };
  }

  String get fullAddress {
    final buffer = StringBuffer(addressLine1);
    if (addressLine2 != null && addressLine2!.isNotEmpty) {
      buffer.write(', $addressLine2');
    }
    buffer.write(', $city, $state - $pincode');
    return buffer.toString();
  }
}

/// Contact Person model.
@immutable
class ContactPersonModel {
  final String name;
  final String designation;
  final String phone;
  final String email;

  const ContactPersonModel({
    required this.name,
    this.designation = '',
    required this.phone,
    required this.email,
  });

  factory ContactPersonModel.fromMap(Map<String, dynamic> map) {
    return ContactPersonModel(
      name: map['name'] as String? ?? '',
      designation: map['designation'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'designation': designation,
      'phone': phone,
      'email': email,
    };
  }
}

/// Customer Master Data Model.
///
/// Implements Section 5.1 of Doc/Flexora-Master-Requirements-v1.2.md:
/// Single source of truth for Customer Master records.
@immutable
class CustomerModel {
  final String id;
  final String plantId;

  final String customerCode;
  final String companyName;
  final String? gstNo;
  final String? panNo;

  final ContactPersonModel primaryContact;
  final List<ContactPersonModel> additionalContacts;

  final AddressModel billingAddress;
  final List<AddressModel> shippingAddresses;

  final String? specialInstructions;
  final String? packingRequirements;
  final String? qcRequirements;

  final String status; // active, inactive

  final DateTime createdAt;
  final String createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;

  const CustomerModel({
    required this.id,
    required this.plantId,
    required this.customerCode,
    required this.companyName,
    required this.primaryContact,
    required this.billingAddress,
    required this.createdAt,
    required this.createdBy,
    this.gstNo,
    this.panNo,
    this.additionalContacts = const [],
    this.shippingAddresses = const [],
    this.specialInstructions,
    this.packingRequirements,
    this.qcRequirements,
    this.status = CustomerStatus.active,
    this.updatedAt,
    this.updatedBy,
  });

  factory CustomerModel.fromMap(String id, Map<String, dynamic> map) {
    ContactPersonModel parseContact(dynamic val) {
      if (val is Map<String, dynamic>) return ContactPersonModel.fromMap(val);
      return ContactPersonModel(
        name: map['contactPerson'] as String? ?? val?.toString() ?? '',
        phone: map['contactPhone'] as String? ?? '',
        email: map['contactEmail'] as String? ?? '',
      );
    }

    AddressModel parseAddress(dynamic val) {
      if (val is Map<String, dynamic>) return AddressModel.fromMap(val);
      final addrStr = val?.toString() ?? '';
      return AddressModel(
        addressLine1: addrStr,
        city: 'Mumbai',
        state: 'Maharashtra',
        pincode: '400001',
      );
    }

    return CustomerModel(
      id: id,
      plantId: map['plantId'] as String? ?? 'plant-1',
      customerCode: map['customerCode'] as String? ?? '',
      companyName: map['companyName'] as String? ?? '',
      gstNo: map['gstNo'] as String?,
      panNo: map['panNo'] as String?,
      primaryContact: parseContact(map['primaryContact']),
      additionalContacts: (map['additionalContacts'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => ContactPersonModel.fromMap(e))
              .toList() ??
          const [],
      billingAddress: parseAddress(map['billingAddress']),
      shippingAddresses: (map['shippingAddresses'] as List<dynamic>?)
              ?.map((e) => parseAddress(e))
              .toList() ??
          const [],
      specialInstructions: map['specialInstructions'] as String?,
      packingRequirements: map['packingRequirements'] as String?,
      qcRequirements: map['qcRequirements'] as String?,
      status: map['status'] as String? ?? CustomerStatus.active,
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
      'customerCode': customerCode,
      'companyName': companyName,
      'gstNo': gstNo,
      'panNo': panNo,
      'primaryContact': primaryContact.toMap(),
      'additionalContacts': additionalContacts.map((c) => c.toMap()).toList(),
      'billingAddress': billingAddress.toMap(),
      'shippingAddresses': shippingAddresses.map((a) => a.toMap()).toList(),
      'specialInstructions': specialInstructions,
      'packingRequirements': packingRequirements,
      'qcRequirements': qcRequirements,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedAt': updatedAt?.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }
}

class CustomerStatus {
  static const String active = 'active';
  static const String inactive = 'inactive';

  static const List<String> values = [active, inactive];
}
