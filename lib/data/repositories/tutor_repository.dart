import 'dart:typed_data';

import '../../domain/models/tutor_model.dart';
import 'base_repository.dart';

/// Repository for tutor operations
class TutorRepository extends BaseRepository {
  static const String tableName = 'tutors';

  /// Get all tutors with pagination
  Future<List<TutorModel>> getAll({
    int limit = 50,
    int offset = 0,
    String? searchQuery,
    String? hotelId,
    bool? isActive,
  }) async {
    try {
      dynamic query = from(tableName).select();

      // Apply filters first
      if (hotelId != null && hotelId.isNotEmpty) {
        query = query.eq('hotel_id', hotelId);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('full_name.ilike.%$searchQuery%,email.ilike.%$searchQuery%,cpf.ilike.%$searchQuery%');
      }

      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }

      // Then apply pagination and ordering
      query = query.range(offset, offset + limit - 1).order('created_at', ascending: false);

      final response = await query;
      return (response as List).map((json) => TutorModel.fromJson(json)).toList();
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Get tutor by ID
  Future<TutorModel?> getById(String id) async {
    try {
      final response = await from(tableName).select().eq('id', id).maybeSingle();
      return response != null ? TutorModel.fromJson(response) : null;
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Get tutor by email
  Future<TutorModel?> getByEmail(String email) async {
    try {
      final response = await from(tableName).select().eq('email', email).maybeSingle();
      return response != null ? TutorModel.fromJson(response) : null;
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Create new tutor
  Future<TutorModel> create(TutorModel tutor) async {
    try {
      final json = tutor.toJson();
      if (json['id'] == '') {
        json.remove('id');
      }
      final response = await from(tableName).insert(json).select().single();
      return TutorModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Update tutor
  Future<TutorModel> update(TutorModel tutor) async {
    try {
      final oldTutor = await getById(tutor.id);
      final response = await from(tableName).update(tutor.toJson()).eq('id', tutor.id).select().single();
      final updatedTutor = TutorModel.fromJson(response);

      // Cascade hotel_id update to pets if hotel_id changed
      if (oldTutor != null && oldTutor.hotelId != tutor.hotelId) {
        await from('pets').update({'hotel_id': tutor.hotelId}).eq('tutor_id', tutor.id);
      }

      return updatedTutor;
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Delete tutor (soft delete)
  Future<void> delete(String id) async {
    try {
      await from(tableName).update({'is_active': false}).eq('id', id);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Upload tutor document to Supabase Storage
  Future<String> uploadDocument(String tutorId, String filePath, List<int> fileBytes) async {
    try {
      final fileName = 'tutors/$tutorId/${DateTime.now().millisecondsSinceEpoch}_${filePath.split('/').last}';
      await storage.from('documents').uploadBinary(fileName, Uint8List.fromList(fileBytes));
      final url = storage.from('documents').getPublicUrl(fileName);
      return url;
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }
}
