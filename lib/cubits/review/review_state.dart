import 'package:equatable/equatable.dart';

import '../../models/review_model.dart';

enum ReviewStatus {
  initial,
  loading,
  loaded,
  submitting,
  submitted,
  error,
}

class ReviewState extends Equatable {
  final ReviewStatus status;
  final List<ReviewModel> reviews;
  final bool hasUserReviewed;
  final String? errorMessage;

  const ReviewState({
    this.status = ReviewStatus.initial,
    this.reviews = const [],
    this.hasUserReviewed = false,
    this.errorMessage,
  });

  bool get isLoading => status == ReviewStatus.loading;
  bool get isSubmitting => status == ReviewStatus.submitting;
  bool get hasError => status == ReviewStatus.error;
  bool get hasReviews => reviews.isNotEmpty;

  double get averageRating {
    if (reviews.isEmpty) return 0.0;
    final totalRating = reviews.fold(0, (sum, review) => sum + review.rating);
    return totalRating / reviews.length;
  }

  ReviewState copyWith({
    ReviewStatus? status,
    List<ReviewModel>? reviews,
    bool? hasUserReviewed,
    String? errorMessage,
  }) {
    return ReviewState(
      status: status ?? this.status,
      reviews: reviews ?? this.reviews,
      hasUserReviewed: hasUserReviewed ?? this.hasUserReviewed,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        reviews,
        hasUserReviewed,
        errorMessage,
      ];
}
