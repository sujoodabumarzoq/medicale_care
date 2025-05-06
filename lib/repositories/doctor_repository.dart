import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/doctor_availability_model.dart';
import '../models/doctor_model.dart';
import '../models/specialty_model.dart';
import '../models/user_model.dart';

class DoctorRepository {
  final SupabaseClient _supabaseClient;

  DoctorRepository({SupabaseClient? supabaseClient}) : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  // Get doctor profile by ID
  Future<DoctorModel?> getDoctorById(String doctorId) async {
    try {
      final response = await _supabaseClient.from('doctor_profiles').select('''
          *,
          users(id, full_name, email),
          specialties!doctor_profiles_specialty_id_fkey(id, name),
          appointments(id, patient_id, status),
          reviews(id, rating, comment)
        ''').eq('id', doctorId).single();

      // Create a map that mimics the structure of the SQL query result
      final doctorMap = {
        'id': (response['id'] ?? '').toString(),
        'specialty_id': response['specialty_id'],
        'license_number': response['license_number'] ?? '',
        'experience_years': response['experience_years'] ?? 0,
        'bio': response['bio'] ?? '',
        'consultation_fee': response['consultation_fee'] ?? 0.0,
        'education': response['education'] ?? '',
        'rating': response['rating'] ?? 0.0,
        'is_popular': response['is_popular'] ?? false,
        'is_available': response['is_available'] ?? false,
        'created_at': response['created_at'] ?? DateTime.now().toIso8601String(),
        'updated_at': response['updated_at'] ?? DateTime.now().toIso8601String(),
        'users': response['users'] is Map
            ? {
                'id': (response['users']['id'] ?? '').toString(),
                'full_name': (response['users']['full_name'] ?? '').toString(),
                'email': (response['users']['email'] ?? '').toString(),
                'role': 'doctor',
                'created_at': response['created_at'] ?? DateTime.now().toIso8601String()
              }
            : {
                'id': (response['id'] ?? '').toString(),
                'full_name': '',
                'email': '',
                'role': 'doctor',
                'created_at': response['created_at'] ?? DateTime.now().toIso8601String()
              },
        'specialties': response['specialties'] is Map
            ? {'id': (response['specialties']['id'] ?? '').toString(), 'name': (response['specialties']['name'] ?? '').toString()}
            : null,
        'appointments': (response['appointments'] as List?)
                ?.map((appointment) => {
                      'id': (appointment['id'] ?? '').toString(),
                      'patient_id': (appointment['patient_id'] ?? '').toString(),
                      'status': (appointment['status'] ?? '').toString()
                    })
                .toList() ??
            [],
        'reviews': (response['reviews'] as List?)
                ?.map((review) => {
                      'id': (review['id'] ?? '').toString(),
                      'rating': (review['rating'] ?? 0).toString(),
                      'comment': (review['comment'] ?? '').toString()
                    })
                .toList() ??
            []
      };

      // Parse the modified response into a DoctorModel
      return DoctorModel.fromJson(doctorMap);
    } catch (e) {
      return null;
    }
  }

  // Create or update doctor profile
  Future<bool> createOrUpdateDoctorProfile({
    required String doctorId,
    required String specialtyId,
    required String licenseNumber,
    required int experienceYears,
    String? bio,
    required double consultationFee,
    String? education,
  }) async {
    try {
      // Check if profile exists
      final exists = await _supabaseClient.from('doctor_profiles').select('id').eq('id', doctorId).maybeSingle();

      if (exists == null) {
        // Create new profile
        await _supabaseClient.from('doctor_profiles').insert({
          'id': doctorId,
          'specialty_id': specialtyId,
          'license_number': licenseNumber,
          'experience_years': experienceYears,
          'bio': bio,
          'consultation_fee': consultationFee,
          'education': education,
        });
      } else {
        // Update existing profile
        await _supabaseClient.from('doctor_profiles').update({
          'specialty_id': specialtyId,
          'license_number': licenseNumber,
          'experience_years': experienceYears,
          'bio': bio,
          'consultation_fee': consultationFee,
          'education': education,
        }).eq('id', doctorId);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Get all doctors
  Future<List<DoctorModel>> getAllDoctors() async {
    try {
      final response = await _supabaseClient.from('doctor_profiles').select('''
      *,
      users!doctor_profiles_id_fkey(*),
      specialties!doctor_profiles_specialty_id_fkey(*)
    ''').order('rating', ascending: false);

      return (response as List).map((json) => DoctorModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Get popular doctors
  Future<List<DoctorModel>> getPopularDoctors({int limit = 10}) async {
    try {
      final response = await _supabaseClient.from('doctor_profiles').select('''
      *,
      users!doctor_profiles_id_fkey (*),
      specialties!doctor_profiles_specialty_id_fkey (*),
      appointments!appointments_doctor_id_fkey (*),
      reviews!reviews_doctor_id_fkey (*)
    ''').eq('is_popular', true).order('rating', ascending: false).limit(limit);

      // Map the response to DoctorModel list
      return (response as List).map((json) {
        return DoctorModel.fromJson(json);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Get doctors by specialty
  Future<List<DoctorModel>> getDoctorsBySpecialty(String specialtyId) async {
    try {
      final response = await _supabaseClient.from('doctor_profiles').select('''
            *,
            users!doctor_profiles_id_fkey(*),
            specialties!doctor_profiles_specialty_id_fkey(*)
          ''').eq('specialty_id', specialtyId).order('rating', ascending: false);

      return (response as List).map((json) {
        final userMap = json['users'] ?? {};
        final specialtyMap = json['specialties'] ?? {};

        return DoctorModel(
          id: json['id'] ?? '',
          user: UserModel.fromJson(userMap),
          specialty: specialtyMap.isNotEmpty ? SpecialtyModel.fromJson(specialtyMap) : null,
          licenseNumber: json['license_number'] ?? '',
          experienceYears: json['experience_years'] ?? 0,
          bio: json['bio'] ?? '',
          consultationFee: (json['consultation_fee'] ?? 0.0).toDouble(),
          education: json['education'] ?? '',
          rating: (json['rating'] ?? 0.0).toDouble(),
          isPopular: json['is_popular'] ?? false,
          isAvailable: json['is_available'] ?? false,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Set doctor availability
  Future<bool> setDoctorAvailability({
    required String doctorId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    bool isRecurring = true,
  }) async {
    try {
      // Check if availability for this day already exists
      final exists =
          await _supabaseClient.from('doctor_availability').select('id').eq('doctor_id', doctorId).eq('day_of_week', dayOfWeek).maybeSingle();

      if (exists == null) {
        // Create new availability
        await _supabaseClient.from('doctor_availability').insert({
          'doctor_id': doctorId,
          'day_of_week': dayOfWeek,
          'start_time': startTime,
          'end_time': endTime,
          'is_recurring': isRecurring,
        });
      } else {
        // Update existing availability
        await _supabaseClient.from('doctor_availability').update({
          'start_time': startTime,
          'end_time': endTime,
          'is_recurring': isRecurring,
        }).eq('id', exists['id']);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Get doctor availability
  Future<List<DoctorAvailabilityModel>> getDoctorAvailability(String doctorId) async {
    try {
      final response = await _supabaseClient.from('doctor_availability').select().eq('doctor_id', doctorId).order('day_of_week');

      return (response as List).map((json) => DoctorAvailabilityModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Delete doctor availability
  Future<bool> deleteDoctorAvailability(String availabilityId) async {
    try {
      await _supabaseClient.from('doctor_availability').delete().eq('id', availabilityId);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Toggle doctor availability status
  Future<bool> toggleDoctorAvailability(String doctorId, bool isAvailable) async {
    try {
      await _supabaseClient.from('doctor_profiles').update({'is_available': isAvailable}).eq('id', doctorId);
      return true;
    } catch (e) {
      return false;
    }
  }
}
