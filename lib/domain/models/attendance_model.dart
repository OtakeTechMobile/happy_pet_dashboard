import 'package:equatable/equatable.dart';

import '../enums/app_enums.dart';

/// Attendance model representing daily check-in/out tracking
class AttendanceModel extends Equatable {
  final String id;
  final String stayId;
  final String petId;
  final DateTime date;
  final DateTime? arrivedAt;
  final DateTime? leftAt;
  final AttendanceStatus status;
  final String? notes;
  final String? recordedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AttendanceModel({
    required this.id,
    required this.stayId,
    required this.petId,
    required this.date,
    this.arrivedAt,
    this.leftAt,
    required this.status,
    this.notes,
    this.recordedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPresent => status == AttendanceStatus.present;
  bool get isAbsent => status == AttendanceStatus.absent;
  bool get isLate => status == AttendanceStatus.late;
  bool get isEarlyDeparture => status == AttendanceStatus.earlyDeparture;

  Duration? get timeSpent {
    if (arrivedAt == null || leftAt == null) return null;
    return leftAt!.difference(arrivedAt!);
  }

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] ?? '',
      stayId: json['stay_id'] ?? '',
      petId: json['pet_id'] ?? '',
      date: DateTime.parse(json['date'] ?? ''),
      arrivedAt: json['arrived_at'] != null ? DateTime.parse(json['arrived_at'] ?? '') : null,
      leftAt: json['left_at'] != null ? DateTime.parse(json['left_at'] ?? '') : null,
      status: AttendanceStatus.fromString(json['status'] ?? ''),
      notes: json['notes'] ?? '',
      recordedBy: json['recorded_by'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? ''),
      updatedAt: DateTime.parse(json['updated_at'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stay_id': stayId,
      'pet_id': petId,
      'date': date.toIso8601String().split('T')[0],
      'arrived_at': arrivedAt?.toIso8601String(),
      'left_at': leftAt?.toIso8601String(),
      'status': status.toDbString(),
      'notes': notes,
      'recorded_by': recordedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  AttendanceModel copyWith({
    String? id,
    String? stayId,
    String? petId,
    DateTime? date,
    DateTime? arrivedAt,
    DateTime? leftAt,
    AttendanceStatus? status,
    String? notes,
    String? recordedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      stayId: stayId ?? this.stayId,
      petId: petId ?? this.petId,
      date: date ?? this.date,
      arrivedAt: arrivedAt ?? this.arrivedAt,
      leftAt: leftAt ?? this.leftAt,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      recordedBy: recordedBy ?? this.recordedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    stayId,
    petId,
    date,
    arrivedAt,
    leftAt,
    status,
    notes,
    recordedBy,
    createdAt,
    updatedAt,
  ];
}
