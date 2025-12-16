import 'package:equatable/equatable.dart';

import '../../../../domain/models/tutor_model.dart';

abstract class ClientsState extends Equatable {
  const ClientsState();

  @override
  List<Object?> get props => [];
}

class ClientsInitial extends ClientsState {}

class ClientsLoading extends ClientsState {}

class ClientsLoaded extends ClientsState {
  final List<TutorModel> clients;

  const ClientsLoaded(this.clients);

  @override
  List<Object?> get props => [clients];
}

class ClientsError extends ClientsState {
  final String message;

  const ClientsError(this.message);

  @override
  List<Object?> get props => [message];
}
