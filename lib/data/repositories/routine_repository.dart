import '../../domain/enums/app_enums.dart';
import '../../domain/models/routine_model.dart';
import 'base_repository.dart';

/// Repository for routine operations
class RoutineRepository extends BaseRepository {
  static const String tableName = 'routines';

  /// Get all routines with filters
  Future<List<RoutineModel>> getAll({
    String? stayId,
    String? petId,
    DateTime? date,
    RoutineType? type,
    RoutineStatus? status,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      dynamic query = from(tableName).select();

      if (stayId != null) {
        query = query.eq('stay_id', stayId);
      }

      if (petId != null) {
        query = query.eq('pet_id', petId);
      }

      if (date != null) {
        query = query.eq('date', date.toIso8601String().split('T')[0]);
      }

      if (type != null) {
        query = query.eq('type', type.name);
      }

      if (status != null) {
        query = query.eq('status', status.toDbString());
      }

      // Apply ordering and range AFTER all filters
      query = query.order('scheduled_time').range(offset, offset + limit - 1);

      final response = await query;
      return (response as List).map((json) => RoutineModel.fromJson(json)).toList();
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Get routines for today
  Future<List<RoutineModel>> getToday({String? petId, RoutineType? type}) async {
    final today = DateTime.now();
    return getAll(date: today, petId: petId, type: type);
  }

  /// Get feeding routines for today
  Future<List<RoutineModel>> getTodayFeeding({String? petId}) async {
    return getToday(petId: petId, type: RoutineType.feeding);
  }

  /// Get routine by ID
  Future<RoutineModel?> getById(String id) async {
    try {
      final response = await from(tableName).select().eq('id', id).maybeSingle();
      return response != null ? RoutineModel.fromJson(response) : null;
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Create new routine
  Future<RoutineModel> create(RoutineModel routine) async {
    try {
      final json = routine.toJson();
      if (json['id'] == '') {
        json.remove('id');
      }
      final response = await from(tableName).insert(json).select().single();
      return RoutineModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Update routine
  Future<RoutineModel> update(RoutineModel routine) async {
    try {
      final response = await from(tableName).update(routine.toJson()).eq('id', routine.id).select().single();
      return RoutineModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Start routine (mark as in progress)
  Future<RoutineModel> startRoutine(String routineId, String userId) async {
    try {
      final response = await from(tableName)
          .update({
            'status': 'in_progress',
            'started_at': DateTime.now().toIso8601String(),
            'assigned_to': userId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', routineId)
          .select()
          .single();
      return RoutineModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Complete routine
  Future<RoutineModel> completeRoutine(String routineId, String userId, {String? notes}) async {
    try {
      final updateData = {
        'status': 'completed',
        'completed_at': DateTime.now().toIso8601String(),
        'completed_by': userId,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (notes != null) {
        updateData['notes'] = notes;
      }

      final response = await from(tableName).update(updateData).eq('id', routineId).select().single();
      return RoutineModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Skip routine
  Future<RoutineModel> skipRoutine(String routineId, String reason) async {
    try {
      final response = await from(tableName)
          .update({'status': 'skipped', 'notes': reason, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', routineId)
          .select()
          .single();
      return RoutineModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Delete routine
  Future<void> delete(String id) async {
    try {
      await from(tableName).delete().eq('id', id);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Calculate feeding completion percentage for today
  Future<double> getTodayFeedingCompletionRate({String? hotelId}) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      var query = from(tableName).select().eq('type', 'feeding').eq('date', today);

      // Note: Would need to join with stays to filter by hotel_id
      // For now, just get all feeding routines for today

      final response = await query;
      final routines = (response as List).map((json) => RoutineModel.fromJson(json)).toList();

      if (routines.isEmpty) return 0.0;

      final completed = routines.where((r) => r.status == RoutineStatus.completed).length;
      return (completed / routines.length) * 100;
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }
}
