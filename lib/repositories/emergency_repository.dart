import 'package:medicale_care/models/emergency_contact_modal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmergencyRepository {
  final SupabaseClient _supabaseClient;

  EmergencyRepository({SupabaseClient? supabaseClient}) : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  // Get all emergency contacts
  Future<List<EmergencyContactModel>> getAllEmergencyContacts() async {
    try {
      final response = await _supabaseClient.from('emergency_contacts').select().order('name');

      return (response as List).map((json) => EmergencyContactModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Get emergency contacts by type
  Future<List<EmergencyContactModel>> getEmergencyContactsByType(String type) async {
    try {
      final response = await _supabaseClient.from('emergency_contacts').select().eq('type', type).order('name');

      return (response as List).map((json) => EmergencyContactModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Get emergency contact by ID
  Future<EmergencyContactModel?> getEmergencyContactById(String id) async {
    try {
      final response = await _supabaseClient.from('emergency_contacts').select().eq('id', id).single();

      return EmergencyContactModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<List<EmergencyContactModel>> getNearestHospitals() async {
    return getEmergencyContactsByType('hospital');
  }
}
