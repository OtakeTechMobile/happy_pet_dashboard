import '../../domain/enums/app_enums.dart';
import '../../domain/models/attendance_model.dart';
import 'base_repository.dart';

/// Repository for attendance operations
class AttendanceRepository extends BaseRepository {
  static const String tableName = 'attendance_log';

  /// Get all attendance records with filters
  Future<List<AttendanceModel>> getAll({
    String? stayId,
    String? petId,
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
    AttendanceStatus? status,
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

      if (startDate != null) {
        query = query.gte('date', startDate.toIso8601String().split('T')[0]);
      }

      if (endDate != null) {
        query = query.lte('date', endDate.toIso8601String().split('T')[0]);
      }

      if (status != null) {
        query = query.eq('status', status.toDbString());
      }

      // Apply range and order after all filters
      query = query.range(offset, offset + limit - 1).order('date', ascending: false);

      final response = await query;
      return (response as List).map((json) => AttendanceModel.fromJson(json)).toList();
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Get attendance for today
  Future<List<AttendanceModel>> getToday({String? petId}) async {
    final today = DateTime.now();
    return getAll(date: today, petId: petId);
  }

  /// Get attendance by ID
  Future<AttendanceModel?> getById(String id) async {
    try {
      final response = await from(tableName).select().eq('id', id).maybeSingle();
      return response != null ? AttendanceModel.fromJson(response) : null;
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Get attendance for a specific stay on a specific date
  Future<AttendanceModel?> getByStayAndDate(String stayId, DateTime date) async {
    try {
      final response = await from(tableName)
          .select()
          .eq('stay_id', stayId)
          .eq('date', date.toIso8601String().split('T')[0])
          .maybeSingle();
      return response != null ? AttendanceModel.fromJson(response) : null;
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Create attendance record
  Future<AttendanceModel> create(AttendanceModel attendance) async {
    try {
      final response = await from(tableName).insert(attendance.toJson()).select().single();
      return AttendanceModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Update attendance record
  Future<AttendanceModel> update(AttendanceModel attendance) async {
    try {
      final response = await from(tableName).update(attendance.toJson()).eq('id', attendance.id).select().single();
      return AttendanceModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Record arrival
  Future<AttendanceModel> recordArrival(String stayId, String petId, String userId) async {
    try {
      final today = DateTime.now();
      final dateStr = today.toIso8601String().split('T')[0];

      // Check if attendance already exists for today
      final existing = await getByStayAndDate(stayId, today);

      if (existing != null) {
        // Update existing record
        final response = await from(tableName)
            .update({
              'arrived_at': DateTime.now().toIso8601String(),
              'status': 'present',
              'recorded_by': userId,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existing.id)
            .select()
            .single();
        return AttendanceModel.fromJson(response);
      } else {
        // Create new record
        final response = await from(tableName)
            .insert({
              'stay_id': stayId,
              'pet_id': petId,
              'date': dateStr,
              'arrived_at': DateTime.now().toIso8601String(),
              'status': 'present',
              'recorded_by': userId,
            })
            .select()
            .single();
        return AttendanceModel.fromJson(response);
      }
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Record departure
  Future<AttendanceModel> recordDeparture(String stayId, String userId) async {
    try {
      final today = DateTime.now();
      final existing = await getByStayAndDate(stayId, today);

      if (existing == null) {
        throw RepositoryException('No attendance record found for today');
      }

      final response = await from(tableName)
          .update({
            'left_at': DateTime.now().toIso8601String(),
            'recorded_by': userId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', existing.id)
          .select()
          .single();
      return AttendanceModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Mark as absent
  Future<AttendanceModel> markAbsent(String stayId, String petId, DateTime date, String userId, {String? notes}) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];

      final response = await from(tableName)
          .insert({
            'stay_id': stayId,
            'pet_id': petId,
            'date': dateStr,
            'status': 'absent',
            'notes': notes,
            'recorded_by': userId,
          })
          .select()
          .single();
      return AttendanceModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Calculate attendance percentage for a period
  Future<double> getAttendanceRate({
    String? petId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      dynamic query = from(tableName).select().gte('date', startDate.toIso8601String().split('T')[0]).lte('date', endDate.toIso8601String().split('T')[0]);

      if (petId != null) {
        query = query.eq('pet_id', petId);
      }

      final response = await query;
      final records = (response as List).map((json) => AttendanceModel.fromJson(json)).toList();

      if (records.isEmpty) return 0.0;

      final present = records.where((r) => r.status == AttendanceStatus.present || r.status == AttendanceStatus.late).length;
      return (present / records.length) * 100;
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Delete attendance record
  Future<void> delete(String id) async {
    try {
      await from(tableName).delete().eq('id', id);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }
}
