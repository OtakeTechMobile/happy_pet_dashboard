import 'package:equatable/equatable.dart';

enum LogType { feeding, activity, health, incident, notes }

class DailyLogModel extends Equatable {
  final String id;
  final String petId;
  final String hotelId;
  final LogType type;
  final String title;
  final String? description;
  final String? photoUrl;
  final String createdBy;
  final DateTime createdAt;

  const DailyLogModel({
    required this.id,
    required this.petId,
    required this.hotelId,
    required this.type,
    required this.title,
    this.description,
    this.photoUrl,
    required this.createdBy,
    required this.createdAt,
  });

  factory DailyLogModel.fromJson(Map<String, dynamic> json) {
    return DailyLogModel(
      id: json['id'] ?? '',
      petId: json['pet_id'] ?? '',
      hotelId: json['hotel_id'] ?? '',
      type: LogType.values.firstWhere((e) => e.name == (json['type'] ?? 'notes'), orElse: () => LogType.notes),
      title: json['title'] ?? '',
      description: json['description'],
      photoUrl: json['photo_url'],
      createdBy: json['created_by'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'type': type.name,
      'title': title,
      'description': description,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };

    if (id.isNotEmpty) map['id'] = id;
    if (petId.isNotEmpty) map['pet_id'] = petId;
    if (hotelId.isNotEmpty) map['hotel_id'] = hotelId;

    return map;
  }

  @override
  List<Object?> get props => [id, petId, hotelId, type, title, description, photoUrl, createdBy, createdAt];
}
