import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicale_care/cubits/chat/chat_cubit.dart';
import 'package:medicale_care/cubits/doctor/doctor_state.dart';
import 'package:medicale_care/cubits/review/review_state.dart';
import 'package:medicale_care/repositories/chat_repository.dart';
import 'package:medicale_care/screens/chat/chat_screen.dart';
import 'package:medicale_care/widgets/map_display.dart';
import 'package:medicale_care/widgets/review_card.dart';

import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/doctor/doctor_cubit.dart';
import '../../cubits/review/review_cubit.dart';
import '../../widgets/rating_bar.dart';
import 'book_appointment_screen.dart';

class DoctorDetailScreen extends StatefulWidget {
  final String doctorId;

  const DoctorDetailScreen({super.key, required this.doctorId});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  void _loadData() {
    context.read<DoctorCubit>().loadDoctorDetails(widget.doctorId);

    final authState = context.read<AuthCubit>().state;
    if (authState.isAuthenticated && authState.user != null) {
      context.read<ReviewCubit>().loadDoctorReviews(
            widget.doctorId,
            authState.user!.id,
          );
    } else {
      context.read<ReviewCubit>().loadDoctorReviews(widget.doctorId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DoctorCubit, DoctorState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.hasError) {
            return Center(
              child: Text(
                state.errorMessage ?? 'Failed to load doctor details',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state.selectedDoctor == null) {
            return const Center(
              child: Text('Doctor not found'),
            );
          }

          final doctor = state.selectedDoctor!;

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.chat),
                      tooltip: 'Chat',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) => ChatCubit(ChatRepository())..loadChat(context.read<AuthCubit>().state.user!.id, doctor.id),
                              child: ChatScreen(
                                doctorName: doctor.user.fullName,
                                patientId: context.read<AuthCubit>().state.user!.id,
                                doctorId: doctor.id,
                                currentUserId: context.read<AuthCubit>().state.user!.id,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                  expandedHeight: 200,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30),
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                            backgroundImage: doctor.user.profileImageUrl != null ? NetworkImage(doctor.user.profileImageUrl!) : null,
                            child: doctor.user.profileImageUrl == null
                                ? Text(
                                    doctor.user.fullName.substring(0, 1),
                                    style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Dr. ${doctor.user.fullName}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            doctor.specialty?.name ?? 'No Specialty',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: 'About'),
                      Tab(text: 'Reviews'),
                      Tab(text: 'Experience'),
                    ],
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildAboutTab(doctor),
                _buildReviewsTab(),
                _buildExperienceTab(doctor),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<DoctorCubit, DoctorState>(
        builder: (context, state) {
          if (state.selectedDoctor == null) {
            return const SizedBox.shrink();
          }

          final doctor = state.selectedDoctor!;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Consultation Fee',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '\$${doctor.consultationFee.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: doctor.isAvailable
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BookAppointmentScreen(
                                  doctorId: doctor.id,
                                ),
                              ),
                            );
                          }
                        : null,
                    child: Text(doctor.isAvailable ? 'Book Appointment' : 'Not Available'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAboutTab(doctor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About Doctor',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            doctor.bio ?? 'No bio available',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.star_outline,
                  title: 'Rating',
                  value: '${doctor.rating.toStringAsFixed(1)}/5',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.work_outline,
                  title: 'Experience',
                  value: '${doctor.experienceYears} Years',
                ),
              ),
            ],
          ),
          const MapDisplay(latitude: 37.7749, longitude: -122.4194),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return BlocBuilder<ReviewCubit, ReviewState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.hasError) {
          return Center(
            child: Text(
              state.errorMessage ?? 'Failed to load reviews',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (!state.hasReviews) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.rate_review_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'No reviews yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Be the first to write a review!',
                  style: TextStyle(color: Colors.grey),
                ),
                if (!state.hasUserReviewed)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () {
                        _showAddReviewDialog(context);
                      },
                      child: const Text('Write a Review'),
                    ),
                  ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Patient Reviews',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (!state.hasUserReviewed)
                    TextButton(
                      onPressed: () {
                        _showAddReviewDialog(context);
                      },
                      child: const Text('Add Review'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    state.averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RatingBar(
                        rating: state.averageRating,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Based on ${state.reviews.length} reviews',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.reviews.length,
                itemBuilder: (context, index) {
                  return ReviewCard(
                    review: state.reviews[index],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExperienceTab(doctor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Education',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            doctor.education ?? 'No education information available',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text(
            'Experience',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            '${doctor.experienceYears} years of experience in ${doctor.specialty?.name ?? 'Unspecified Specialty'}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text(
            'License',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            'License Number: ${doctor.licenseNumber ?? 'Not available'}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddReviewDialog(BuildContext context) async {
    final authState = context.read<AuthCubit>().state;
    if (!authState.isAuthenticated || authState.user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You need to be logged in to add a review'),
          ),
        );
      }
      return;
    }

    int rating = 5;
    final commentController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Rate your experience'),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setState) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            rating = index + 1;
                          });
                        },
                      );
                    }),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  labelText: 'Comment (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            BlocBuilder<ReviewCubit, ReviewState>(
              builder: (context, state) {
                return TextButton(
                  onPressed: state.isSubmitting
                      ? null
                      : () async {
                          final success = await context.read<ReviewCubit>().submitReview(
                                doctorId: widget.doctorId,
                                patientId: authState.user!.id,
                                rating: rating,
                                comment: commentController.text.isNotEmpty ? commentController.text : null,
                              );

                          if (success && mounted) {
                            Navigator.of(context).pop();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Review submitted successfully'),
                              ),
                            );
                          }
                        },
                  child: state.isSubmitting ? const CircularProgressIndicator() : const Text('Submit'),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
