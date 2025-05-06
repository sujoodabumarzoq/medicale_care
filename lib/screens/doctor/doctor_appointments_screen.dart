import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medicale_care/cubits/appointment/appointment_state.dart';
import 'package:medicale_care/cubits/auth/auth_state.dart';

import '../../cubits/appointment/appointment_cubit.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../models/appointment_model.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DateFormat _dateFormat = DateFormat('MMMM d, yyyy');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadAppointments();
  }

  void _loadAppointments() {
    final authState = context.read<AuthCubit>().state;
    if (authState.isAuthenticated && authState.user != null) {
      context.read<AppointmentCubit>().loadDoctorAppointments(authState.user!.id);
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
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Confirmed'),
            Tab(text: 'Completed'),
            Text('Cancelled'),
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
              _buildAppointmentList(filter: (appointment) => true),
              _buildAppointmentList(filter: (appointment) => appointment.isPending),
              _buildAppointmentList(filter: (appointment) => appointment.isConfirmed),
              _buildAppointmentList(filter: (appointment) => appointment.isCompleted),
              _buildAppointmentList(filter: (appointment) => appointment.isCancelled),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppointmentList({
    required bool Function(AppointmentModel appointment) filter,
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

        // Group appointments by date
        final groupedAppointments = <DateTime, List<AppointmentModel>>{};
        for (final appointment in filteredAppointments) {
          final date = appointment.appointmentDate;
          if (!groupedAppointments.containsKey(date)) {
            groupedAppointments[date] = [];
          }
          groupedAppointments[date]!.add(appointment);
        }

        // Sort dates
        final sortedDates = groupedAppointments.keys.toList()..sort((a, b) => a.compareTo(b));

        return RefreshIndicator(
          onRefresh: () async {
            _loadAppointments();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final date = sortedDates[index];
              final appointments = groupedAppointments[date]!;

              // Sort appointments by time
              appointments.sort((a, b) => a.startTime.compareTo(b.startTime));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _dateFormat.format(date),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: appointments.length,
                    itemBuilder: (context, i) {
                      return _buildAppointmentCard(appointments[i]);
                    },
                  ),
                  const Divider(height: 32),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  backgroundImage: appointment.patientImageUrl != null ? NetworkImage(appointment.patientImageUrl!) : null,
                  child: appointment.patientImageUrl == null
                      ? Text(
                          appointment.patientName?.substring(0, 1) ?? 'P',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.patientName ?? 'Patient',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${appointment.startTime} - ${appointment.endTime}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appointment.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(appointment.status),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (appointment.symptoms != null && appointment.symptoms!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Symptoms:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment.symptoms!,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
            if (appointment.isPending || appointment.isConfirmed) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () => _updateAppointmentStatus(
                      appointment.id,
                      appointment.isPending ? 'confirmed' : 'completed',
                    ),
                    icon: Icon(
                      appointment.isPending ? Icons.check : Icons.done_all,
                      color: Theme.of(context).primaryColor,
                      size: 18,
                    ),
                    label: Text(
                      appointment.isPending ? 'Confirm' : 'Complete',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _updateAppointmentStatus(
                      appointment.id,
                      'cancelled',
                    ),
                    icon: const Icon(
                      Icons.cancel,
                      color: Colors.red,
                      size: 18,
                    ),
                    label: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _updateAppointmentStatus(String appointmentId, String status) async {
    final authState = context.read<AuthCubit>().state;
    if (!authState.isAuthenticated || authState.user == null) return;

    final success = await context.read<AppointmentCubit>().updateAppointmentStatus(
          appointmentId,
          status,
          authState.user!.id,
        );

    if (success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment ${status.toLowerCase()} successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update appointment status to ${status.toLowerCase()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
