import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicale_care/cubits/doctor/doctor_state.dart';

import '../../cubits/doctor/doctor_cubit.dart';
import '../../widgets/doctor_card.dart';
import 'doctor_detail_screen.dart';

class PopularDoctorsScreen extends StatefulWidget {
  const PopularDoctorsScreen({super.key});

  @override
  State<PopularDoctorsScreen> createState() => _PopularDoctorsScreenState();
}

class _PopularDoctorsScreenState extends State<PopularDoctorsScreen> {
  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  void _loadDoctors() {
    context.read<DoctorCubit>().loadPopularDoctors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Popular Doctors'),
      ),
      body: BlocBuilder<DoctorCubit, DoctorState>(
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
                    state.errorMessage ?? 'Failed to load doctors',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadDoctors,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.popularDoctors.isEmpty) {
            return const Center(
              child: Text('No popular doctors available'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadDoctors();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.popularDoctors.length,
              itemBuilder: (context, index) {
                final doctor = state.popularDoctors[index];

                return DoctorCard(
                  doctor: doctor,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DoctorDetailScreen(
                          doctorId: doctor.id,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
