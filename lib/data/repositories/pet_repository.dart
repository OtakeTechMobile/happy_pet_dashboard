import 'dart:developer';
import 'dart:typed_data';

import '../../domain/enums/app_enums.dart';
import '../../domain/models/pet_model.dart';
import 'base_repository.dart';

/// Repository for pet operations
class PetRepository extends BaseRepository {
  static const String tableName = 'pets';

  /// Get all pets with filters
  Future<List<PetModel>> getAll({
    String? tutorId,
    String? hotelId,
    String? species,
    bool? isActive,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      dynamic query = from(tableName).select();

      if (tutorId != null) {
        query = query.eq('tutor_id', tutorId);
      }

      if (hotelId != null && hotelId.isNotEmpty) {
        query = query.eq('hotel_id', hotelId);
      }

      if (species != null) {
        query = query.eq('species', species);
      }

      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }

      // Apply ordering and range AFTER all filters
      query = query.order('created_at', ascending: false).range(offset, offset + limit - 1);

      final response = await query;
      return (response as List).map((json) => PetModel.fromJson(json)).toList();
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Get pet by ID
  Future<PetModel?> getById(String id) async {
    try {
      final response = await from(tableName).select().eq('id', id).maybeSingle();
      return response != null ? PetModel.fromJson(response) : null;
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Get pets by tutor ID
  Future<List<PetModel>> getByTutorId(String tutorId) async {
    try {
      final response = await from(tableName).select().eq('tutor_id', tutorId).order('name');
      return (response as List).map((json) => PetModel.fromJson(json)).toList();
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Get pets with expired vaccinations
  Future<List<PetModel>> getPetsWithExpiredVaccinations() async {
    try {
      final response = await from(tableName).select().eq('is_active', true);
      final pets = (response as List).map((json) => PetModel.fromJson(json)).toList();
      return pets.where((pet) => pet.hasExpiredVaccinations).toList();
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Create new pet
  Future<PetModel> create(PetModel pet) async {
    try {
      final json = pet.toJson();
      if (json['id'] == '') {
        json.remove('id');
      }
      final response = await from(tableName).insert(json).select().single();
      return PetModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      log(error.toString());
      handleError(error, stackTrace);
    }
  }

  /// Update pet
  Future<PetModel> update(PetModel pet) async {
    try {
      final response = await from(tableName).update(pet.toJson()).eq('id', pet.id).select().single();
      return PetModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Delete pet (status change)
  Future<void> delete(String id, {PetStatus status = PetStatus.inactive, String? reason}) async {
    try {
      final pet = await getById(id);
      if (pet == null) return;

      final newHistory = List<PetStatusHistory>.from(pet.statusHistory);
      newHistory.add(PetStatusHistory(status: status, date: DateTime.now(), reason: reason));

      await from(tableName)
          .update({
            'is_active': status == PetStatus.active,
            'status': status.toDbString(),
            'status_history': newHistory.map((h) => h.toJson()).toList(),
          })
          .eq('id', id);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Update pet status with history
  Future<void> updatePetStatus(String id, PetStatus status, {String? reason}) async {
    await delete(id, status: status, reason: reason);
  }

  /// Upload pet photo to Supabase Storage
  Future<String> uploadPhoto(String petId, List<int> photoBytes, String fileName) async {
    try {
      final filePath = 'pets/$petId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      await storage.from('photos').uploadBinary(filePath, Uint8List.fromList(photoBytes));
      final url = storage.from('photos').getPublicUrl(filePath);
      return url;
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Upload vaccination document
  Future<String> uploadVaccinationDocument(String petId, List<int> fileBytes, String fileName) async {
    try {
      final filePath = 'pets/$petId/vaccinations/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      await storage.from('documents').uploadBinary(filePath, Uint8List.fromList(fileBytes));
      final url = storage.from('documents').getPublicUrl(filePath);
      return url;
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }
}
