import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicale_care/cubits/appointment/appointment_state.dart';
import 'package:medicale_care/cubits/auth/auth_state.dart';
import 'package:medicale_care/widgets/appointment_card.dart';

import '../../cubits/appointment/appointment_cubit.dart';
import '../../cubits/auth/auth_cubit.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAppointments();
  }

  void _loadAppointments() {
    final authState = context.read<AuthCubit>().state;
    if (authState.isAuthenticated && authState.user != null) {
      context.read<AppointmentCubit>().loadPatientAppointments(authState.user!.id);
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
      appBar: AppBar(
        title: const Text('My Appointments'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          if (!authState.isAuthenticated || authState.user == null) {
            return const Center(
              child: Text('You need to be logged in to view appointments'),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildAppointmentList(
                filter: (appointment) => appointment.isPending || appointment.isConfirmed,
              ),
              _buildAppointmentList(
                filter: (appointment) => appointment.isCompleted,
              ),
              _buildAppointmentList(
                filter: (appointment) => appointment.isCancelled,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppointmentList({
    required bool Function(dynamic appointment) filter,
  }) {
    return BlocBuilder<AppointmentCubit, AppointmentState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.errorMessage ?? 'Failed to load appointments',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadAppointments,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final filteredAppointments = state.appointments.where(filter).toList();

        if (filteredAppointments.isEmpty) {
          return const Center(
            child: Text('No appointments found'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            _loadAppointments();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredAppointments.length,
            itemBuilder: (context, index) {
              final appointment = filteredAppointments[index];

              return AppointmentCard(
                appointment: appointment,
                onTap: () {},
                showCancelButton: appointment.isPending || appointment.isConfirmed,
                onCancel: () {
                  _showCancelDialog(appointment.id);
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showCancelDialog(String appointmentId) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Appointment'),
          content: const Text(
            'Are you sure you want to cancel this appointment? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                final authState = context.read<AuthCubit>().state;
                if (authState.isAuthenticated && authState.user != null) {
                  final success = await context.read<AppointmentCubit>().cancelAppointment(
                        appointmentId,
                        authState.user!.id,
                      );

                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Appointment cancelled successfully'),
                      ),
                    );
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to cancel appointment'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
