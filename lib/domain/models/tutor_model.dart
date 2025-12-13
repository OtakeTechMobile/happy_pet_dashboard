import 'package:equatable/equatable.dart';

/// Tutor model representing pet owners/guardians
class TutorModel extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? secondaryPhone;
  final String? cpf;
  final String? addressStreet;
  final String? addressNumber;
  final String? addressComplement;
  final String? addressNeighborhood;
  final String? addressCity;
  final String? addressState;
  final String? addressZip;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? notes;
  final List<DocumentInfo> documents;
  final bool isActive;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TutorModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.secondaryPhone,
    this.cpf,
    this.addressStreet,
    this.addressNumber,
    this.addressComplement,
    this.addressNeighborhood,
    this.addressCity,
    this.addressState,
    this.addressZip,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.notes,
    this.documents = const [],
    this.isActive = true,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullAddress {
    final parts = <String>[];
    if (addressStreet != null && addressStreet!.isNotEmpty) {
      parts.add(addressStreet!);
      if (addressNumber != null) parts.add(addressNumber!);
    }
    if (addressNeighborhood != null) parts.add(addressNeighborhood!);
    if (addressCity != null && addressState != null) {
      parts.add('$addressCity - $addressState');
    }
    if (addressZip != null) parts.add('CEP: $addressZip');
    return parts.join(', ');
  }

  factory TutorModel.fromJson(Map<String, dynamic> json) {
    return TutorModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      secondaryPhone: json['secondary_phone'] as String?,
      cpf: json['cpf'] as String?,
      addressStreet: json['address_street'] as String?,
      addressNumber: json['address_number'] as String?,
      addressComplement: json['address_complement'] as String?,
      addressNeighborhood: json['address_neighborhood'] as String?,
      addressCity: json['address_city'] as String?,
      addressState: json['address_state'] as String?,
      addressZip: json['address_zip'] as String?,
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactPhone: json['emergency_contact_phone'] as String?,
      notes: json['notes'] as String?,
      documents:
          (json['documents'] as List<dynamic>?)
              ?.map((doc) => DocumentInfo.fromJson(doc as Map<String, dynamic>))
              .toList() ??
          const [],
      isActive: json['is_active'] as bool? ?? true,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'secondary_phone': secondaryPhone,
      'cpf': cpf,
      'address_street': addressStreet,
      'address_number': addressNumber,
      'address_complement': addressComplement,
      'address_neighborhood': addressNeighborhood,
      'address_city': addressCity,
      'address_state': addressState,
      'address_zip': addressZip,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'notes': notes,
      'documents': documents.map((doc) => doc.toJson()).toList(),
      'is_active': isActive,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  TutorModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? secondaryPhone,
    String? cpf,
    String? addressStreet,
    String? addressNumber,
    String? addressComplement,
    String? addressNeighborhood,
    String? addressCity,
    String? addressState,
    String? addressZip,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? notes,
    List<DocumentInfo>? documents,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TutorModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      secondaryPhone: secondaryPhone ?? this.secondaryPhone,
      cpf: cpf ?? this.cpf,
      addressStreet: addressStreet ?? this.addressStreet,
      addressNumber: addressNumber ?? this.addressNumber,
      addressComplement: addressComplement ?? this.addressComplement,
      addressNeighborhood: addressNeighborhood ?? this.addressNeighborhood,
      addressCity: addressCity ?? this.addressCity,
      addressState: addressState ?? this.addressState,
      addressZip: addressZip ?? this.addressZip,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      notes: notes ?? this.notes,
      documents: documents ?? this.documents,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
    email,
    phone,
    secondaryPhone,
    cpf,
    addressStreet,
    addressNumber,
    addressComplement,
    addressNeighborhood,
    addressCity,
    addressState,
    addressZip,
    emergencyContactName,
    emergencyContactPhone,
    notes,
    documents,
    isActive,
    createdBy,
    createdAt,
    updatedAt,
  ];
}

/// Document information embedded in tutor
class DocumentInfo extends Equatable {
  final String name;
  final String url;
  final String type;

  const DocumentInfo({required this.name, required this.url, required this.type});

  factory DocumentInfo.fromJson(Map<String, dynamic> json) {
    return DocumentInfo(name: json['name'] as String, url: json['url'] as String, type: json['type'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'url': url, 'type': type};
  }

  @override
  List<Object?> get props => [name, url, type];
}
