import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  final AuthRepository authRepository;

  HotelOwnersCubit(this._hotelRepository, this.authRepository) : super(HotelOwnersInitial());

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
    required List<Map<String, String>> staffData,
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

      // 2. Create the Owner (Auth + Profile).
      await authRepository.signupNewUser(
        fullName: ownerName,
        email: ownerEmail,
        password: ownerPassword,
        role: UserRole.owner,
        hotelId: createdHotel.id,
      );

      // 3. Create Staff (Auth + Profile) (limit 3)
      final limitedStaff = staffData.take(3).toList();
      for (var staff in limitedStaff) {
        if (staff['email']?.isEmpty ?? true) continue;
        await authRepository.signupNewUser(
          fullName: staff['name']!,
          email: staff['email']!,
          password: staff['password']!,
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

  Future<List<Map<String, dynamic>>> getHotelStaff(String hotelId) async {
    try {
      return await _hotelRepository.getStaffMembers(hotelId);
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  Future<void> updateHotel(HotelModel hotel) async {
    emit(HotelOwnersLoading());
    try {
      await _hotelRepository.update(hotel);
      await loadHotels();
    } catch (e) {
      log(e.toString());
      emit(HotelOwnersError(e.toString()));
    }
  }

  Future<void> toggleHotelStatus(HotelModel hotel, bool isActive) async {
    emit(HotelOwnersLoading());
    try {
      await _hotelRepository.update(hotel.copyWith(isActive: isActive));
      await loadHotels();
    } catch (e) {
      log(e.toString());
      emit(HotelOwnersError(e.toString()));
    }
  }

  Future<void> signupStaff({
    required String fullName,
    required String email,
    required String password,
    required String hotelId,
  }) async {
    try {
      await authRepository.signupNewUser(
        fullName: fullName,
        email: email,
        password: password,
        role: UserRole.staff,
        hotelId: hotelId,
      );
    } catch (e) {
      log('Error creating staff: $e');
    }
  }
}
