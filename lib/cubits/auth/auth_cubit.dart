import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicale_care/cubits/auth/auth_state.dart';

import '../../repositories/auth_repository.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState());

  Future<void> checkAuthStatus() async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      if (_authRepository.authState == AuthenticationState.authenticated) {
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          emit(state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          ));
        } else {
          emit(state.copyWith(status: AuthStatus.unauthenticated));
        }
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Error checking authentication status',
      ));
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final response = await _authRepository.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final user = await _authRepository.getCurrentUser();
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ));
      } else {
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Invalid credentials',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Login failed: ${e.toString()}',
      ));
    }
  }

  Future<void> signUp(
      {required String email,
      required String password,
      required String fullName,
      required String role,
      String? phoneNumber,
      double? latitude,
      double? longitude}) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final response = await _authRepository.signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        phoneNumber: phoneNumber,
        latitude: latitude,
        longitude: longitude,
      );

      if (response.user != null) {
        final user = await _authRepository.getCurrentUser();
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ));
      } else {
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Registration failed',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Registration failed',
      ));
    }
  }

  Future<void> signOut() async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      await _authRepository.signOut();
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Sign out failed: ${e.toString()}',
      ));
    }
  }

  Future<void> resetPassword(String email) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      await _authRepository.resetPassword(email);
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Password reset failed: ${e.toString()}',
      ));
    }
  }

  Future<void> updateProfile({
    required String fullName,
    String? phoneNumber,
    List<int>? imageBytes,
    String? imageName,
  }) async {
    if (state.user == null) return;

    emit(state.copyWith(status: AuthStatus.loading));

    try {
      String? imageUrl;

      if (imageBytes != null && imageName != null) {
        imageUrl = await _authRepository.uploadProfileImage(
          state.user!.id,
          imageBytes,
          imageName,
        );
      }

      await _authRepository.updateUserProfile(
        userId: state.user!.id,
        fullName: fullName,
        phoneNumber: phoneNumber,
        profileImageUrl: imageUrl,
      );

      final updatedUser = await _authRepository.getCurrentUser();
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: updatedUser,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Profile update failed: ${e.toString()}',
      ));
    }
  }
}
