import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/hotel_repository.dart';
import '../../../../domain/enums/app_enums.dart';
import '../../../../domain/models/hotel_model.dart';

abstract class HotelOwnersState extends Equatable {
  const HotelOwnersState();
  @override
  List<Object?> get props => [];
}

class HotelOwnersInitial extends HotelOwnersState {}
class HotelOwnersLoading extends HotelOwnersState {}
class HotelOwnersLoaded extends HotelOwnersState {
  final List<HotelModel> hotels;
  const HotelOwnersLoaded(this.hotels);
  @override
  List<Object?> get props => [hotels];
}
class HotelOwnersError extends HotelOwnersState {
  final String message;
  const HotelOwnersError(this.message);
  @override
  List<Object?> get props => [message];
}

class HotelOwnersCubit extends Cubit<HotelOwnersState> {
  final HotelRepository _hotelRepository;
  final AuthRepository _authRepository;

  HotelOwnersCubit(this._hotelRepository, this._authRepository) : super(HotelOwnersInitial());

  Future<void> loadHotels() async {
    emit(HotelOwnersLoading());
    try {
      final hotels = await _hotelRepository.getAll();
      emit(HotelOwnersLoaded(hotels));
    } catch (e) {
      log(e.toString());
      emit(HotelOwnersError(e.toString()));
    }
  }

  Future<void> registerHotelWithOwner({
    required String hotelName,
    required String ownerName,
    required String ownerEmail,
    required String ownerPassword,
    required List<String> staffNames,
  }) async {
    emit(HotelOwnersLoading());
    try {
      // 1. Create Hotel
      final newHotel = HotelModel(
        id: '',
        name: hotelName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        maxStaff: 3,
      );
      final createdHotel = await _hotelRepository.create(newHotel);

      // 2. Ideally, we would use a Supabase Function (Edge Function) or Admin API to create users without logging out.
      // Since this is a dashboard context, we might be limited by Supabase Client auth.
      // For this implementation, we'll simulate the user creation in the database table 'users' directly
      // if the RLS allows, or assume we have an admin service.
      
      // In a real production app with Supabase, you'd use service_role to create auth users.
      // Here, we'll create the Owner profile.
      const uuid = Uuid();
      await _authRepository.createUserProfile(
        userId: uuid.v4(), // Use valid UUID
        fullName: ownerName,
        role: UserRole.owner,
        hotelId: createdHotel.id,
      );

      // 3. Create Staff profiles (limit 3)
      final limitedStaff = staffNames.take(3).toList();
      for (var name in limitedStaff) {
        await _authRepository.createUserProfile(
          userId: uuid.v4(), // Use valid UUID
          fullName: name,
          role: UserRole.staff,
          hotelId: createdHotel.id,
        );
      }

      await loadHotels();
    } catch (e) {
      log(e.toString());
      emit(HotelOwnersError(e.toString()));
    }
  }
}
