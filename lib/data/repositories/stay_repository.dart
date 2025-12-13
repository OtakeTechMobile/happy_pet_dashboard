import '../../domain/enums/app_enums.dart';
import '../../domain/models/stay_model.dart';
import 'base_repository.dart';

/// Repository for stay (reservations) operations
class StayRepository extends BaseRepository {
  static const String tableName = 'stays';

  /// Get all stays with filters
  Future<List<StayModel>> getAll({
    String? petId,
    String? tutorId,
    String? hotelId,
    StayStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      dynamic query = from(tableName).select();

      if (petId != null) {
        query = query.eq('pet_id', petId);
      }

      if (tutorId != null) {
        query = query.eq('tutor_id', tutorId);
      }

      if (hotelId != null) {
        query = query.eq('hotel_id', hotelId);
      }

      if (status != null) {
        query = query.eq('status', status.toDbString());
      }

      if (startDate != null) {
        query = query.gte('scheduled_checkin', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('scheduled_checkout', endDate.toIso8601String());
      }

      // Apply ordering and range AFTER all filters
      query = query.order('scheduled_checkin', ascending: false).range(offset, offset + limit - 1);

      final response = await query;
      return (response as List).map((json) => StayModel.fromJson(json)).toList();
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Get stay by ID
  Future<StayModel?> getById(String id) async {
    try {
      final response = await from(tableName).select().eq('id', id).maybeSingle();
      return response != null ? StayModel.fromJson(response) : null;
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Get active stays (checked in)
  Future<List<StayModel>> getActiveStays({String? hotelId}) async {
    try {
      var query = from(tableName).select().eq('status', 'checked_in');

      if (hotelId != null) {
        query = query.eq('hotel_id', hotelId);
      }

      final response = await query;
      return (response as List).map((json) => StayModel.fromJson(json)).toList();
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Get stays with early departures
  Future<List<StayModel>> getEarlyDepartures({String? hotelId, DateTime? afterDate}) async {
    try {
      var query = from(tableName).select().eq('status', 'checked_out');

      if (hotelId != null) {
        query = query.eq('hotel_id', hotelId);
      }

      if (afterDate != null) {
        query = query.gte('actual_checkout', afterDate.toIso8601String());
      }

      final response = await query;
      final stays = (response as List).map((json) => StayModel.fromJson(json)).toList();
      return stays.where((stay) => stay.isEarlyDeparture).toList();
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Create new stay/reservation
  Future<StayModel> create(StayModel stay) async {
    try {
      final response = await from(tableName).insert(stay.toJson()).select().single();
      return StayModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Update stay
  Future<StayModel> update(StayModel stay) async {
    try {
      final response = await from(tableName).update(stay.toJson()).eq('id', stay.id).select().single();
      return StayModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Check in a stay
  Future<StayModel> checkIn(String stayId, String userId) async {
    try {
      final response = await from(tableName)
          .update({
            'status': 'checked_in',
            'actual_checkin': DateTime.now().toIso8601String(),
            'check_in_by': userId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', stayId)
          .select()
          .single();
      return StayModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Check out a stay
  Future<StayModel> checkOut(String stayId, String userId) async {
    try {
      final response = await from(tableName)
          .update({
            'status': 'checked_out',
            'actual_checkout': DateTime.now().toIso8601String(),
            'check_out_by': userId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', stayId)
          .select()
          .single();
      return StayModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Cancel a stay
  Future<StayModel> cancel(String stayId, String userId, String reason) async {
    try {
      final response = await from(tableName)
          .update({
            'status': 'cancelled',
            'cancelled_at': DateTime.now().toIso8601String(),
            'cancelled_by': userId,
            'cancellation_reason': reason,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', stayId)
          .select()
          .single();
      return StayModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }
}
