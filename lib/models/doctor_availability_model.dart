import 'package:equatable/equatable.dart';

class DoctorAvailabilityModel extends Equatable {
  final String id;
  final String doctorId;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final bool isRecurring;

  const DoctorAvailabilityModel({
    required this.id,
    required this.doctorId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isRecurring,
  });

  String get dayName {
    final days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return days[dayOfWeek];
  }

  DoctorAvailabilityModel copyWith({
    String? id,
    String? doctorId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    bool? isRecurring,
  }) {
    return DoctorAvailabilityModel(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }

  factory DoctorAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return DoctorAvailabilityModel(
      id: json['id'],
      doctorId: json['doctor_id'],
      dayOfWeek: json['day_of_week'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      isRecurring: json['is_recurring'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'is_recurring': isRecurring,
    };
  }

  @override
  List<Object?> get props => [
        id,
        doctorId,
        dayOfWeek,
        startTime,
        endTime,
        isRecurring,
      ];
}
