import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/emergency_repository.dart';
import 'emergency_state.dart';

class EmergencyCubit extends Cubit<EmergencyState> {
  final EmergencyRepository _emergencyRepository;

  EmergencyCubit({required EmergencyRepository emergencyRepository})
      : _emergencyRepository = emergencyRepository,
        super(const EmergencyState());

  Future<void> loadAllEmergencyContacts() async {
    emit(state.copyWith(status: EmergencyStatus.loading));

    try {
      final contacts = await _emergencyRepository.getAllEmergencyContacts();
      emit(state.copyWith(
        status: EmergencyStatus.loaded,
        contacts: contacts,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: EmergencyStatus.error,
        errorMessage: 'Failed to load emergency contacts: ${e.toString()}',
      ));
    }
  }

  Future<void> loadEmergencyContactsByType(String type) async {
    emit(state.copyWith(
      status: EmergencyStatus.loading,
      selectedType: type,
    ));

    try {
      final contacts = await _emergencyRepository.getEmergencyContactsByType(type);
      emit(state.copyWith(
        status: EmergencyStatus.loaded,
        contacts: contacts,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: EmergencyStatus.error,
        errorMessage: 'Failed to load emergency contacts: ${e.toString()}',
      ));
    }
  }

  Future<void> loadNearestHospitals() async {
    emit(state.copyWith(status: EmergencyStatus.loading));

    try {
      final hospitals = await _emergencyRepository.getNearestHospitals();
      emit(state.copyWith(
        status: EmergencyStatus.loaded,
        nearestHospitals: hospitals,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: EmergencyStatus.error,
        errorMessage: 'Failed to load nearest hospitals: ${e.toString()}',
      ));
    }
  }

  void filterByType(String? type) {
    emit(state.copyWith(selectedType: type));
  }
}
