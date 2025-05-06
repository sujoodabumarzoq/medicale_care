// lib/repositories/auth_repository.dart
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';

class AuthRepository {
  final SupabaseClient _supabaseClient;

  AuthRepository({SupabaseClient? supabaseClient}) : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  // Get current auth state
  AuthenticationState get authState {
    final session = _supabaseClient.auth.currentSession;
    if (session == null) {
      return AuthenticationState.unauthenticated;
    }
    return AuthenticationState.authenticated;
  }

  // Get current user ID
  String? get currentUserId => _supabaseClient.auth.currentUser?.id;

  // Sign up
  Future<AuthResponse> signUp(
      {required String email,
      required String password,
      required String fullName,
      required String role,
      String? phoneNumber,
      double? latitude,
      double? longitude}) async {
    final response = await _supabaseClient.auth.signUp(
      email: email,
      password: password,
      data: {
        "confirmation_sent_at": DateTime.now().toString(),
      },
    );

    if (response.user != null) {
      // Create user profile
      await _supabaseClient.from('users').insert({
        'id': response.user!.id,
        'email': email,
        'full_name': fullName,
        'role': role,
        'phone_number': phoneNumber,
      });

      // Create specific profile based on role
      if (role == 'patient') {
        await _supabaseClient.from('patient_profiles').insert({
          'id': response.user!.id,
        });
      } else if (role == 'doctor') {
        await _supabaseClient.from('doctor_profiles').insert({'id': response.user!.id, 'latitude': latitude, 'longitude': longitude});
      }
    }

    return response;
  }

  // Sign in
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  // Sign out
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _supabaseClient.auth.resetPasswordForEmail(email);
  }

  // Get current user data
  Future<UserModel?> getCurrentUser() async {
    final userId = currentUserId;
    if (userId == null) return null;

    final response = await _supabaseClient.from('users').select().eq('id', userId).single();

    return UserModel.fromJson(response);
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    final Map<String, dynamic> userData = {};

    if (fullName != null) userData['full_name'] = fullName;
    if (phoneNumber != null) userData['phone_number'] = phoneNumber;
    if (profileImageUrl != null) userData['profile_image_url'] = profileImageUrl;

    if (userData.isNotEmpty) {
      await _supabaseClient.from('users').update(userData).eq('id', userId);
    }
  }

  // Upload profile image
  Future<String?> uploadProfileImage(String userId, List<int> fileBytes, String fileName) async {
    final fileExt = fileName.split('.').last;
    final filePath = 'profiles/$userId.$fileExt';

    final response = await _supabaseClient.storage.from('profile_images').uploadBinary(filePath, Uint8List.fromList(fileBytes));

    if (response.contains('error')) {
      return null;
    }

    // Get the public URL
    final imageUrl = _supabaseClient.storage.from('profile_images').getPublicUrl(filePath);

    // Update user profile with the new image URL
    await updateUserProfile(
      userId: userId,
      profileImageUrl: imageUrl,
    );

    return imageUrl;
  }
}

enum AuthenticationState {
  authenticated,
  unauthenticated,
}
