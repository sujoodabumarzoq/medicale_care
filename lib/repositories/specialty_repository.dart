import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/specialty_model.dart';

class SpecialtyRepository {
  final SupabaseClient _supabaseClient;

  SpecialtyRepository({SupabaseClient? supabaseClient}) : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  // Get all specialties
  Future<List<SpecialtyModel>> getAllSpecialties() async {
    try {
      final response = await _supabaseClient.from('specialties').select().order('name');

      return (response as List).map((json) => SpecialtyModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Get specialty by ID
  Future<SpecialtyModel?> getSpecialtyById(String specialtyId) async {
    try {
      final response = await _supabaseClient.from('specialties').select().eq('id', specialtyId).single();

      return SpecialtyModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}
