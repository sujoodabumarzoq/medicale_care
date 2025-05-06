import 'package:equatable/equatable.dart';
import 'package:medicale_care/models/user_model.dart';

class PatientModel extends Equatable {
  final String id;
  final UserModel user;
  final DateTime? dateOfBirth;
  final String? bloodType;
  final String? allergies;
  final String? medicalHistory;

  const PatientModel({
    required this.id,
    required this.user,
    this.dateOfBirth,
    this.bloodType,
    this.allergies,
    this.medicalHistory,
  });

  PatientModel copyWith({
    String? id,
    UserModel? user,
    DateTime? dateOfBirth,
    String? bloodType,
    String? allergies,
    String? medicalHistory,
  }) {
    return PatientModel(
      id: id ?? this.id,
      user: user ?? this.user,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      medicalHistory: medicalHistory ?? this.medicalHistory,
    );
  }

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'],
      user: UserModel.fromJson(json['user']),
      dateOfBirth: json['date_of_birth'] != null ? DateTime.parse(json['date_of_birth']) : null,
      bloodType: json['blood_type'],
      allergies: json['allergies'],
      medicalHistory: json['medical_history'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'blood_type': bloodType,
      'allergies': allergies,
      'medical_history': medicalHistory,
    };
  }

  @override
  List<Object?> get props => [
        id,
        user,
        dateOfBirth,
        bloodType,
        allergies,
        medicalHistory,
      ];
}
