import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicale_care/cubits/speciality/specialty_cubit.dart';
import 'package:medicale_care/cubits/speciality/specialty_state.dart';

import '../../models/specialty_model.dart';
import 'doctor_list_screen.dart';

class SpecialtyListScreen extends StatefulWidget {
  const SpecialtyListScreen({super.key});

  @override
  State<SpecialtyListScreen> createState() => _SpecialtyListScreenState();
}

class _SpecialtyListScreenState extends State<SpecialtyListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<SpecialtyModel> _filteredSpecialties = [];

  @override
  void initState() {
    super.initState();
    context.read<SpecialtyCubit>().loadAllSpecialties();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSpecialties(String query) {
    final state = context.read<SpecialtyCubit>().state;
    if (state.specialties.isEmpty) return;

    setState(() {
      if (query.isEmpty) {
        _filteredSpecialties = state.specialties;
      } else {
        _filteredSpecialties = state.specialties
            .where((specialty) =>
                specialty.name.toLowerCase().contains(query.toLowerCase()) ||
                (specialty.description?.toLowerCase().contains(query.toLowerCase()) ?? false))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Specialties'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search specialties...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterSpecialties('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _filterSpecialties,
            ),
          ),
          Expanded(
            child: BlocConsumer<SpecialtyCubit, SpecialtyState>(
              listener: (context, state) {
                if (state.status == SpecialtyStatus.loaded) {
                  setState(() {
                    _filteredSpecialties = state.specialties;
                  });
                }
              },
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
                          state.errorMessage ?? 'Failed to load specialties',
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<SpecialtyCubit>().loadAllSpecialties();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (!state.hasData || _filteredSpecialties.isEmpty) {
                  return const Center(
                    child: Text('No specialties found'),
                  );
                }

                return _buildSpecialtyGrid(_filteredSpecialties);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtyGrid(List<SpecialtyModel> specialties) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: specialties.length,
      itemBuilder: (context, index) {
        final specialty = specialties[index];
        return _buildSpecialtyCard(specialty);
      },
    );
  }

  Widget _buildSpecialtyCard(SpecialtyModel specialty) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DoctorListScreen(
              specialtyId: specialty.id,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconData(specialty.icon ?? specialty.name),
                color: Theme.of(context).primaryColor,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              specialty.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (specialty.description != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  specialty.description!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String specialtyName) {
    final name = specialtyName.toLowerCase();

    if (name.contains('cardio')) return Icons.favorite;
    if (name.contains('dent')) return Icons.elderly;
    if (name.contains('eye') || name.contains('ophthal')) return Icons.remove_red_eye;
    if (name.contains('neuro')) return Icons.psychology;
    if (name.contains('ortho')) return Icons.accessibility_new;
    if (name.contains('pediatr')) return Icons.child_care;
    if (name.contains('derma')) return Icons.face;
    if (name.contains('psych')) return Icons.sentiment_satisfied_alt;
    if (name.contains('gyneco')) return Icons.female;
    if (name.contains('uro')) return Icons.male;

    return Icons.medical_services;
  }
}
