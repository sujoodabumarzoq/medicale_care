import 'package:equatable/equatable.dart';

class EmergencyContactModel extends Equatable {
  final String id;
  final String name;
  final String phoneNumber;
  final String address;
  final double? latitude;
  final double? longitude;
  final String type;
  final bool is24Hours;
  final DateTime createdAt;

  const EmergencyContactModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.address,
    this.latitude,
    this.longitude,
    required this.type,
    required this.is24Hours,
    required this.createdAt,
  });

  bool get isHospital => type == 'hospital';
  bool get isAmbulance => type == 'ambulance';
  bool get isFire => type == 'fire';

  String get typeLabel {
    switch (type) {
      case 'hospital':
        return 'Hospital';
      case 'ambulance':
        return 'Ambulance';
      case 'fire':
        return 'Fire';

      default:
        return 'Emergency Service';
    }
  }

  EmergencyContactModel copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? address,
    double? latitude,
    double? longitude,
    String? type,
    bool? is24Hours,
    DateTime? createdAt,
  }) {
    return EmergencyContactModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      type: type ?? this.type,
      is24Hours: is24Hours ?? this.is24Hours,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory EmergencyContactModel.fromJson(Map<String, dynamic> json) {
    return EmergencyContactModel(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      latitude: json['latitude'] != null ? double.parse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.parse(json['longitude'].toString()) : null,
      type: json['type'],
      is24Hours: json['is_24_hours'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'type': type,
      'is_24_hours': is24Hours,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phoneNumber,
        address,
        latitude,
        longitude,
        type,
        is24Hours,
        createdAt,
      ];
}
