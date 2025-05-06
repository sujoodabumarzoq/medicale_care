import 'package:equatable/equatable.dart';

import '../../models/specialty_model.dart';

enum SpecialtyStatus {
  initial,
  loading,
  loaded,
  error,
}

class SpecialtyState extends Equatable {
  final SpecialtyStatus status;
  final List<SpecialtyModel> specialties;
  final SpecialtyModel? selectedSpecialty;
  final String? errorMessage;

  const SpecialtyState({
    this.status = SpecialtyStatus.initial,
    this.specialties = const [],
    this.selectedSpecialty,
    this.errorMessage,
  });

  bool get isLoading => status == SpecialtyStatus.loading;
  bool get hasError => status == SpecialtyStatus.error;
  bool get hasData => specialties.isNotEmpty;

  SpecialtyState copyWith({
    SpecialtyStatus? status,
    List<SpecialtyModel>? specialties,
    SpecialtyModel? selectedSpecialty,
    String? errorMessage,
  }) {
    return SpecialtyState(
      status: status ?? this.status,
      specialties: specialties ?? this.specialties,
      selectedSpecialty: selectedSpecialty ?? this.selectedSpecialty,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        specialties,
        selectedSpecialty,
        errorMessage,
      ];
}
