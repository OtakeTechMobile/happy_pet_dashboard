import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/hotel_repository.dart';
import '../../../../domain/models/hotel_model.dart';
import 'hotel_state.dart';

class HotelCubit extends Cubit<HotelState> {
  final HotelRepository _repository;

  HotelCubit(this._repository) : super(const HotelState());

  Future<void> loadHotel(String hotelId) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final hotel = await _repository.getById(hotelId);
      emit(state.copyWith(isLoading: false, hotel: hotel));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadFirstHotel() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final hotels = await _repository.getAll();
      if (hotels.isNotEmpty) {
        emit(state.copyWith(isLoading: false, hotel: hotels.first));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> saveHotel(HotelModel hotel) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      if (hotel.id.isEmpty) {
        // Assuming creating a new one if ID is empty, though usually we might have one per account
        final newHotel = await _repository.create(hotel);
        emit(state.copyWith(isLoading: false, hotel: newHotel));
      } else {
        final updatedHotel = await _repository.update(hotel);
        emit(state.copyWith(isLoading: false, hotel: updatedHotel));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
