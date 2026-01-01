import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/daily_log_repository.dart';
import '../../../../data/repositories/pet_repository.dart';
import '../../../../domain/models/daily_log_model.dart';
import 'patio_state.dart';

class PatioCubit extends Cubit<PatioState> {
  final PetRepository _petRepository;
  final DailyLogRepository _logRepository;

  PatioCubit(this._petRepository, this._logRepository) : super(PatioInitial());

  Future<void> loadPatioData(String hotelId) async {
    emit(PatioLoading());
    try {
      // Filter pets by hotel_id and status 'checked_in' (assuming isActive filter for now as per current DB state)
      final pets = await _petRepository.getAll(isActive: true, hotelId: hotelId);
      final logs = await _logRepository.getByHotelId(hotelId, date: DateTime.now());

      emit(PatioLoaded(pets, logs));
    } catch (e) {
      emit(PatioError(e.toString()));
    }
  }

  Future<void> addLog(DailyLogModel log, String hotelId) async {
    try {
      await _logRepository.create(log);
      await loadPatioData(hotelId);
    } catch (e) {
      emit(PatioError(e.toString()));
    }
  }
}
