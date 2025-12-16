import 'dart:developer';

import 'package:bloc/bloc.dart';

import '../../../../data/repositories/pet_repository.dart';
import '../../../../domain/models/pet_model.dart';
import 'pets_state.dart';

class PetsCubit extends Cubit<PetsState> {
  final PetRepository _repository;

  PetsCubit(this._repository) : super(PetsInitial());

  Future<void> loadPets() async {
    emit(PetsLoading());
    try {
      final pets = await _repository.getAll();
      pets.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      emit(PetsLoaded(pets));
    } catch (e) {
      log(e.toString());
      emit(PetsError(e.toString()));
    }
  }

  Future<void> searchPets(String query) async {
    emit(PetsLoading());
    try {
      // PetRepository has getAll(tutorId, species, isActive...). Not explicit search query for name?
      // Checking PetRepository (step 12 view_file):
      // Future<List<PetModel>> getAll({String? tutorId, String? species, bool? isActive...})
      // It DOES NOT have a text search query for name.
      // I should update PetRepository to support name search or filter locally.
      // I'll filter locally for now to avoid modifying Repository interface recursively (and maybe breaking other things),
      // OR I can modify repository. Modifying repository is better.
      // But `PetRepository` was using `from('pets').select().eq...`.
      // I'd need to add `.ilike('name', '%$query%')`.

      // I'll do LOCAL filtering in the Cubit for now to be safe and fast,
      // since I fetch all pets anyway (default limit 50).

      final pets = await _repository.getAll();
      if (query.isNotEmpty) {
        final filtered = pets.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
        emit(PetsLoaded(filtered));
      } else {
        emit(PetsLoaded(pets));
      }
    } catch (e) {
      emit(PetsError(e.toString()));
    }
  }

  Future<void> createPet(PetModel pet) async {
    emit(PetsLoading());
    try {
      await _repository.create(pet);
      await loadPets();
    } catch (e) {
      emit(PetsError(e.toString()));
    }
  }

  Future<void> updatePet(PetModel pet) async {
    emit(PetsLoading());
    try {
      await _repository.update(pet);
      await loadPets();
    } catch (e) {
      emit(PetsError(e.toString()));
    }
  }

  Future<void> deletePet(String id) async {
    emit(PetsLoading());
    try {
      await _repository.delete(id);
      await loadPets();
    } catch (e) {
      emit(PetsError(e.toString()));
    }
  }
}
