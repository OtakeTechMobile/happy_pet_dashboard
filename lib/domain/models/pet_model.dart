import 'package:equatable/equatable.dart';

/// Pet model with medical records and photos
class PetModel extends Equatable {
  final String id;
  final String tutorId;
  final String name;
  final String species;
  final String? breed;
  final String? gender;
  final DateTime? birthDate;
  final double? weight;
  final String? microchipNumber;
  final String? color;
  final String? photoUrl;
  final List<String> photos;
  final String? medicalConditions;
  final String? allergies;
  final String? specialNeeds;
  final String? foodBrand;
  final String? foodAmount;
  final int feedingTimes;
  final List<VaccinationInfo> vaccinations;
  final List<MedicationInfo> medications;
  final String? veterinarianName;
  final String? veterinarianPhone;
  final bool isActive;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PetModel({
    required this.id,
    required this.tutorId,
    required this.name,
    required this.species,
    this.breed,
    this.gender,
    this.birthDate,
    this.weight,
    this.microchipNumber,
    this.color,
    this.photoUrl,
    this.photos = const [],
    this.medicalConditions,
    this.allergies,
    this.specialNeeds,
    this.foodBrand,
    this.foodAmount,
    this.feedingTimes = 2,
    this.vaccinations = const [],
    this.medications = const [],
    this.veterinarianName,
    this.veterinarianPhone,
    this.isActive = true,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  int? get ageInYears {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month || (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  String get displayAge {
    if (birthDate == null) return 'Unknown';
    final years = ageInYears!;
    if (years == 0) {
      final months = DateTime.now().month - birthDate!.month;
      return months <= 0 ? 'Less than 1 month' : '$months months';
    }
    return '$years ${years == 1 ? 'year' : 'years'}';
  }

  bool get hasExpiredVaccinations {
    final now = DateTime.now();
    return vaccinations.any((v) => v.nextDate != null && v.nextDate!.isBefore(now));
  }

  List<VaccinationInfo> get expiredVaccinations {
    final now = DateTime.now();
    return vaccinations.where((v) => v.nextDate != null && v.nextDate!.isBefore(now)).toList();
  }

  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      id: json['id'] as String,
      tutorId: json['tutor_id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      breed: json['breed'] as String?,
      gender: json['gender'] as String?,
      birthDate: json['birth_date'] != null ? DateTime.parse(json['birth_date'] as String) : null,
      weight: (json['weight'] as num?)?.toDouble(),
      microchipNumber: json['microchip_number'] as String?,
      color: json['color'] as String?,
      photoUrl: json['photo_url'] as String?,
      photos: (json['photos'] as List<dynamic>?)?.cast<String>() ?? const [],
      medicalConditions: json['medical_conditions'] as String?,
      allergies: json['allergies'] as String?,
      specialNeeds: json['special_needs'] as String?,
      foodBrand: json['food_brand'] as String?,
      foodAmount: json['food_amount'] as String?,
      feedingTimes: json['feeding_times'] as int? ?? 2,
      vaccinations:
          (json['vaccinations'] as List<dynamic>?)
              ?.map((v) => VaccinationInfo.fromJson(v as Map<String, dynamic>))
              .toList() ??
          const [],
      medications:
          (json['medications'] as List<dynamic>?)
              ?.map((m) => MedicationInfo.fromJson(m as Map<String, dynamic>))
              .toList() ??
          const [],
      veterinarianName: json['veterinarian_name'] as String?,
      veterinarianPhone: json['veterinarian_phone'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tutor_id': tutorId,
      'name': name,
      'species': species,
      'breed': breed,
      'gender': gender,
      'birth_date': birthDate?.toIso8601String().split('T')[0],
      'weight': weight,
      'microchip_number': microchipNumber,
      'color': color,
      'photo_url': photoUrl,
      'photos': photos,
      'medical_conditions': medicalConditions,
      'allergies': allergies,
      'special_needs': specialNeeds,
      'food_brand': foodBrand,
      'food_amount': foodAmount,
      'feeding_times': feedingTimes,
      'vaccinations': vaccinations.map((v) => v.toJson()).toList(),
      'medications': medications.map((m) => m.toJson()).toList(),
      'veterinarian_name': veterinarianName,
      'veterinarian_phone': veterinarianPhone,
      'is_active': isActive,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PetModel copyWith({
    String? id,
    String? tutorId,
    String? name,
    String? species,
    String? breed,
    String? gender,
    DateTime? birthDate,
    double? weight,
    String? microchipNumber,
    String? color,
    String? photoUrl,
    List<String>? photos,
    String? medicalConditions,
    String? allergies,
    String? specialNeeds,
    String? foodBrand,
    String? foodAmount,
    int? feedingTimes,
    List<VaccinationInfo>? vaccinations,
    List<MedicationInfo>? medications,
    String? veterinarianName,
    String? veterinarianPhone,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PetModel(
      id: id ?? this.id,
      tutorId: tutorId ?? this.tutorId,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      weight: weight ?? this.weight,
      microchipNumber: microchipNumber ?? this.microchipNumber,
      color: color ?? this.color,
      photoUrl: photoUrl ?? this.photoUrl,
      photos: photos ?? this.photos,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      allergies: allergies ?? this.allergies,
      specialNeeds: specialNeeds ?? this.specialNeeds,
      foodBrand: foodBrand ?? this.foodBrand,
      foodAmount: foodAmount ?? this.foodAmount,
      feedingTimes: feedingTimes ?? this.feedingTimes,
      vaccinations: vaccinations ?? this.vaccinations,
      medications: medications ?? this.medications,
      veterinarianName: veterinarianName ?? this.veterinarianName,
      veterinarianPhone: veterinarianPhone ?? this.veterinarianPhone,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    tutorId,
    name,
    species,
    breed,
    gender,
    birthDate,
    weight,
    microchipNumber,
    color,
    photoUrl,
    photos,
    medicalConditions,
    allergies,
    specialNeeds,
    foodBrand,
    foodAmount,
    feedingTimes,
    vaccinations,
    medications,
    veterinarianName,
    veterinarianPhone,
    isActive,
    createdBy,
    createdAt,
    updatedAt,
  ];
}

/// Vaccination information embedded in pet
class VaccinationInfo extends Equatable {
  final String name;
  final DateTime date;
  final DateTime? nextDate;
  final String? documentUrl;

  const VaccinationInfo({required this.name, required this.date, this.nextDate, this.documentUrl});

  bool get isExpired {
    if (nextDate == null) return false;
    return nextDate!.isBefore(DateTime.now());
  }

  factory VaccinationInfo.fromJson(Map<String, dynamic> json) {
    return VaccinationInfo(
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      nextDate: json['next_date'] != null ? DateTime.parse(json['next_date'] as String) : null,
      documentUrl: json['document_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'date': date.toIso8601String(),
      'next_date': nextDate?.toIso8601String(),
      'document_url': documentUrl,
    };
  }

  @override
  List<Object?> get props => [name, date, nextDate, documentUrl];
}

/// Medication information embedded in pet
class MedicationInfo extends Equatable {
  final String name;
  final String dosage;
  final String frequency;
  final DateTime startDate;
  final DateTime? endDate;

  const MedicationInfo({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    this.endDate,
  });

  bool get isActive {
    final now = DateTime.now();
    if (endDate == null) return now.isAfter(startDate);
    return now.isAfter(startDate) && now.isBefore(endDate!);
  }

  factory MedicationInfo.fromJson(Map<String, dynamic> json) {
    return MedicationInfo(
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [name, dosage, frequency, startDate, endDate];
}
