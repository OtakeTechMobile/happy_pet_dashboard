import 'package:equatable/equatable.dart';

import '../enums/app_enums.dart';

/// Stay model representing reservations and check-ins
class StayModel extends Equatable {
  final String id;
  final String petId;
  final String tutorId;
  final StayStatus status;
  final DateTime scheduledCheckIn;
  final DateTime scheduledCheckOut;
  final DateTime? actualCheckin;
  final DateTime? actualCheckout;
  final String? checkInBy;
  final String? checkOutBy;
  final String? packageType;
  final double? basePrice;
  final List<AdditionalService> additionalServices;
  final double? totalPrice;
  final String? notes;
  final String? cancellationReason;
  final DateTime? cancelledAt;
  final String? cancelledBy;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StayModel({
    required this.id,
    required this.petId,
    required this.tutorId,
    required this.status,
    required this.scheduledCheckIn,
    required this.scheduledCheckOut,
    this.actualCheckin,
    this.actualCheckout,
    this.checkInBy,
    this.checkOutBy,
    this.packageType,
    this.basePrice,
    this.additionalServices = const [],
    this.totalPrice,
    this.notes,
    this.cancellationReason,
    this.cancelledAt,
    this.cancelledBy,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  int get durationInDays {
    return scheduledCheckOut.difference(scheduledCheckIn).inDays + 1;
  }

  bool get isActive {
    return status == StayStatus.checkedIn;
  }

  bool get isEarlyDeparture {
    if (actualCheckout == null || status != StayStatus.checkedOut) return false;
    return actualCheckout!.isBefore(scheduledCheckOut);
  }

  factory StayModel.fromJson(Map<String, dynamic> json) {
    return StayModel(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      tutorId: json['tutor_id'] as String,
      status: StayStatus.fromString(json['status'] as String),
      scheduledCheckIn: DateTime.parse(json['scheduled_checkin'] as String),
      scheduledCheckOut: DateTime.parse(json['scheduled_checkout'] as String),
      actualCheckin: json['actual_checkin'] != null ? DateTime.parse(json['actual_checkin'] as String) : null,
      actualCheckout: json['actual_checkout'] != null ? DateTime.parse(json['actual_checkout'] as String) : null,
      checkInBy: json['check_in_by'] as String?,
      checkOutBy: json['check_out_by'] as String?,
      packageType: json['package_type'] as String?,
      basePrice: (json['base_price'] as num?)?.toDouble(),
      additionalServices:
          (json['additional_services'] as List<dynamic>?)
              ?.map((s) => AdditionalService.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const [],
      totalPrice: (json['total_price'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      cancelledAt: json['cancelled_at'] != null ? DateTime.parse(json['cancelled_at'] as String) : null,
      cancelledBy: json['cancelled_by'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pet_id': petId,
      'tutor_id': tutorId,
      'status': status.toDbString(),
      'scheduled_checkin': scheduledCheckIn.toIso8601String(),
      'scheduled_checkout': scheduledCheckOut.toIso8601String(),
      'actual_checkin': actualCheckin?.toIso8601String(),
      'actual_checkout': actualCheckout?.toIso8601String(),
      'check_in_by': checkInBy,
      'check_out_by': checkOutBy,
      'package_type': packageType,
      'base_price': basePrice,
      'additional_services': additionalServices.map((s) => s.toJson()).toList(),
      'total_price': totalPrice,
      'notes': notes,
      'cancellation_reason': cancellationReason,
      'cancelled_at': cancelledAt?.toIso8601String(),
      'cancelled_by': cancelledBy,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  StayModel copyWith({
    String? id,
    String? petId,
    String? tutorId,
    StayStatus? status,
    DateTime? scheduledCheckIn,
    DateTime? scheduledCheckOut,
    DateTime? actualCheckin,
    DateTime? actualCheckout,
    String? checkInBy,
    String? checkOutBy,
    String? packageType,
    double? basePrice,
    List<AdditionalService>? additionalServices,
    double? totalPrice,
    String? notes,
    String? cancellationReason,
    DateTime? cancelledAt,
    String? cancelledBy,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StayModel(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      tutorId: tutorId ?? this.tutorId,
      status: status ?? this.status,
      scheduledCheckIn: scheduledCheckIn ?? this.scheduledCheckIn,
      scheduledCheckOut: scheduledCheckOut ?? this.scheduledCheckOut,
      actualCheckin: actualCheckin ?? this.actualCheckin,
      actualCheckout: actualCheckout ?? this.actualCheckout,
      checkInBy: checkInBy ?? this.checkInBy,
      checkOutBy: checkOutBy ?? this.checkOutBy,
      packageType: packageType ?? this.packageType,
      basePrice: basePrice ?? this.basePrice,
      additionalServices: additionalServices ?? this.additionalServices,
      totalPrice: totalPrice ?? this.totalPrice,
      notes: notes ?? this.notes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    petId,
    tutorId,
    status,
    scheduledCheckIn,
    scheduledCheckOut,
    actualCheckin,
    actualCheckout,
    checkInBy,
    checkOutBy,
    packageType,
    basePrice,
    additionalServices,
    totalPrice,
    notes,
    cancellationReason,
    cancelledAt,
    cancelledBy,
    createdBy,
    createdAt,
    updatedAt,
  ];
}

/// Additional service embedded in stay
class AdditionalService extends Equatable {
  final String service;
  final double price;

  const AdditionalService({required this.service, required this.price});

  factory AdditionalService.fromJson(Map<String, dynamic> json) {
    return AdditionalService(service: json['service'] as String, price: (json['price'] as num).toDouble());
  }

  Map<String, dynamic> toJson() {
    return {'service': service, 'price': price};
  }

  @override
  List<Object?> get props => [service, price];
}
