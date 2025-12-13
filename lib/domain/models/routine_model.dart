import 'package:equatable/equatable.dart';

import '../enums/app_enums.dart';

/// Routine model representing daily activities
class RoutineModel extends Equatable {
  final String id;
  final String stayId;
  final String petId;
  final RoutineType type;
  final String title;
  final String? description;
  final String scheduledTime; // HH:mm format
  final DateTime date;
  final RoutineStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? assignedTo;
  final String? completedBy;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RoutineModel({
    required this.id,
    required this.stayId,
    required this.petId,
    required this.type,
    required this.title,
    this.description,
    required this.scheduledTime,
    required this.date,
    required this.status,
    this.startedAt,
    this.completedAt,
    this.assignedTo,
    this.completedBy,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCompleted => status == RoutineStatus.completed;
  bool get isInProgress => status == RoutineStatus.inProgress;
  bool get isPending => status == RoutineStatus.pending;

  DateTime get scheduledDateTime {
    final timeParts = scheduledTime.split(':');
    return DateTime(date.year, date.month, date.day, int.parse(timeParts[0]), int.parse(timeParts[1]));
  }

  factory RoutineModel.fromJson(Map<String, dynamic> json) {
    return RoutineModel(
      id: json['id'] as String,
      stayId: json['stay_id'] as String,
      petId: json['pet_id'] as String,
      type: RoutineType.fromString(json['type'] as String),
      title: json['title'] as String,
      description: json['description'] as String?,
      scheduledTime: json['scheduled_time'] as String,
      date: DateTime.parse(json['date'] as String),
      status: RoutineStatus.fromString(json['status'] as String),
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at'] as String) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
      assignedTo: json['assigned_to'] as String?,
      completedBy: json['completed_by'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stay_id': stayId,
      'pet_id': petId,
      'type': type.name,
      'title': title,
      'description': description,
      'scheduled_time': scheduledTime,
      'date': date.toIso8601String().split('T')[0],
      'status': status.toDbString(),
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'assigned_to': assignedTo,
      'completed_by': completedBy,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  RoutineModel copyWith({
    String? id,
    String? stayId,
    String? petId,
    RoutineType? type,
    String? title,
    String? description,
    String? scheduledTime,
    DateTime? date,
    RoutineStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    String? assignedTo,
    String? completedBy,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoutineModel(
      id: id ?? this.id,
      stayId: stayId ?? this.stayId,
      petId: petId ?? this.petId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      date: date ?? this.date,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      assignedTo: assignedTo ?? this.assignedTo,
      completedBy: completedBy ?? this.completedBy,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    stayId,
    petId,
    type,
    title,
    description,
    scheduledTime,
    date,
    status,
    startedAt,
    completedAt,
    assignedTo,
    completedBy,
    notes,
    createdAt,
    updatedAt,
  ];
}
