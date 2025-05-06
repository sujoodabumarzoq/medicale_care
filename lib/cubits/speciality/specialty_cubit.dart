import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/specialty_repository.dart';
import 'specialty_state.dart';

class SpecialtyCubit extends Cubit<SpecialtyState> {
  final SpecialtyRepository _specialtyRepository;

  SpecialtyCubit({required SpecialtyRepository specialtyRepository})
      : _specialtyRepository = specialtyRepository,
        super(const SpecialtyState());

  Future<void> loadAllSpecialties() async {
    emit(state.copyWith(status: SpecialtyStatus.loading));

    try {
      final specialties = await _specialtyRepository.getAllSpecialties();
      emit(state.copyWith(
        status: SpecialtyStatus.loaded,
        specialties: specialties,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SpecialtyStatus.error,
        errorMessage: 'Failed to load specialties: ${e.toString()}',
      ));
    }
  }

  Future<void> loadSpecialtyDetails(String specialtyId) async {
    emit(state.copyWith(status: SpecialtyStatus.loading));

    try {
      final specialty = await _specialtyRepository.getSpecialtyById(specialtyId);
      if (specialty != null) {
        emit(state.copyWith(
          status: SpecialtyStatus.loaded,
          selectedSpecialty: specialty,
        ));
      } else {
        emit(state.copyWith(
          status: SpecialtyStatus.error,
          errorMessage: 'Specialty not found',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: SpecialtyStatus.error,
        errorMessage: 'Failed to load specialty details: ${e.toString()}',
      ));
    }
  }

  void selectSpecialty(String specialtyId) {
    final specialty = state.specialties.firstWhere(
      (s) => s.id == specialtyId,
      orElse: () => state.specialties.first,
    );

    emit(state.copyWith(selectedSpecialty: specialty));
  }
}
