import 'package:equatable/equatable.dart';

/// Pricing package model for different stay durations
class PricingPackageModel extends Equatable {
  final String id;
  final String hotelId;
  final String name;
  final PricingType type;
  final double price;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PricingPackageModel({
    required this.id,
    required this.hotelId,
    required this.name,
    required this.type,
    required this.price,
    this.description,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PricingPackageModel.fromJson(Map<String, dynamic> json) {
    return PricingPackageModel(
      id: json['id'] as String,
      hotelId: json['hotel_id'] as String,
      name: json['name'] as String,
      type: PricingType.fromString(json['type'] as String),
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotel_id': hotelId,
      'name': name,
      'type': type.toDbString(),
      'price': price,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PricingPackageModel copyWith({
    String? id,
    String? hotelId,
    String? name,
    PricingType? type,
    double? price,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PricingPackageModel(
      id: id ?? this.id,
      hotelId: hotelId ?? this.hotelId,
      name: name ?? this.name,
      type: type ?? this.type,
      price: price ?? this.price,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        hotelId,
        name,
        type,
        price,
        description,
        isActive,
        createdAt,
        updatedAt,
      ];
}

/// Pricing type enum
enum PricingType {
  daily,
  weekly,
  monthly,
  semiAnnual,
  annual;

  String get displayName {
    switch (this) {
      case PricingType.daily:
        return 'Daily';
      case PricingType.weekly:
        return 'Weekly';
      case PricingType.monthly:
        return 'Monthly';
      case PricingType.semiAnnual:
        return 'Semi-Annual';
      case PricingType.annual:
        return 'Annual';
    }
  }

  static PricingType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'weekly':
        return PricingType.weekly;
      case 'monthly':
        return PricingType.monthly;
      case 'semi_annual':
      case 'semiannual':
        return PricingType.semiAnnual;
      case 'annual':
        return PricingType.annual;
      default:
        return PricingType.daily;
    }
  }

  String toDbString() {
    switch (this) {
      case PricingType.weekly:
        return 'weekly';
      case PricingType.monthly:
        return 'monthly';
      case PricingType.semiAnnual:
        return 'semi_annual';
      case PricingType.annual:
        return 'annual';
      default:
        return 'daily';
    }
  }
}

/// Additional service model for extra charges
class AdditionalServiceModel extends Equatable {
  final String id;
  final String hotelId;
  final String name;
  final double price;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AdditionalServiceModel({
    required this.id,
    required this.hotelId,
    required this.name,
    required this.price,
    this.description,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdditionalServiceModel.fromJson(Map<String, dynamic> json) {
    return AdditionalServiceModel(
      id: json['id'] as String,
      hotelId: json['hotel_id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotel_id': hotelId,
      'name': name,
      'price': price,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  AdditionalServiceModel copyWith({
    String? id,
    String? hotelId,
    String? name,
    double? price,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdditionalServiceModel(
      id: id ?? this.id,
      hotelId: hotelId ?? this.hotelId,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        hotelId,
        name,
        price,
        description,
        isActive,
        createdAt,
        updatedAt,
      ];
}
