import 'package:equatable/equatable.dart';

import '../../models/patient_model.dart';

enum PatientStatus {
  initial,
  loading,
  loaded,
  updating,
  updated,
  error,
}

class PatientState extends Equatable {
  final PatientStatus status;
  final PatientModel? patient;
  final String? errorMessage;

  const PatientState({
    this.status = PatientStatus.initial,
    this.patient,
    this.errorMessage,
  });

  bool get isLoading => status == PatientStatus.loading || status == PatientStatus.updating;
  bool get hasError => status == PatientStatus.error;
  bool get isProfileComplete => patient != null && patient!.dateOfBirth != null && (patient!.bloodType?.isNotEmpty ?? false);

  PatientState copyWith({
    PatientStatus? status,
    PatientModel? patient,
    String? errorMessage,
  }) {
    return PatientState(
      status: status ?? this.status,
      patient: patient ?? this.patient,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, patient, errorMessage];
}
