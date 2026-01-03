import 'dart:developer';

import 'package:bloc/bloc.dart';

import '../../../../data/repositories/pet_repository.dart';
import '../../../../domain/models/pet_model.dart';
import 'pets_state.dart';

class PetsCubit extends Cubit<PetsState> {
  final PetRepository _repository;

  PetsCubit(this._repository) : super(PetsInitial());

  Future<void> loadPets({String? hotelId}) async {
    emit(PetsLoading());
    try {
      final pets = await _repository.getAll(hotelId: hotelId);
      pets.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      emit(PetsLoaded(pets));
    } catch (e) {
      log(e.toString());
      emit(PetsError(e.toString()));
    }
  }

  Future<void> searchPets(String query, {String? hotelId}) async {
    emit(PetsLoading());
    try {
      final pets = await _repository.getAll(hotelId: hotelId);
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

  Future<void> createPet(PetModel pet, {List<int>? photoBytes, String? fileName}) async {
    emit(PetsLoading());
    try {
      var createdPet = await _repository.create(pet);

      if (photoBytes != null && fileName != null) {
        final photoUrl = await _repository.uploadPhoto(createdPet.id, photoBytes, fileName);
        createdPet = createdPet.copyWith(photoUrl: photoUrl);
        await _repository.update(createdPet);
      }

      await loadPets();
    } catch (e) {
      log(e.toString());
      emit(PetsError(e.toString()));
    }
  }

  Future<void> updatePet(PetModel pet, {List<int>? photoBytes, String? fileName}) async {
    emit(PetsLoading());
    try {
      var petToUpdate = pet;

      if (photoBytes != null && fileName != null) {
        final photoUrl = await _repository.uploadPhoto(pet.id, photoBytes, fileName);
        petToUpdate = pet.copyWith(photoUrl: photoUrl);
      }

      await _repository.update(petToUpdate);
      await loadPets();
    } catch (e) {
      log(e.toString());
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
