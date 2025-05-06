import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/patient_model.dart';
import '../models/user_model.dart';

class PatientRepository {
  final SupabaseClient _supabaseClient;

  PatientRepository({SupabaseClient? supabaseClient}) : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  // Get patient profile by ID
  Future<PatientModel?> getPatientById(String patientId) async {
    try {
      final userData = await _supabaseClient.from('users').select().eq('id', patientId).single();

      final patientData = await _supabaseClient.from('patient_profiles').select().eq('id', patientId).single();

      final user = UserModel.fromJson(userData);

      return PatientModel(
        id: patientData['id'],
        user: user,
        dateOfBirth: patientData['date_of_birth'] != null ? DateTime.parse(patientData['date_of_birth']) : null,
        bloodType: patientData['blood_type'],
        allergies: patientData['allergies'],
        medicalHistory: patientData['medical_history'],
      );
    } catch (e) {
      return null;
    }
  }

  // Create or update patient profile
  Future<bool> updatePatientProfile({
    required String patientId,
    DateTime? dateOfBirth,
    String? bloodType,
    String? allergies,
    String? medicalHistory,
  }) async {
    try {
      // First, check if profile exists
      final exists = await _supabaseClient.from('patient_profiles').select('id').eq('id', patientId).maybeSingle();

      final data = {
        'date_of_birth': dateOfBirth?.toIso8601String(),
        'blood_type': bloodType,
        'allergies': allergies,
        'medical_history': medicalHistory,
      };

      if (exists == null) {
        // Create new profile
        await _supabaseClient.from('patient_profiles').insert({
          'id': patientId,
          ...data,
        });
      } else {
        // Update existing profile
        await _supabaseClient.from('patient_profiles').update(data).eq('id', patientId);
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
