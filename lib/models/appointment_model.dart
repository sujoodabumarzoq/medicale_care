import 'package:equatable/equatable.dart';

class AppointmentModel extends Equatable {
  final String id;
  final String doctorId;
  final String patientId;
  final DateTime appointmentDate;
  final String startTime;
  final String endTime;
  final String status;
  final String? notes;
  final String? symptoms;
  final DateTime createdAt;
  final DateTime updatedAt;

  final String? doctorName;
  final String? patientName;
  final String? doctorSpecialty;
  final String? doctorImageUrl;
  final String? patientImageUrl;

  const AppointmentModel({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.notes,
    this.symptoms,
    required this.createdAt,
    required this.updatedAt,
    this.doctorName,
    this.patientName,
    this.doctorSpecialty,
    this.doctorImageUrl,
    this.patientImageUrl,
  });

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';

  AppointmentModel copyWith({
    String? id,
    String? doctorId,
    String? patientId,
    DateTime? appointmentDate,
    String? startTime,
    String? endTime,
    String? status,
    String? notes,
    String? symptoms,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? doctorName,
    String? patientName,
    String? doctorSpecialty,
    String? doctorImageUrl,
    String? patientImageUrl,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      symptoms: symptoms ?? this.symptoms,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      doctorName: doctorName ?? this.doctorName,
      patientName: patientName ?? this.patientName,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      doctorImageUrl: doctorImageUrl ?? this.doctorImageUrl,
      patientImageUrl: patientImageUrl ?? this.patientImageUrl,
    );
  }

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] ?? '',
      doctorId: json['doctor_id'] ?? '',
      patientId: json['patient_id'] ?? '',
      appointmentDate: json['appointment_date'] != null ? DateTime.parse(json['appointment_date']) : DateTime.now(),
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      symptoms: json['symptoms'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
      doctorName: json['doctor_name'],
      patientName: json['patient_name'],
      doctorSpecialty: json['doctor_specialty'],
      doctorImageUrl: json['doctor_image_url'],
      patientImageUrl: json['patient_image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'patient_id': patientId,
      'appointment_date': appointmentDate.toIso8601String(),
      'start_time': startTime,
      'end_time': endTime,
      'status': status,
      'notes': notes,
      'symptoms': symptoms,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        doctorId,
        patientId,
        appointmentDate,
        startTime,
        endTime,
        status,
        notes,
        symptoms,
        createdAt,
        updatedAt,
      ];
}
