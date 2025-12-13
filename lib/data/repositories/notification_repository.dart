import '../../domain/models/notification_model.dart';
import 'base_repository.dart';

/// Repository for notification operations
class NotificationRepository extends BaseRepository {
  static const String tableName = 'notifications';

  /// Get all notifications
  Future<List<NotificationModel>> getAll({
    String? recipientId,
    NotificationType? type,
    NotificationStatus? status,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      dynamic query = from(tableName).select();

      if (recipientId != null) {
        query = query.eq('recipient_id', recipientId);
      }

      if (type != null) {
        query = query.eq('type', type.name);
      }

      if (status != null) {
        query = query.eq('status', status.name);
      }

      // Apply ordering and range AFTER all filters
      query = query.order('created_at', ascending: false).range(offset, offset + limit - 1);

      final response = await query;
      return (response as List).map((json) => NotificationModel.fromJson(json)).toList();
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Get notification by ID
  Future<NotificationModel?> getById(String id) async {
    try {
      final response = await from(tableName).select().eq('id', id).maybeSingle();
      return response != null ? NotificationModel.fromJson(response) : null;
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Get failed notifications for retry
  Future<List<NotificationModel>> getFailedNotifications({int limit = 50}) async {
    return getAll(status: NotificationStatus.failed, limit: limit);
  }

  /// Create notification
  Future<NotificationModel> create(NotificationModel notification) async {
    try {
      final response = await from(tableName).insert(notification.toJson()).select().single();
      return NotificationModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Update notification
  Future<NotificationModel> update(NotificationModel notification) async {
    try {
      final response = await from(tableName).update(notification.toJson()).eq('id', notification.id).select().single();
      return NotificationModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Mark notification as sent
  Future<NotificationModel> markAsSent(String notificationId) async {
    try {
      final response = await from(tableName)
          .update({
            'status': 'sent',
            'sent_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId)
          .select()
          .single();
      return NotificationModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Mark notification as failed
  Future<NotificationModel> markAsFailed(String notificationId, String errorMessage) async {
    try {
      final response = await from(tableName)
          .update({
            'status': 'failed',
            'error_message': errorMessage,
          })
          .eq('id', notificationId)
          .select()
          .single();
      return NotificationModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Delete notification
  Future<void> delete(String id) async {
    try {
      await from(tableName).delete().eq('id', id);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }
}
