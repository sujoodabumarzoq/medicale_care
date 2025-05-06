import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String? profileImageUrl;
  final String? phoneNumber;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.profileImageUrl,
    this.phoneNumber,
    required this.createdAt,
  });

  bool get isDoctor => role == 'doctor';
  bool get isPatient => role == 'patient';

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
    String? profileImageUrl,
    String? phoneNumber,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      fullName: (json['full_name'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      profileImageUrl: json['profile_image_url']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'profile_image_url': profileImageUrl,
      'phone_number': phoneNumber,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        role,
        profileImageUrl,
        phoneNumber,
        createdAt,
      ];
}
