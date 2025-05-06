import 'package:equatable/equatable.dart';

class ReviewModel extends Equatable {
  final String id;
  final String doctorId;
  final String patientId;
  final String? appointmentId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  final String? patientName;
  final String? patientImageUrl;

  const ReviewModel({
    required this.id,
    required this.doctorId,
    required this.patientId,
    this.appointmentId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.patientName,
    this.patientImageUrl,
  });

  ReviewModel copyWith({
    String? id,
    String? doctorId,
    String? patientId,
    String? appointmentId,
    int? rating,
    String? comment,
    DateTime? createdAt,
    String? patientName,
    String? patientImageUrl,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      appointmentId: appointmentId ?? this.appointmentId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      patientName: patientName ?? this.patientName,
      patientImageUrl: patientImageUrl ?? this.patientImageUrl,
    );
  }

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: (json['id'] ?? '').toString(),
      doctorId: (json['doctor_id'] ?? '').toString(),
      patientId: (json['patient_id'] ?? '').toString(),
      appointmentId: json['appointment_id']?.toString(),
      rating: json['rating'] is int ? json['rating'] : int.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      comment: json['comment']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
      patientName: json['patient_name']?.toString() ?? (json['patient_profiles']?['users']?['full_name']?.toString() ?? 'Anonymous'),
      patientImageUrl: json['patient_image_url']?.toString() ?? (json['patient_profiles']?['users']?['profile_image_url']?.toString()),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'patient_id': patientId,
      'appointment_id': appointmentId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        doctorId,
        patientId,
        appointmentId,
        rating,
        comment,
        createdAt,
      ];
}
