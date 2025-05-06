import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medicale_care/cubits/appointment/appointment_state.dart';
import 'package:medicale_care/cubits/doctor/doctor_state.dart';
import 'package:medicale_care/screens/chat/doctor_chats_screen.dart';
import 'package:medicale_care/screens/doctor/doctor_appointments_screen.dart';
import 'package:medicale_care/screens/doctor/doctor_availability_screen.dart';
import 'package:medicale_care/screens/doctor/doctor_profile_screen.dart';

import '../../cubits/appointment/appointment_cubit.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/doctor/doctor_cubit.dart';
import '../../models/appointment_model.dart';
import '../auth/login_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authState = context.read<AuthCubit>().state;
    if (authState.isAuthenticated && authState.user != null) {
      context.read<DoctorCubit>().loadDoctorDetails(authState.user!.id);
      context.read<AppointmentCubit>().loadDoctorAppointments(authState.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Appointments',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.access_time_outlined),
            activeIcon: Icon(Icons.access_time),
            label: 'Availability',
          ),
          if (context.read<AuthCubit>().state.user?.role == 'doctor') ...[
            const BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              activeIcon: Icon(Icons.chat),
              label: 'Chats',
            ),
          ],
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const DoctorHomeScreen();
      case 1:
        return const DoctorAppointmentsScreen();
      case 2:
        return const DoctorAvailabilityScreen();
      case 3:
        return DoctorChatsScreen(
          doctorId: context.read<AuthCubit>().state.user!.id,
        );
      case 4:
        return const DoctorProfileScreen();
      default:
        return const DoctorHomeScreen();
    }
  }
}

class DoctorHomeScreen extends StatelessWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (!authState.isAuthenticated || authState.user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              if (authState.user != null) {
                context.read<DoctorCubit>().loadDoctorDetails(authState.user!.id);
                context.read<AppointmentCubit>().loadDoctorAppointments(authState.user!.id);
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, authState),
                  const SizedBox(height: 24),
                  _buildStatCards(context),
                  const SizedBox(height: 24),
                  _buildTodayAppointments(context, authState.user!.id),
                  const SizedBox(height: 24),
                  _buildUpcomingAppointments(context, authState.user!.id),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AuthState authState) {
    return BlocBuilder<DoctorCubit, DoctorState>(
      builder: (context, doctorState) {
        final isAvailable = doctorState.selectedDoctor?.isAvailable ?? false;

        return Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              backgroundImage: authState.user?.profileImageUrl != null ? NetworkImage(authState.user!.profileImageUrl!) : null,
              child: authState.user?.profileImageUrl == null
                  ? Text(
                      authState.user?.fullName.substring(0, 1) ?? 'D',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. ${authState.user?.fullName ?? ''}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    doctorState.selectedDoctor?.specialty?.name ?? 'Doctor',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Switch(
              value: isAvailable,
              activeColor: Theme.of(context).primaryColor,
              onChanged: (value) {
                if (authState.user != null) {
                  context.read<DoctorCubit>().toggleDoctorAvailability(
                        doctorId: authState.user!.id,
                        isAvailable: value,
                      );
                }
              },
            ),
            Column(
              children: [
                Text(
                  isAvailable ? 'Available' : 'Unavailable',
                  style: TextStyle(
                    color: isAvailable ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Status',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );

                await context.read<AuthCubit>().signOut();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCards(BuildContext context) {
    return BlocBuilder<AppointmentCubit, AppointmentState>(
      builder: (context, state) {
        // Calculate stats from appointments
        int totalAppointments = state.appointments.length;
        int pendingAppointments = state.appointments.where((apt) => apt.isPending).length;
        int todayAppointments = state.appointments.where((apt) {
          final today = DateTime.now();
          return apt.appointmentDate.year == today.year && apt.appointmentDate.month == today.month && apt.appointmentDate.day == today.day;
        }).length;
        int completedAppointments = state.appointments.where((apt) => apt.isCompleted).length;

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Today',
                todayAppointments.toString(),
                Colors.blue,
                Icons.today,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Pending',
                pendingAppointments.toString(),
                Colors.orange,
                Icons.pending_actions,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Total',
                totalAppointments.toString(),
                Colors.purple,
                Icons.people,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Completed',
                completedAppointments.toString(),
                Colors.green,
                Icons.check_circle,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
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
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayAppointments(BuildContext context, String doctorId) {
    final today = DateTime.now();
    final dateFormat = DateFormat('MMMM d, yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Appointments",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              dateFormat.format(today),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        BlocBuilder<AppointmentCubit, AppointmentState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // Filter today's appointments
            final todayAppointments = state.appointments.where((apt) {
              return apt.appointmentDate.year == today.year && apt.appointmentDate.month == today.month && apt.appointmentDate.day == today.day;
            }).toList();

            // Sort by time
            todayAppointments.sort((a, b) {
              return a.startTime.compareTo(b.startTime);
            });

            if (todayAppointments.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('No appointments for today'),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: todayAppointments.length,
              itemBuilder: (context, index) {
                final appointment = todayAppointments[index];
                return _buildAppointmentCard(context, appointment);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildUpcomingAppointments(BuildContext context, String doctorId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Appointments',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                // Navigate to appointments tab
                (context.findAncestorStateOfType<_DoctorDashboardScreenState>())?.setState(() {
                  (context.findAncestorStateOfType<_DoctorDashboardScreenState>())?._selectedIndex = 1;
                });
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        BlocBuilder<AppointmentCubit, AppointmentState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final today = DateTime.now();

            // Filter upcoming appointments (excluding today)
            final upcomingAppointments = state.appointments.where((apt) {
              final appointmentDate = apt.appointmentDate;
              final isToday = appointmentDate.year == today.year && appointmentDate.month == today.month && appointmentDate.day == today.day;

              final isFuture = appointmentDate.isAfter(today);

              return (isFuture && !isToday) && (apt.isPending || apt.isConfirmed);
            }).toList();

            // Sort by date
            upcomingAppointments.sort((a, b) {
              int dateComparison = a.appointmentDate.compareTo(b.appointmentDate);
              if (dateComparison != 0) return dateComparison;
              return a.startTime.compareTo(b.startTime);
            });

            if (upcomingAppointments.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('No upcoming appointments'),
                ),
              );
            }

            // Show only the next 3 upcoming appointments
            final displayAppointments = upcomingAppointments.take(3).toList();

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayAppointments.length,
              itemBuilder: (context, index) {
                final appointment = displayAppointments[index];
                return _buildAppointmentCard(context, appointment);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(BuildContext context, AppointmentModel appointment) {
    final dateFormat = DateFormat('MMMM d, yyyy');

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
                            Icons.calendar_today,
                            size: 14,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dateFormat.format(appointment.appointmentDate),
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          appointment.startTime,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ])
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
            if (appointment.isPending || appointment.isConfirmed) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    context,
                    appointment.isPending ? 'Confirm' : 'Complete',
                    appointment.isPending ? Icons.check : Icons.done_all,
                    Theme.of(context).primaryColor,
                    () => _updateAppointmentStatus(
                      context,
                      appointment.id,
                      appointment.isPending ? 'confirmed' : 'completed',
                      context.read<AuthCubit>().state.user!.id,
                    ),
                  ),
                  _buildActionButton(
                    context,
                    'Cancel',
                    Icons.cancel,
                    Colors.red,
                    () => _updateAppointmentStatus(
                      context,
                      appointment.id,
                      'cancelled',
                      context.read<AuthCubit>().state.user!.id,
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

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: color,
        size: 18,
      ),
      label: Text(
        label,
        style: TextStyle(color: color),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  void _updateAppointmentStatus(
    BuildContext context,
    String appointmentId,
    String status,
    String doctorId,
  ) async {
    final success = await context.read<AppointmentCubit>().updateAppointmentStatus(
          appointmentId,
          status,
          doctorId,
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
