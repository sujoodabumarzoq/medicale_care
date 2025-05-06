import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/doctor_repository.dart';
import 'doctor_state.dart';

class DoctorCubit extends Cubit<DoctorState> {
  final DoctorRepository _doctorRepository;

  DoctorCubit({required DoctorRepository doctorRepository})
      : _doctorRepository = doctorRepository,
        super(const DoctorState());

  Future<void> loadAllDoctors() async {
    emit(state.copyWith(status: DoctorStatus.loading));

    try {
      final doctors = await _doctorRepository.getAllDoctors();
      emit(state.copyWith(
        status: DoctorStatus.loaded,
        doctors: doctors,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DoctorStatus.error,
        errorMessage: 'Failed to load doctors: ${e.toString()}',
      ));
    }
  }

  Future<void> loadPopularDoctors() async {
    emit(state.copyWith(status: DoctorStatus.loading));

    try {
      final doctors = await _doctorRepository.getPopularDoctors();
      emit(state.copyWith(
        status: DoctorStatus.loaded,
        popularDoctors: doctors,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DoctorStatus.error,
        errorMessage: 'Failed to load popular doctors: ${e.toString()}',
      ));
    }
  }

  Future<void> loadDoctorsBySpecialty(String specialtyId) async {
    emit(state.copyWith(
      status: DoctorStatus.loading,
      selectedSpecialtyId: specialtyId,
    ));

    try {
      final doctors = await _doctorRepository.getDoctorsBySpecialty(specialtyId);
      emit(state.copyWith(
        status: DoctorStatus.loaded,
        doctors: doctors,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DoctorStatus.error,
        errorMessage: 'Failed to load doctors by specialty: ${e.toString()}',
      ));
    }
  }

  Future<void> loadDoctorDetails(String doctorId) async {
    emit(state.copyWith(status: DoctorStatus.loading));

    try {
      final doctor = await _doctorRepository.getDoctorById(doctorId);
      if (doctor != null) {
        emit(state.copyWith(
          status: DoctorStatus.loaded,
          selectedDoctor: doctor,
        ));
      } else {
        emit(state.copyWith(
          status: DoctorStatus.error,
          errorMessage: 'Doctor not found',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: DoctorStatus.error,
        errorMessage: 'Failed to load doctor details: ${e.toString()}',
      ));
    }
  }

  Future<void> searchDoctors(String query) async {
    if (query.trim().isEmpty) {
      loadAllDoctors();
      return;
    }

    emit(state.copyWith(status: DoctorStatus.loading));

    try {
      // Filter doctors based on the search query
      final filteredDoctors = state.doctors.where((doctor) {
        final fullName = doctor.user.fullName.toLowerCase();
        return fullName.contains(query.toLowerCase());
      }).toList();

      emit(state.copyWith(
        status: DoctorStatus.loaded,
        doctors: filteredDoctors,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DoctorStatus.error,
        errorMessage: 'Search failed: ${e.toString()}',
      ));
    }
  }

  Future<bool> toggleDoctorAvailability({
    required String doctorId,
    required bool isAvailable,
  }) async {
    emit(state.copyWith(status: DoctorStatus.loading));

    try {
      final success = await _doctorRepository.toggleDoctorAvailability(doctorId, isAvailable);

      if (success) {
        // If toggle was successful, reload the doctor details to update the UI
        await loadDoctorDetails(doctorId);
        return true;
      } else {
        emit(state.copyWith(
          status: DoctorStatus.error,
          errorMessage: 'Failed to update availability status',
        ));
        return false;
      }
    } catch (e) {
      emit(state.copyWith(
        status: DoctorStatus.error,
        errorMessage: 'Failed to update availability: ${e.toString()}',
      ));
      return false;
    }
  }
}
