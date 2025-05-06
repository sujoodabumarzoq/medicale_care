import 'package:equatable/equatable.dart';

import '../../models/appointment_model.dart';
import '../../models/doctor_availability_model.dart';

enum AppointmentStatus {
  initial,
  loading,
  booked,
  loadingAvailabilities,
  availabilitiesLoaded,
  loadingAppointments,
  appointmentsLoaded,
  error,
}

class AppointmentState extends Equatable {
  final AppointmentStatus status;
  final List<AppointmentModel> appointments;
  final List<DoctorAvailabilityModel> availabilities;
  final DateTime? selectedDate;
  final String? selectedTimeSlot;
  final String? errorMessage;
  final bool isBookingInProgress;

  const AppointmentState({
    this.status = AppointmentStatus.initial,
    this.appointments = const [],
    this.availabilities = const [],
    this.selectedDate,
    this.selectedTimeSlot,
    this.errorMessage,
    this.isBookingInProgress = false,
  });

  bool get isLoading =>
      status == AppointmentStatus.loading || status == AppointmentStatus.loadingAvailabilities || status == AppointmentStatus.loadingAppointments;
  bool get hasError => status == AppointmentStatus.error;
  bool get hasAppointments => appointments.isNotEmpty;
  bool get hasAvailabilities => availabilities.isNotEmpty;

  AppointmentState copyWith({
    AppointmentStatus? status,
    List<AppointmentModel>? appointments,
    List<DoctorAvailabilityModel>? availabilities,
    DateTime? selectedDate,
    String? selectedTimeSlot,
    String? errorMessage,
    bool? isBookingInProgress,
  }) {
    return AppointmentState(
      status: status ?? this.status,
      appointments: appointments ?? this.appointments,
      availabilities: availabilities ?? this.availabilities,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      errorMessage: errorMessage ?? this.errorMessage,
      isBookingInProgress: isBookingInProgress ?? this.isBookingInProgress,
    );
  }

  @override
  List<Object?> get props => [
        status,
        appointments,
        availabilities,
        selectedDate,
        selectedTimeSlot,
        errorMessage,
        isBookingInProgress,
      ];
}
