import 'package:equatable/equatable.dart';

/// Hotel model representing pet hotel locations
class HotelModel extends Equatable {
  final String id;
  final String name;
  final String? addressStreet;
  final String? addressNumber;
  final String? addressCity;
  final String? addressState;
  final String? addressZip;
  final String? phone;
  final String? email;
  final int capacity;
  final Map<String, dynamic>? businessHours;
  final Map<String, dynamic>? settings;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HotelModel({
    required this.id,
    required this.name,
    this.addressStreet,
    this.addressNumber,
    this.addressCity,
    this.addressState,
    this.addressZip,
    this.phone,
    this.email,
    this.capacity = 20,
    this.businessHours,
    this.settings,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullAddress {
    final parts = <String>[];
    if (addressStreet != null && addressStreet!.isNotEmpty) {
      parts.add(addressStreet!);
      if (addressNumber != null) parts.add(addressNumber!);
    }
    if (addressCity != null && addressState != null) {
      parts.add('$addressCity - $addressState');
    }
    if (addressZip != null) parts.add('CEP: $addressZip');
    return parts.join(', ');
  }

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    return HotelModel(
      id: json['id'] as String,
      name: json['name'] as String,
      addressStreet: json['address_street'] as String?,
      addressNumber: json['address_number'] as String?,
      addressCity: json['address_city'] as String?,
      addressState: json['address_state'] as String?,
      addressZip: json['address_zip'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      capacity: json['capacity'] as int? ?? 20,
      businessHours: json['business_hours'] as Map<String, dynamic>?,
      settings: json['settings'] as Map<String, dynamic>?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address_street': addressStreet,
      'address_number': addressNumber,
      'address_city': addressCity,
      'address_state': addressState,
      'address_zip': addressZip,
      'phone': phone,
      'email': email,
      'capacity': capacity,
      'business_hours': businessHours,
      'settings': settings,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  HotelModel copyWith({
    String? id,
    String? name,
    String? addressStreet,
    String? addressNumber,
    String? addressCity,
    String? addressState,
    String? addressZip,
    String? phone,
    String? email,
    int? capacity,
    Map<String, dynamic>? businessHours,
    Map<String, dynamic>? settings,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HotelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      addressStreet: addressStreet ?? this.addressStreet,
      addressNumber: addressNumber ?? this.addressNumber,
      addressCity: addressCity ?? this.addressCity,
      addressState: addressState ?? this.addressState,
      addressZip: addressZip ?? this.addressZip,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      capacity: capacity ?? this.capacity,
      businessHours: businessHours ?? this.businessHours,
      settings: settings ?? this.settings,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        addressStreet,
        addressNumber,
        addressCity,
        addressState,
        addressZip,
        phone,
        email,
        capacity,
        businessHours,
        settings,
        isActive,
        createdAt,
        updatedAt,
      ];
}
