import 'package:equatable/equatable.dart';

import '../../../../domain/models/daily_log_model.dart';
import '../../../../domain/models/pet_model.dart';

abstract class PatioState extends Equatable {
  const PatioState();
  @override
  List<Object?> get props => [];
}

class PatioInitial extends PatioState {}

class PatioLoading extends PatioState {}

class PatioLoaded extends PatioState {
  final List<PetModel> activePets;
  final List<DailyLogModel> todayLogs;

  const PatioLoaded(this.activePets, this.todayLogs);

  @override
  List<Object?> get props => [activePets, todayLogs];
}

class PatioError extends PatioState {
  final String message;
  const PatioError(this.message);

  @override
  List<Object?> get props => [message];
}
