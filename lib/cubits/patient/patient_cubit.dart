import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/patient_repository.dart';
import 'patient_state.dart';

class PatientCubit extends Cubit<PatientState> {
  final PatientRepository _patientRepository;

  PatientCubit({required PatientRepository patientRepository})
      : _patientRepository = patientRepository,
        super(const PatientState());

  Future<void> loadPatientProfile(String patientId) async {
    emit(state.copyWith(status: PatientStatus.loading));

    try {
      final patient = await _patientRepository.getPatientById(patientId);

      if (patient != null) {
        emit(state.copyWith(
          status: PatientStatus.loaded,
          patient: patient,
        ));
      } else {
        emit(state.copyWith(
          status: PatientStatus.error,
          errorMessage: 'Patient profile not found',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: PatientStatus.error,
        errorMessage: 'Failed to load patient profile: ${e.toString()}',
      ));
    }
  }

  Future<bool> updatePatientProfile({
    required String patientId,
    DateTime? dateOfBirth,
    String? bloodType,
    String? allergies,
    String? medicalHistory,
  }) async {
    emit(state.copyWith(status: PatientStatus.updating));

    try {
      final success = await _patientRepository.updatePatientProfile(
        patientId: patientId,
        dateOfBirth: dateOfBirth,
        bloodType: bloodType,
        allergies: allergies,
        medicalHistory: medicalHistory,
      );

      if (success) {
        await loadPatientProfile(patientId);
        emit(state.copyWith(status: PatientStatus.updated));
      } else {
        emit(state.copyWith(
          status: PatientStatus.error,
          errorMessage: 'Failed to update patient profile',
        ));
      }

      return success;
    } catch (e) {
      emit(state.copyWith(
        status: PatientStatus.error,
        errorMessage: 'Failed to update patient profile: ${e.toString()}',
      ));
      return false;
    }
  }
}
