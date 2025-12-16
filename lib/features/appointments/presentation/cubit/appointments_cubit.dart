import 'dart:developer';

import 'package:bloc/bloc.dart';

import '../../../../data/repositories/pet_repository.dart';
import '../../../../data/repositories/routine_repository.dart';
import '../../../../data/repositories/tutor_repository.dart';
import '../../../../domain/models/routine_model.dart';
import 'appointments_state.dart';

class AppointmentsCubit extends Cubit<AppointmentsState> {
  final RoutineRepository _routineRepository;
  final PetRepository _petRepository;
  final TutorRepository _tutorRepository;

  AppointmentsCubit({
    required RoutineRepository routineRepository,
    required PetRepository petRepository,
    required TutorRepository tutorRepository,
  }) : _routineRepository = routineRepository,
       _petRepository = petRepository,
       _tutorRepository = tutorRepository,
       super(AppointmentsInitial());

  Future<void> loadAppointments() async {
    emit(AppointmentsLoading());
    try {
      final routines = await _routineRepository.getAll();
      final pets = await _petRepository.getAll();
      final tutors = await _tutorRepository.getAll();

      final viewModels = routines.map((routine) {
        final pet = pets.firstWhere(
          (p) => p.id == routine.petId,
          orElse: () => pets.isEmpty ? pets.first : pets[0],
        ); // Fallback risky but ensures no crash if data inconsistent (e.g. mock data mismatch).
        // Better fallback:
        final petName = pets.any((p) => p.id == routine.petId)
            ? pets.firstWhere((p) => p.id == routine.petId).name
            : 'Unknown Pet';

        final petTutorId = pets.any((p) => p.id == routine.petId)
            ? pets.firstWhere((p) => p.id == routine.petId).tutorId
            : '';

        final clientName = tutors.any((t) => t.id == petTutorId)
            ? tutors.firstWhere((t) => t.id == petTutorId).fullName
            : 'Unknown Client';

        return AppointmentViewModel(routine: routine, petName: petName, clientName: clientName);
      }).toList();

      emit(AppointmentsLoaded(viewModels));
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  Future<void> createAppointment(RoutineModel routine) async {
    emit(AppointmentsLoading());
    try {
      await _routineRepository.create(routine);
      await loadAppointments();
    } catch (e) {
      log(e.toString());
      emit(AppointmentsError(e.toString()));
    }
  }

  Future<void> updateAppointment(RoutineModel routine) async {
    emit(AppointmentsLoading());
    try {
      await _routineRepository.update(routine);
      await loadAppointments();
    } catch (e) {
      log(e.toString());
      emit(AppointmentsError(e.toString()));
    }
  }

  Future<void> deleteAppointment(String id) async {
    emit(AppointmentsLoading());
    try {
      await _routineRepository.delete(id);
      await loadAppointments();
    } catch (e) {
      log(e.toString());
      emit(AppointmentsError(e.toString()));
    }
  }
}
