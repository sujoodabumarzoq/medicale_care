import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/appointment_model.dart';

class AppointmentRepository {
  final SupabaseClient _supabaseClient;

  AppointmentRepository({SupabaseClient? supabaseClient}) : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  // Book an appointment
  Future<bool> bookAppointment({
    required String patientId,
    required String doctorId,
    required DateTime appointmentDate,
    required String startTime,
    required String endTime,
    String? symptoms,
    String? notes,
  }) async {
    try {
      await _supabaseClient.from('appointments').insert({
        'patient_id': patientId,
        'doctor_id': doctorId,
        'appointment_date': appointmentDate.toIso8601String(),
        'start_time': startTime,
        'end_time': endTime,
        'status': 'pending',
        'symptoms': symptoms,
        'notes': notes,
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // Get patient appointments// Get doctor appointments
  Future<List<AppointmentModel>> getDoctorAppointments(String doctorId) async {
    try {
      final response = await _supabaseClient.from('appointments').select('''
          *,
          patient:patient_profiles!appointments_patient_id_fkey (
            users!patient_profiles_id_fkey(*)
          )
        ''').eq('doctor_id', doctorId).order('appointment_date', ascending: true).order('start_time', ascending: true);

      return (response as List).map((json) {
        final patientUser = json['patient']['users'] ?? {};

        return AppointmentModel(
          id: json['id'],
          doctorId: json['doctor_id'],
          patientId: json['patient_id'],
          appointmentDate: DateTime.parse(json['appointment_date']),
          startTime: json['start_time'],
          endTime: json['end_time'],
          status: json['status'],
          notes: json['notes'],
          symptoms: json['symptoms'],
          createdAt: DateTime.parse(json['created_at']),
          updatedAt: DateTime.parse(json['updated_at']),
          patientName: patientUser['full_name'] ?? 'Unknown Patient',
          patientImageUrl: patientUser['profile_image_url'],
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// get patient appointments
  Future<List<AppointmentModel>> getPatientAppointments(String patientId) async {
    try {
      final response = await _supabaseClient.from('appointments').select('''
          *,
          doctor:doctor_profiles!appointments_doctor_id_fkey (
            users!doctor_profiles_id_fkey(*)
          )
        ''').eq('patient_id', patientId).order('appointment_date', ascending: true).order('start_time', ascending: true);

      return (response as List).map((json) {
        final doctorUser = json['doctor']['users'] ?? {};

        return AppointmentModel(
          id: json['id'],
          doctorId: json['doctor_id'],
          patientId: json['patient_id'],
          appointmentDate: DateTime.parse(json['appointment_date']),
          startTime: json['start_time'],
          endTime: json['end_time'],
          status: json['status'],
          notes: json['notes'],
          symptoms: json['symptoms'],
          createdAt: DateTime.parse(json['created_at']),
          updatedAt: DateTime.parse(json['updated_at']),
          doctorName: doctorUser['full_name'] ?? 'Unknown Doctor',
          doctorImageUrl: doctorUser['profile_image_url'],
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Update appointment status
  Future<bool> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      await _supabaseClient.from('appointments').update({'status': status, 'updated_at': DateTime.now().toIso8601String()}).eq('id', appointmentId);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Update appointment notes
  Future<bool> updateAppointmentNotes(String appointmentId, String notes) async {
    try {
      await _supabaseClient.from('appointments').update({'notes': notes, 'updated_at': DateTime.now().toIso8601String()}).eq('id', appointmentId);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Cancel appointment
  Future<bool> cancelAppointment(String appointmentId) async {
    return await updateAppointmentStatus(appointmentId, 'cancelled');
  }

  // Complete appointment
  Future<bool> completeAppointment(String appointmentId) async {
    return await updateAppointmentStatus(appointmentId, 'completed');
  }

  // Confirm appointment
  Future<bool> confirmAppointment(String appointmentId) async {
    return await updateAppointmentStatus(appointmentId, 'confirmed');
  }

  // Listen to appointment changes
  Stream<List<AppointmentModel>> streamAppointments(String userId, String role) {
    final field = role == 'doctor' ? 'doctor_id' : 'patient_id';

    return _supabaseClient.from('appointments').stream(primaryKey: ['id']).eq(field, userId).map((List<Map<String, dynamic>> data) {
          return data.map((json) => AppointmentModel.fromJson(json)).toList();
        });
  }
}
