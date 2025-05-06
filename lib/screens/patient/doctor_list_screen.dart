import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicale_care/cubits/doctor/doctor_cubit.dart';
import 'package:medicale_care/cubits/doctor/doctor_state.dart';
import 'package:medicale_care/cubits/speciality/specialty_cubit.dart';
import 'package:medicale_care/cubits/speciality/specialty_state.dart';
import 'package:medicale_care/screens/patient/doctor_detail_screen.dart';
import 'package:medicale_care/widgets/doctor_card.dart';

class DoctorListScreen extends StatefulWidget {
  final String? specialtyId;

  const DoctorListScreen({super.key, this.specialtyId});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _currentSpecialtyId;

  @override
  void initState() {
    super.initState();
    _currentSpecialtyId = widget.specialtyId;
    _loadDoctors();
  }

  void _loadDoctors() {
    if (_currentSpecialtyId != null) {
      context.read<DoctorCubit>().loadDoctorsBySpecialty(_currentSpecialtyId!);
      context.read<SpecialtyCubit>().loadSpecialtyDetails(_currentSpecialtyId!);
    } else {
      context.read<DoctorCubit>().loadAllDoctors();
      context.read<SpecialtyCubit>().loadAllSpecialties();
    }
  }

  void _searchDoctors(String query) {
    if (query.isEmpty) {
      _loadDoctors();
    } else {
      context.read<DoctorCubit>().searchDoctors(query);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.specialtyId != null
            ? BlocBuilder<SpecialtyCubit, SpecialtyState>(
                builder: (context, state) {
                  return Text(state.selectedSpecialty?.name ?? 'Doctors');
                },
              )
            : const Text('Find Doctors'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search doctors...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadDoctors();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _searchDoctors,
            ),
          ),
          _buildSpecialtyFilter(context),
          Expanded(
            child: BlocBuilder<DoctorCubit, DoctorState>(
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

                if (!state.hasData || state.doctors.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _loadDoctors();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.doctors.length,
                    itemBuilder: (context, index) {
                      return DoctorCard(
                        doctor: state.doctors[index],
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DoctorDetailScreen(
                                doctorId: state.doctors[index].id,
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
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _currentSpecialtyId != null ? 'No doctors found in this specialty' : 'No doctors available',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _currentSpecialtyId != null ? 'Try selecting a different specialty' : 'Please check back later',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtyFilter(BuildContext context) {
    return BlocBuilder<SpecialtyCubit, SpecialtyState>(
      builder: (context, state) {
        if (!state.hasData) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 50,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              // Add +1 for the "All" chip
              itemCount: state.specialties.length + 1,
              itemBuilder: (context, index) {
                // First item is the "All" chip
                if (index == 0) {
                  final isSelected = _currentSpecialtyId == null;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selectedColor: isSelected ? Theme.of(context).primaryColor : null,
                      label: Text(
                        'All',
                        style: TextStyle(
                          color: isSelected ? Colors.white : null,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _currentSpecialtyId = null;
                          });
                          context.read<DoctorCubit>().loadAllDoctors();
                        }
                      },
                    ),
                  );
                }

                final specialty = state.specialties[index - 1];
                final isSelected = _currentSpecialtyId == specialty.id;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    selectedColor: isSelected ? Theme.of(context).primaryColor : null,
                    label: Text(
                      specialty.name,
                      style: TextStyle(
                        color: isSelected ? Colors.white : null,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _currentSpecialtyId = specialty.id;
                        });
                        context.read<SpecialtyCubit>().selectSpecialty(specialty.id);
                        context.read<DoctorCubit>().loadDoctorsBySpecialty(specialty.id);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
