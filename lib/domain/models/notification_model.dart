import 'package:equatable/equatable.dart';

/// Notification model for communication tracking
class NotificationModel extends Equatable {
  final String id;
  final String? recipientId;
  final String? recipientEmail;
  final String? recipientPhone;
  final NotificationType type;
  final String? subject;
  final String content;
  final NotificationStatus status;
  final DateTime? sentAt;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    this.recipientId,
    this.recipientEmail,
    this.recipientPhone,
    required this.type,
    this.subject,
    required this.content,
    required this.status,
    this.sentAt,
    this.errorMessage,
    this.metadata,
    required this.createdAt,
  });

  bool get isSent => status == NotificationStatus.sent;
  bool get isPending => status == NotificationStatus.pending;
  bool get isFailed => status == NotificationStatus.failed;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      recipientId: json['recipient_id'] ?? '',
      recipientEmail: json['recipient_email'] ?? '',
      recipientPhone: json['recipient_phone'] ?? '',
      type: NotificationType.fromString(json['type'] ?? ''),
      subject: json['subject'] ?? '',
      content: json['content'] ?? '',
      status: NotificationStatus.fromString(json['status'] ?? ''),
      sentAt: json['sent_at'] != null ? DateTime.parse(json['sent_at'] ?? '') : null,
      errorMessage: json['error_message'] ?? '',
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipient_id': recipientId,
      'recipient_email': recipientEmail,
      'recipient_phone': recipientPhone,
      'type': type.name,
      'subject': subject,
      'content': content,
      'status': status.name,
      'sent_at': sentAt?.toIso8601String(),
      'error_message': errorMessage,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? recipientId,
    String? recipientEmail,
    String? recipientPhone,
    NotificationType? type,
    String? subject,
    String? content,
    NotificationStatus? status,
    DateTime? sentAt,
    String? errorMessage,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      type: type ?? this.type,
      subject: subject ?? this.subject,
      content: content ?? this.content,
      status: status ?? this.status,
      sentAt: sentAt ?? this.sentAt,
      errorMessage: errorMessage ?? this.errorMessage,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    recipientId,
    recipientEmail,
    recipientPhone,
    type,
    subject,
    content,
    status,
    sentAt,
    errorMessage,
    metadata,
    createdAt,
  ];
}

/// Notification type enum
enum NotificationType {
  email,
  sms,
  whatsapp;

  String get displayName {
    switch (this) {
      case NotificationType.email:
        return 'Email';
      case NotificationType.sms:
        return 'SMS';
      case NotificationType.whatsapp:
        return 'WhatsApp';
    }
  }

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.name == value.toLowerCase(),
      orElse: () => NotificationType.email,
    );
  }
}

/// Notification status enum
enum NotificationStatus {
  pending,
  sent,
  failed;

  String get displayName {
    switch (this) {
      case NotificationStatus.pending:
        return 'Pending';
      case NotificationStatus.sent:
        return 'Sent';
      case NotificationStatus.failed:
        return 'Failed';
    }
  }

  static NotificationStatus fromString(String value) {
    return NotificationStatus.values.firstWhere(
      (status) => status.name == value.toLowerCase(),
      orElse: () => NotificationStatus.pending,
    );
  }
}
