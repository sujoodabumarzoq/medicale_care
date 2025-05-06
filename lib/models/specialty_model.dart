import 'package:equatable/equatable.dart';

class SpecialtyModel extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final DateTime createdAt;

  const SpecialtyModel({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.createdAt,
  });

  SpecialtyModel copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    DateTime? createdAt,
  }) {
    return SpecialtyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory SpecialtyModel.fromJson(Map<String, dynamic> json) {
    return SpecialtyModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      icon: json['icon']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, name, description, icon, createdAt];
}
