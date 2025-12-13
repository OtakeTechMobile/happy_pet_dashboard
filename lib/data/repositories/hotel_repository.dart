import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/hotel_model.dart';
import 'base_repository.dart';

/// Repository for hotel operations
class HotelRepository extends BaseRepository {
  static const String tableName = 'hotels';

  /// Get all hotels
  Future<List<HotelModel>> getAll({bool? isActive}) async {
    try {
      dynamic query = from(tableName).select();

      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }

      // Apply ordering AFTER all filters
      query = query.order('name');

      final response = await query;
      return (response as List).map((json) => HotelModel.fromJson(json)).toList();
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Get hotel by ID
  Future<HotelModel?> getById(String id) async {
    try {
      final response = await from(tableName).select().eq('id', id).maybeSingle();
      return response != null ? HotelModel.fromJson(response) : null;
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Create hotel
  Future<HotelModel> create(HotelModel hotel) async {
    try {
      final data = hotel.toJson();
      if (hotel.id.isEmpty) {
        data.remove('id');
      }
      final response = await from(tableName).insert(data).select().single();
      return HotelModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Update hotel
  Future<HotelModel> update(HotelModel hotel) async {
    try {
      final data = hotel.toJson();
      data['updated_at'] = DateTime.now().toIso8601String();
      final response = await from(tableName).update(data).eq('id', hotel.id).select().single();
      return HotelModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Delete hotel (soft delete)
  Future<void> delete(String id) async {
    try {
      await from(tableName).update({'is_active': false}).eq('id', id);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Get current occupancy for a hotel
  Future<int> getCurrentOccupancy(String hotelId) async {
    try {
      final response = await from(
        'stays',
      ).select('id').eq('hotel_id', hotelId).eq('status', 'checked_in').count(CountOption.exact);

      // The count is returned in the count property
      return response.count;
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Get occupancy percentage
  Future<double> getOccupancyRate(String hotelId) async {
    try {
      final hotel = await getById(hotelId);
      if (hotel == null || hotel.capacity == 0) return 0.0;

      final occupied = await getCurrentOccupancy(hotelId);
      return (occupied / hotel.capacity) * 100;
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }
}
