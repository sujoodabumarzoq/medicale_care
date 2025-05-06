import 'package:equatable/equatable.dart';

import '../../models/doctor_model.dart';

enum DoctorStatus {
  initial,
  loading,
  loaded,
  error,
}

class DoctorState extends Equatable {
  final DoctorStatus status;
  final List<DoctorModel> doctors;
  final List<DoctorModel> popularDoctors;
  final DoctorModel? selectedDoctor;
  final String? errorMessage;
  final String? selectedSpecialtyId;

  const DoctorState({
    this.status = DoctorStatus.initial,
    this.doctors = const [],
    this.popularDoctors = const [],
    this.selectedDoctor,
    this.errorMessage,
    this.selectedSpecialtyId,
  });

  bool get isLoading => status == DoctorStatus.loading;
  bool get hasError => status == DoctorStatus.error;
  bool get hasData => doctors.isNotEmpty || popularDoctors.isNotEmpty;

  DoctorState copyWith({
    DoctorStatus? status,
    List<DoctorModel>? doctors,
    List<DoctorModel>? popularDoctors,
    DoctorModel? selectedDoctor,
    String? errorMessage,
    String? selectedSpecialtyId,
  }) {
    return DoctorState(
      status: status ?? this.status,
      doctors: doctors ?? this.doctors,
      popularDoctors: popularDoctors ?? this.popularDoctors,
      selectedDoctor: selectedDoctor ?? this.selectedDoctor,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedSpecialtyId: selectedSpecialtyId ?? this.selectedSpecialtyId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        doctors,
        popularDoctors,
        selectedDoctor,
        errorMessage,
        selectedSpecialtyId,
      ];
}
