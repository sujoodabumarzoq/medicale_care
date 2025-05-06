import 'package:equatable/equatable.dart';
import 'package:medicale_care/models/message_model.dart';

class ChatModel extends Equatable {
  final String id;
  final String patientId;
  final String doctorId;
  final String? patientName;
  final DateTime lastMessageTime;
  final bool unreadByPatient;
  final bool unreadByDoctor;
  final List<MessageModel> messages;

  const ChatModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    this.patientName,
    required this.lastMessageTime,
    this.unreadByPatient = false,
    this.unreadByDoctor = false,
    this.messages = const [],
  });

  ChatModel copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? patientName,
    DateTime? lastMessageTime,
    bool? unreadByPatient,
    bool? unreadByDoctor,
    List<MessageModel>? messages,
  }) {
    return ChatModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      patientName: patientName ?? this.patientName,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadByPatient: unreadByPatient ?? this.unreadByPatient,
      unreadByDoctor: unreadByDoctor ?? this.unreadByDoctor,
      messages: messages ?? this.messages,
    );
  }

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] ?? '',
      patientId: json['patient_id'] ?? '',
      doctorId: json['doctor_id'] ?? '',
      patientName: json['patient_profile']?['user']?['full_name'] as String?,
      lastMessageTime: json['last_message_time'] != null ? DateTime.parse(json['last_message_time']) : DateTime.now(),
      unreadByPatient: json['unread_by_patient'] ?? false,
      unreadByDoctor: json['unread_by_doctor'] ?? false,
      messages: (json['messages'] as List?)?.map((e) => MessageModel.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'last_message_time': lastMessageTime.toIso8601String(),
      'unread_by_patient': unreadByPatient,
      'unread_by_doctor': unreadByDoctor,
      'messages': messages.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [id, patientId, doctorId, patientName, lastMessageTime, unreadByPatient, unreadByDoctor, messages];
}
