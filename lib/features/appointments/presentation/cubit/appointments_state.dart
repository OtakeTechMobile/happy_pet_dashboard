import 'package:equatable/equatable.dart';

import '../../../../domain/models/routine_model.dart';

class AppointmentViewModel extends Equatable {
  final RoutineModel routine;
  final String petName;
  final String clientName;

  const AppointmentViewModel({required this.routine, required this.petName, required this.clientName});

  @override
  List<Object?> get props => [routine, petName, clientName];
}

abstract class AppointmentsState extends Equatable {
  const AppointmentsState();

  @override
  List<Object?> get props => [];
}

class AppointmentsInitial extends AppointmentsState {}

class AppointmentsLoading extends AppointmentsState {}

class AppointmentsLoaded extends AppointmentsState {
  final List<AppointmentViewModel> appointments;

  const AppointmentsLoaded(this.appointments);

  @override
  List<Object?> get props => [appointments];
}

class AppointmentsError extends AppointmentsState {
  final String message;

  const AppointmentsError(this.message);

  @override
  List<Object?> get props => [message];
}
