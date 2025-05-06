import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/review_repository.dart';
import 'review_state.dart';

class ReviewCubit extends Cubit<ReviewState> {
  final ReviewRepository _reviewRepository;

  ReviewCubit({required ReviewRepository reviewRepository})
      : _reviewRepository = reviewRepository,
        super(const ReviewState());

  Future<void> loadDoctorReviews(String doctorId, [String? patientId]) async {
    emit(state.copyWith(status: ReviewStatus.loading));

    try {
      final reviews = await _reviewRepository.getDoctorReviews(doctorId);

      bool hasUserReviewed = false;
      if (patientId != null) {
        hasUserReviewed = await _reviewRepository.hasPatientReviewedDoctor(patientId, doctorId);
      }

      emit(state.copyWith(
        status: ReviewStatus.loaded,
        reviews: reviews,
        hasUserReviewed: hasUserReviewed,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ReviewStatus.error,
        errorMessage: 'Failed to load reviews: ${e.toString()}',
      ));
    }
  }

  Future<bool> submitReview({
    required String doctorId,
    required String patientId,
    String? appointmentId,
    required int rating,
    String? comment,
  }) async {
    emit(state.copyWith(status: ReviewStatus.submitting));

    try {
      final success = await _reviewRepository.addReview(
        doctorId: doctorId,
        patientId: patientId,
        appointmentId: appointmentId,
        rating: rating,
        comment: comment,
      );

      if (success) {
        await loadDoctorReviews(doctorId, patientId);
        emit(state.copyWith(
          status: ReviewStatus.submitted,
          hasUserReviewed: true,
        ));
      } else {
        emit(state.copyWith(
          status: ReviewStatus.error,
          errorMessage: 'Failed to submit review',
        ));
      }

      return success;
    } catch (e) {
      emit(state.copyWith(
        status: ReviewStatus.error,
        errorMessage: 'Failed to submit review: ${e.toString()}',
      ));
      return false;
    }
  }

  Future<bool> updateReview({
    required String reviewId,
    required String doctorId,
    required String patientId,
    required int rating,
    String? comment,
  }) async {
    emit(state.copyWith(status: ReviewStatus.submitting));

    try {
      final success = await _reviewRepository.updateReview(
        reviewId: reviewId,
        rating: rating,
        comment: comment,
      );

      if (success) {
        await loadDoctorReviews(doctorId, patientId);
        emit(state.copyWith(status: ReviewStatus.submitted));
      } else {
        emit(state.copyWith(
          status: ReviewStatus.error,
          errorMessage: 'Failed to update review',
        ));
      }

      return success;
    } catch (e) {
      emit(state.copyWith(
        status: ReviewStatus.error,
        errorMessage: 'Failed to update review: ${e.toString()}',
      ));
      return false;
    }
  }
}
