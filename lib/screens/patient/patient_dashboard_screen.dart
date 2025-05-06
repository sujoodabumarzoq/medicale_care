import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicale_care/cubits/appointment/appointment_cubit.dart';
import 'package:medicale_care/cubits/appointment/appointment_state.dart';
import 'package:medicale_care/cubits/doctor/doctor_state.dart';
import 'package:medicale_care/cubits/navigation_cubit.dart';
import 'package:medicale_care/cubits/speciality/specialty_cubit.dart';
import 'package:medicale_care/cubits/speciality/specialty_state.dart';
import 'package:medicale_care/screens/auth/login_screen.dart';
import 'package:medicale_care/screens/patient/appointment_list_screen.dart';
import 'package:medicale_care/screens/patient/doctor_detail_screen.dart';
import 'package:medicale_care/screens/patient/doctor_list_screen.dart';
import 'package:medicale_care/screens/patient/emergency_contact_screen.dart';
import 'package:medicale_care/screens/patient/patient_profile_screen.dart';
import 'package:medicale_care/screens/patient/popular_doctors_screen.dart';
import 'package:medicale_care/screens/patient/specialty_list_screen.dart';
import 'package:medicale_care/widgets/appointment_card.dart';
import 'package:medicale_care/widgets/doctor_card.dart';
import 'package:medicale_care/widgets/specialty_card.dart';

import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/doctor/doctor_cubit.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authState = context.read<AuthCubit>().state;
    if (authState.isAuthenticated && authState.user != null) {
      context.read<DoctorCubit>().loadPopularDoctors();
      context.read<SpecialtyCubit>().loadAllSpecialties();
      context.read<AppointmentCubit>().loadPatientAppointments(authState.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<NavigationCubit, int>(
        builder: (context, selectedIndex) {
          return _buildBody(selectedIndex);
        },
      ),
      bottomNavigationBar: BlocBuilder<NavigationCubit, int>(
        builder: (context, selectedIndex) {
          return BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (index) {
              // Update the navigation state when an item is tapped
              context.read<NavigationCubit>().setIndex(index);
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_outlined),
                activeIcon: Icon(Icons.search),
                label: 'Doctors',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                activeIcon: Icon(Icons.calendar_today),
                label: 'Appointments',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return const PatientHomeScreen();
      case 1:
        return const DoctorListScreen();
      case 2:
        return const AppointmentListScreen();
      case 3:
        return const PatientProfileScreen();
      default:
        return const PatientHomeScreen();
    }
  }
}

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

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
              context.read<DoctorCubit>().loadPopularDoctors();
              context.read<SpecialtyCubit>().loadAllSpecialties();
              context.read<AppointmentCubit>().loadPatientAppointments(authState.user!.id);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(context, authState),
                const SizedBox(height: 24),
                _buildEmergencyCard(context),
                const SizedBox(height: 24),
                _buildUpcomingAppointments(context, authState.user!.id),
                const SizedBox(height: 24),
                _buildSpecialties(context),
                const SizedBox(height: 24),
                _buildPopularDoctors(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AuthState authState) {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          backgroundImage: authState.user?.profileImageUrl != null ? NetworkImage(authState.user!.profileImageUrl!) : null,
          child: authState.user?.profileImageUrl == null
              ? Text(
                  authState.user?.fullName.substring(0, 1) ?? 'P',
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
                'Hello, ${authState.user?.fullName ?? 'Patient'}!',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                'How are you feeling today?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await context.read<AuthCubit>().signOut();
            if (context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildEmergencyCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EmergencyContactScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF4060), Color(0xFFFF7043)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_hospital_outlined,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Emergency',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Get quick access to emergency numbers and nearest hospitals',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingAppointments(BuildContext context, String patientId) {
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
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AppointmentListScreen()),
                );
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BlocBuilder<AppointmentCubit, AppointmentState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state.hasError) {
              return Center(
                child: Text(
                  state.errorMessage ?? 'Failed to load appointments',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (!state.hasAppointments) {
              return const Center(
                child: Text('No upcoming appointments'),
              );
            }

            // Filter upcoming appointments (pending or confirmed)
            final upcomingAppointments = state.appointments.where((appointment) => appointment.isPending || appointment.isConfirmed).toList();

            if (upcomingAppointments.isEmpty) {
              return const Center(
                child: Text('No upcoming appointments'),
              );
            }

            // Show only the next 2 appointments
            final displayAppointments = upcomingAppointments.take(2).toList();

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayAppointments.length,
              itemBuilder: (context, index) {
                return AppointmentCard(
                  appointment: displayAppointments[index],
                  onTap: () {
                    // Navigate to appointment details
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSpecialties(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Specialties',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SpecialtyListScreen()),
                );
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BlocBuilder<SpecialtyCubit, SpecialtyState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state.hasError) {
              return Center(
                child: Text(
                  state.errorMessage ?? 'Failed to load specialties',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (!state.hasData) {
              return const Center(
                child: Text('No specialties available'),
              );
            }

            // Show only the first 4 specialties
            final displaySpecialties = state.specialties.take(4).toList();

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displaySpecialties.length,
              itemBuilder: (context, index) {
                return SpecialtyCard(
                  specialty: displaySpecialties[index],
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DoctorListScreen(
                          specialtyId: displaySpecialties[index].id,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildPopularDoctors(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Popular Doctors',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PopularDoctorsScreen()),
                );
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BlocBuilder<DoctorCubit, DoctorState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state.hasError) {
              return Center(
                child: Text(
                  state.errorMessage ?? 'Failed to load doctors',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (state.popularDoctors.isEmpty) {
              return const Center(
                child: Text('No popular doctors available'),
              );
            }

            // Show only the first 3 popular doctors
            final displayDoctors = state.popularDoctors.take(3).toList();

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayDoctors.length,
              // lib/screens/patient/patient_dashboard_screen.dart (continued)
              itemBuilder: (context, index) {
                return DoctorCard(
                  doctor: displayDoctors[index],
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DoctorDetailScreen(
                          doctorId: displayDoctors[index].id,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
