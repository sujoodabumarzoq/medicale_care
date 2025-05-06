import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/appointment_repository.dart';
import '../../repositories/doctor_repository.dart';
import 'appointment_state.dart';

class AppointmentCubit extends Cubit<AppointmentState> {
  final AppointmentRepository _appointmentRepository;
  final DoctorRepository _doctorRepository;

  AppointmentCubit({
    required AppointmentRepository appointmentRepository,
    required DoctorRepository doctorRepository,
  })  : _appointmentRepository = appointmentRepository,
        _doctorRepository = doctorRepository,
        super(const AppointmentState());

  Future<void> loadPatientAppointments(String patientId) async {
    emit(state.copyWith(status: AppointmentStatus.loadingAppointments));

    try {
      final appointments = await _appointmentRepository.getPatientAppointments(patientId);
      emit(state.copyWith(
        status: AppointmentStatus.appointmentsLoaded,
        appointments: appointments,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AppointmentStatus.error,
        errorMessage: 'Failed to load appointments: ${e.toString()}',
      ));
    }
  }

  Future<void> loadDoctorAppointments(String doctorId) async {
    emit(state.copyWith(status: AppointmentStatus.loadingAppointments));

    try {
      final appointments = await _appointmentRepository.getDoctorAppointments(doctorId);
      emit(state.copyWith(
        status: AppointmentStatus.appointmentsLoaded,
        appointments: appointments,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AppointmentStatus.error,
        errorMessage: 'Failed to load appointments: ${e.toString()}',
      ));
    }
  }

  Future<void> loadDoctorAvailability(String doctorId) async {
    emit(state.copyWith(status: AppointmentStatus.loadingAvailabilities));

    try {
      final availabilities = await _doctorRepository.getDoctorAvailability(doctorId);
      emit(state.copyWith(
        status: AppointmentStatus.availabilitiesLoaded,
        availabilities: availabilities,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AppointmentStatus.error,
        errorMessage: 'Failed to load doctor availability: ${e.toString()}',
      ));
    }
  }

  void selectDate(DateTime date) {
    emit(state.copyWith(
      selectedDate: date,
      selectedTimeSlot: null,
    ));
  }

  void selectTimeSlot(String timeSlot) {
    emit(state.copyWith(selectedTimeSlot: timeSlot));
  }

  Future<bool> bookAppointment({
    required String patientId,
    required String doctorId,
    required DateTime appointmentDate,
    required String startTime,
    required String endTime,
    String? symptoms,
    String? notes,
  }) async {
    emit(state.copyWith(
      isBookingInProgress: true,
      status: AppointmentStatus.loading,
    ));

    try {
      final success = await _appointmentRepository.bookAppointment(
        patientId: patientId,
        doctorId: doctorId,
        appointmentDate: appointmentDate,
        startTime: startTime,
        endTime: endTime,
        symptoms: symptoms,
        notes: notes,
      );

      if (success) {
        emit(state.copyWith(
          status: AppointmentStatus.booked,
          isBookingInProgress: false,
        ));

        // Reload appointments after booking
        await loadPatientAppointments(patientId);
      } else {
        emit(state.copyWith(
          status: AppointmentStatus.error,
          errorMessage: 'Failed to book appointment',
          isBookingInProgress: false,
        ));
      }

      return success;
    } catch (e) {
      emit(state.copyWith(
        status: AppointmentStatus.error,
        errorMessage: 'Failed to book appointment',
        isBookingInProgress: false,
      ));
      return false;
    }
  }

  Future<bool> cancelAppointment(String appointmentId, String patientId) async {
    emit(state.copyWith(status: AppointmentStatus.loading));

    try {
      final success = await _appointmentRepository.cancelAppointment(appointmentId);

      if (success) {
        // Reload appointments after cancellation
        await loadPatientAppointments(patientId);
      } else {
        emit(state.copyWith(
          status: AppointmentStatus.error,
          errorMessage: 'Failed to cancel appointment',
        ));
      }

      return success;
    } catch (e) {
      emit(state.copyWith(
        status: AppointmentStatus.error,
        errorMessage: 'Failed to cancel appointment: ${e.toString()}',
      ));
      return false;
    }
  }

  Future<bool> updateAppointmentStatus(String appointmentId, String status, String doctorId) async {
    emit(state.copyWith(status: AppointmentStatus.loading));

    try {
      final success = await _appointmentRepository.updateAppointmentStatus(appointmentId, status);

      if (success) {
        // Reload appointments after status update
        await loadDoctorAppointments(doctorId);
      } else {
        emit(state.copyWith(
          status: AppointmentStatus.error,
          errorMessage: 'Failed to update appointment status',
        ));
      }

      return success;
    } catch (e) {
      emit(state.copyWith(
        status: AppointmentStatus.error,
        errorMessage: 'Failed to update appointment status: ${e.toString()}',
      ));
      return false;
    }
  }
}
