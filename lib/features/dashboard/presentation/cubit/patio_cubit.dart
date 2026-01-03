import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/daily_log_repository.dart';
import '../../../../data/repositories/pet_repository.dart';
import '../../../../domain/models/daily_log_model.dart';
import 'patio_state.dart';

class PatioCubit extends Cubit<PatioState> {
  final PetRepository _petRepository;
  final DailyLogRepository _logRepository;
  final String hotelId;

  PatioCubit(this._petRepository, this._logRepository, this.hotelId) : super(PatioInitial());

  Future<void> loadPatioData() async {
    emit(PatioLoading());
    try {
      // Filter pets by hotel_id and status 'checked_in' (assuming isActive filter for now as per current DB state)
      final pets = await _petRepository.getAll(isActive: true, hotelId: hotelId);
      final logs = await _logRepository.getByHotelId(hotelId, date: DateTime.now());
      log(pets.map((e) => e.hotelId).toString());
      log(logs.map((e) => e.hotelId).toString());

      emit(PatioLoaded(pets, logs));
    } catch (e) {
      emit(PatioError(e.toString()));
    }
  }

  Future<void> addLog(DailyLogModel log) async {
    try {
      await _logRepository.create(log);
      await loadPatioData();
    } catch (e) {
      emit(PatioError(e.toString()));
    }
  }
}
