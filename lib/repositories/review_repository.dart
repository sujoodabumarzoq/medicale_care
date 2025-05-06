import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/review_model.dart';

class ReviewRepository {
  final SupabaseClient _supabaseClient;

  ReviewRepository({SupabaseClient? supabaseClient}) : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  // Add a review
  Future<bool> addReview({
    required String doctorId,
    required String patientId,
    String? appointmentId,
    required int rating,
    String? comment,
  }) async {
    try {
      // Check if review already exists
      final existingReview = await _supabaseClient.from('reviews').select('id').eq('doctor_id', doctorId).eq('patient_id', patientId).maybeSingle();

      if (existingReview != null) {
        // Update existing review
        await _supabaseClient.from('reviews').update({
          'rating': rating,
          'comment': comment,
          'appointment_id': appointmentId,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', existingReview['id']);
      } else {
        // Insert new review
        await _supabaseClient.from('reviews').insert({
          'doctor_id': doctorId,
          'patient_id': patientId,
          'appointment_id': appointmentId,
          'rating': rating,
          'comment': comment,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get reviews for a doctor
  Future<List<ReviewModel>> getDoctorReviews(String doctorId) async {
    try {
      final response = await _supabaseClient.from('reviews').select('''
            *,
            patient_profiles!reviews_patient_id_fkey(
              id,
              users!patient_profiles_id_fkey(
                full_name, 
                profile_image_url
              )
            )
          ''').eq('doctor_id', doctorId).order('created_at', ascending: false);

      return (response as List).map((json) {
        // Navigate through the nested structure
        final patientUser = json['patient_profiles']['users'] ?? {};

        return ReviewModel(
          id: json['id'] ?? '',
          doctorId: json['doctor_id'] ?? '',
          patientId: json['patient_id'] ?? '',
          appointmentId: json['appointment_id'],
          rating: json['rating'] ?? 0,
          comment: json['comment'],
          createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
          patientName: patientUser['full_name'] ?? 'Anonymous',
          patientImageUrl: patientUser['profile_image_url'],
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Update a review
  Future<bool> updateReview({
    required String reviewId,
    required int rating,
    String? comment,
  }) async {
    try {
      await _supabaseClient.from('reviews').update({
        'rating': rating,
        'comment': comment,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', reviewId);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete a review
  Future<bool> deleteReview(String reviewId) async {
    try {
      await _supabaseClient.from('reviews').delete().eq('id', reviewId);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Check if patient has already reviewed a doctor
  Future<bool> hasPatientReviewedDoctor(String patientId, String doctorId) async {
    try {
      final response = await _supabaseClient.from('reviews').select('id').eq('patient_id', patientId).eq('doctor_id', doctorId).maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  // Get average rating for a doctor
  Future<double> getDoctorAverageRating(String doctorId) async {
    try {
      final response = await _supabaseClient.from('reviews').select('rating').eq('doctor_id', doctorId);

      if (response.isEmpty) return 0.0;

      final ratings = (response as List).map((r) => r['rating'] as int);
      return ratings.reduce((a, b) => a + b) / ratings.length;
    } catch (e) {
      return 0.0;
    }
  }
}
