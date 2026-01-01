import '../../domain/models/daily_log_model.dart';
import 'base_repository.dart';

class DailyLogRepository extends BaseRepository {
  static const String tableName = 'daily_logs';

  Future<List<DailyLogModel>> getByPetId(String petId) async {
    try {
      final response = await from(tableName).select().eq('pet_id', petId).order('created_at', ascending: false);
      return (response as List).map((json) => DailyLogModel.fromJson(json)).toList();
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  Future<List<DailyLogModel>> getByHotelId(String hotelId, {DateTime? date}) async {
    try {
      var query = from(tableName).select();
      
      if (hotelId.isNotEmpty) {
        query = query.eq('hotel_id', hotelId);
      }

      if (date != null) {
        final startOfDay = DateTime(date.year, date.month, date.day).toIso8601String();
        final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59).toIso8601String();
        query = query.gte('created_at', startOfDay).lte('created_at', endOfDay);
      }

      final response = await query.order('created_at', ascending: false);
      return (response as List).map((json) => DailyLogModel.fromJson(json)).toList();
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  Future<DailyLogModel> create(DailyLogModel log) async {
    try {
      final json = log.toJson();
      final response = await from(tableName).insert(json).select().single();
      return DailyLogModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }
}
