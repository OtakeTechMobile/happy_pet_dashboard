import 'package:bloc/bloc.dart';

import '../../../../data/repositories/tutor_repository.dart';
import '../../../../domain/models/tutor_model.dart';
import 'clients_state.dart';

class ClientsCubit extends Cubit<ClientsState> {
  final TutorRepository _repository;

  ClientsCubit(this._repository) : super(ClientsInitial());

  Future<void> loadClients() async {
    emit(ClientsLoading());
    try {
      final clients = await _repository.getAll();
      emit(ClientsLoaded(clients));
    } catch (e) {
      emit(ClientsError(e.toString()));
    }
  }

  Future<void> searchClients(String query) async {
    emit(ClientsLoading());
    try {
      // Assuming getTutors has a name filter or we filter locally.
      // Checking TutorRepository: it has getTutors({String? query, ...}) ?
      // I'll check the repository definition again.
      // If not, I'll filter locally for now or update repository.
      final clients = await _repository.getAll(searchQuery: query);
      emit(ClientsLoaded(clients));
    } catch (e) {
      emit(ClientsError(e.toString()));
    }
  }

  Future<void> createClient(TutorModel client) async {
    emit(ClientsLoading());
    try {
      await _repository.create(client);
      await loadClients();
    } catch (e) {
      emit(ClientsError(e.toString()));
    }
  }

  Future<void> updateClient(TutorModel client) async {
    emit(ClientsLoading());
    try {
      await _repository.update(client);
      await loadClients();
    } catch (e) {
      emit(ClientsError(e.toString()));
    }
  }

  Future<void> deleteClient(String id) async {
    emit(ClientsLoading());
    try {
      await _repository.delete(id);
      await loadClients();
    } catch (e) {
      emit(ClientsError(e.toString()));
    }
  }
}
