import 'package:equatable/equatable.dart';
import 'package:medicale_care/models/emergency_contact_modal.dart';

enum EmergencyStatus {
  initial,
  loading,
  loaded,
  error,
}

class EmergencyState extends Equatable {
  final EmergencyStatus status;
  final List<EmergencyContactModel> contacts;
  final List<EmergencyContactModel> nearestHospitals;
  final String? errorMessage;
  final String? selectedType;

  const EmergencyState({
    this.status = EmergencyStatus.initial,
    this.contacts = const [],
    this.nearestHospitals = const [],
    this.errorMessage,
    this.selectedType,
  });

  bool get isLoading => status == EmergencyStatus.loading;
  bool get hasError => status == EmergencyStatus.error;
  bool get hasContacts => contacts.isNotEmpty;
  bool get hasNearestHospitals => nearestHospitals.isNotEmpty;

  List<EmergencyContactModel> get filteredContacts {
    if (selectedType == null) return contacts;
    return contacts.where((contact) => contact.type == selectedType).toList();
  }

  EmergencyState copyWith({
    EmergencyStatus? status,
    List<EmergencyContactModel>? contacts,
    List<EmergencyContactModel>? nearestHospitals,
    String? errorMessage,
    String? selectedType,
  }) {
    return EmergencyState(
      status: status ?? this.status,
      contacts: contacts ?? this.contacts,
      nearestHospitals: nearestHospitals ?? this.nearestHospitals,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedType: selectedType ?? this.selectedType,
    );
  }

  @override
  List<Object?> get props => [
        status,
        contacts,
        nearestHospitals,
        errorMessage,
        selectedType,
      ];
}
