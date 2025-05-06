import 'package:equatable/equatable.dart';
import 'package:medicale_care/models/user_model.dart';

import 'appointment_model.dart';
import 'review_model.dart';
import 'specialty_model.dart';

class DoctorModel extends Equatable {
  final String id;
  final UserModel user;
  final SpecialtyModel? specialty;
  final String licenseNumber;
  final int experienceYears;
  final String bio;
  final double consultationFee;
  final String education;
  final double rating;
  final bool isPopular;
  final bool isAvailable;
  final List<AppointmentModel> appointments;
  final List<ReviewModel> reviews;

  const DoctorModel({
    required this.id,
    required this.user,
    this.specialty,
    required this.licenseNumber,
    required this.experienceYears,
    this.bio = '',
    this.consultationFee = 0.0,
    this.education = '',
    this.rating = 0.0,
    this.isPopular = false,
    this.isAvailable = false,
    this.appointments = const [],
    this.reviews = const [],
  });

  DoctorModel copyWith({
    String? id,
    UserModel? user,
    SpecialtyModel? specialty,
    String? licenseNumber,
    int? experienceYears,
    String? bio,
    double? consultationFee,
    String? education,
    double? rating,
    bool? isPopular,
    bool? isAvailable,
    List<AppointmentModel>? appointments,
    List<ReviewModel>? reviews,
  }) {
    return DoctorModel(
      id: id ?? this.id,
      user: user ?? this.user,
      specialty: specialty ?? this.specialty,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      experienceYears: experienceYears ?? this.experienceYears,
      bio: bio ?? this.bio,
      consultationFee: consultationFee ?? this.consultationFee,
      education: education ?? this.education,
      rating: rating ?? this.rating,
      isPopular: isPopular ?? this.isPopular,
      isAvailable: isAvailable ?? this.isAvailable,
      appointments: appointments ?? this.appointments,
      reviews: reviews ?? this.reviews,
    );
  }

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] ?? '',
      user: UserModel.fromJson({
        'id': json['users']?['id'] ?? json['id'] ?? '',
        'email': json['users']?['email'] ?? json['email'] ?? '',
        'full_name': json['users']?['full_name'] ?? json['full_name'] ?? '',
        'role': 'doctor',
        'created_at': json['created_at'] ?? DateTime.now().toIso8601String(),
        'profile_image_url': json['profile_image_url'],
        'phone_number': json['phone_number']
      }),
      specialty: json['specialties'] != null ? SpecialtyModel.fromJson(json['specialties']) : null,
      licenseNumber: json['license_number'] ?? '',
      experienceYears: json['experience_years'] ?? 0,
      bio: json['bio'] ?? '',
      consultationFee: (json['consultation_fee'] ?? 0.0).toDouble(),
      education: json['education'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      isPopular: json['is_popular'] ?? false,
      isAvailable: json['is_available'] ?? false,
      appointments: (json['appointments'] as List?)?.map((e) => AppointmentModel.fromJson(e)).toList() ?? [],
      reviews: (json['reviews'] as List?)?.map((e) => ReviewModel.fromJson(e)).toList() ?? [],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'specialty': specialty?.toJson(),
      'license_number': licenseNumber,
      'experience_years': experienceYears,
      'bio': bio,
      'consultation_fee': consultationFee,
      'education': education,
      'rating': rating,
      'is_popular': isPopular,
      'is_available': isAvailable,
      'appointments': appointments.map((e) => e.toJson()).toList(),
      'reviews': reviews.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        user,
        specialty,
        licenseNumber,
        experienceYears,
        bio,
        consultationFee,
        education,
        rating,
        isPopular,
        isAvailable,
        appointments,
        reviews,
      ];
}
