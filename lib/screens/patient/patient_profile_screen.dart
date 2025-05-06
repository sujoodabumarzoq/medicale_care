// lib/screens/patient/patient_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/patient/patient_cubit.dart';
import '../../cubits/patient/patient_state.dart';
import '../auth/login_screen.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  DateTime? _dateOfBirth;
  String? _bloodType;
  final _allergiesController = TextEditingController();
  final _medicalHistoryController = TextEditingController();

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authState = context.read<AuthCubit>().state;
    if (authState.isAuthenticated && authState.user != null) {
      // Pre-fill user data from auth state
      _fullNameController.text = authState.user!.fullName;
      _phoneNumberController.text = authState.user!.phoneNumber ?? '';

      // Load patient-specific profile
      context.read<PatientCubit>().loadPatientProfile(authState.user!.id);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _allergiesController.dispose();
    _medicalHistoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              if (!authState.isAuthenticated) return const SizedBox.shrink();

              return IconButton(
                icon: Icon(_isEditing ? Icons.close : Icons.edit),
                onPressed: () {
                  setState(() {
                    if (_isEditing) {
                      // Cancel editing - reset form
                      _resetForm(authState);
                    }
                    _isEditing = !_isEditing;
                  });
                },
              );
            },
          ),
        ],
      ),
      body: BlocListener<PatientCubit, PatientState>(
        listener: (context, patientState) {
          if (patientState.status == PatientStatus.loaded && patientState.patient != null && !_isEditing) {
            // Pre-fill patient data when loaded and not in edit mode
            setState(() {
              _dateOfBirth = patientState.patient!.dateOfBirth;
              _bloodType = patientState.patient!.bloodType;
              _allergiesController.text = patientState.patient!.allergies ?? '';
              _medicalHistoryController.text = patientState.patient!.medicalHistory ?? '';
            });
          }

          if (patientState.status == PatientStatus.updated) {
            // Profile updated successfully
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: Colors.green,
              ),
            );

            setState(() {
              _isEditing = false;
            });
          }

          if (patientState.status == PatientStatus.error) {
            // Error updating profile
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(patientState.errorMessage ?? 'An error occurred'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            return BlocBuilder<PatientCubit, PatientState>(
              builder: (context, patientState) {
                if (patientState.isLoading && patientState.patient == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileHeader(authState),
                        const SizedBox(height: 24),
                        _buildPersonalInfoSection(authState, patientState),
                        const SizedBox(height: 24),
                        _buildMedicalInfoSection(patientState),
                        const SizedBox(height: 24),
                        if (_isEditing) _buildUpdateButton(authState),
                        const SizedBox(height: 24),
                        _buildLogoutButton(),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AuthState authState) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _isEditing ? _pickProfileImage : null,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  backgroundImage: authState.user!.profileImageUrl != null ? NetworkImage(authState.user!.profileImageUrl!) : null,
                  child: authState.user!.profileImageUrl == null
                      ? Text(
                          authState.user!.fullName.substring(0, 1),
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        )
                      : null,
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            authState.user!.fullName,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            authState.user!.email,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(AuthState authState, PatientState patientState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Information',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _isEditing
            ? TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              )
            : _buildInfoTile(
                icon: Icons.person,
                title: 'Full Name',
                value: authState.user!.fullName,
              ),
        const SizedBox(height: 16),
        _isEditing
            ? TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              )
            : _buildInfoTile(
                icon: Icons.phone,
                title: 'Phone Number',
                value: authState.user!.phoneNumber ?? 'Not provided',
              ),
        const SizedBox(height: 16),
        _isEditing
            ? InkWell(
                onTap: _pickDateOfBirth,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _dateOfBirth != null ? DateFormat('MMMM d, y').format(_dateOfBirth!) : 'Select date',
                  ),
                ),
              )
            : _buildInfoTile(
                icon: Icons.calendar_today,
                title: 'Date of Birth',
                value:
                    patientState.patient?.dateOfBirth != null ? DateFormat('MMMM d, y').format(patientState.patient!.dateOfBirth!) : 'Not provided',
              ),
      ],
    );
  }

  Widget _buildMedicalInfoSection(PatientState patientState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Medical Information',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _isEditing
            ? DropdownButtonFormField<String>(
                value: _bloodType,
                decoration: const InputDecoration(
                  labelText: 'Blood Type',
                  prefixIcon: Icon(Icons.bloodtype),
                  border: OutlineInputBorder(),
                ),
                items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                    .map((type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _bloodType = value;
                  });
                },
              )
            : _buildInfoTile(
                icon: Icons.bloodtype,
                title: 'Blood Type',
                value: patientState.patient?.bloodType ?? 'Not provided',
              ),
        const SizedBox(height: 16),
        _isEditing
            ? TextFormField(
                controller: _allergiesController,
                decoration: const InputDecoration(
                  labelText: 'Allergies',
                  prefixIcon: Icon(Icons.warning_amber),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              )
            : _buildInfoTile(
                icon: Icons.warning_amber,
                title: 'Allergies',
                value: patientState.patient?.allergies ?? 'None',
              ),
        const SizedBox(height: 16),
        _isEditing
            ? TextFormField(
                controller: _medicalHistoryController,
                decoration: const InputDecoration(
                  labelText: 'Medical History',
                  prefixIcon: Icon(Icons.history),
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              )
            : _buildInfoTile(
                icon: Icons.history,
                title: 'Medical History',
                value: patientState.patient?.medicalHistory ?? 'None',
                maxLines: 5,
              ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  style: const TextStyle(fontSize: 16),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton(AuthState authState) {
    return BlocBuilder<PatientCubit, PatientState>(
      builder: (context, state) {
        final isUpdating = state.status == PatientStatus.updating;

        return ElevatedButton(
          onPressed: isUpdating
              ? null
              : () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _updateProfile(authState);
                  }
                },
          child: isUpdating
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Update Profile'),
        );
      },
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
      onPressed: () async {
        await context.read<AuthCubit>().signOut();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
      ),
      child: const Text('Logout'),
    );
  }

  void _resetForm(AuthState authState) {
    _fullNameController.text = authState.user!.fullName;
    _phoneNumberController.text = authState.user!.phoneNumber ?? '';

    final patientState = context.read<PatientCubit>().state;
    if (patientState.patient != null) {
      _dateOfBirth = patientState.patient!.dateOfBirth;
      _bloodType = patientState.patient!.bloodType;
      _allergiesController.text = patientState.patient!.allergies ?? '';
      _medicalHistoryController.text = patientState.patient!.medicalHistory ?? '';
    }
  }

  Future<void> _pickDateOfBirth() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _dateOfBirth = pickedDate;
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture upload not implemented'),
        ),
      );
    }
  }

  void _updateProfile(AuthState authState) async {
    // First update auth profile
    await context.read<AuthCubit>().updateProfile(
          fullName: _fullNameController.text,
          phoneNumber: _phoneNumberController.text,
        );

    await context.read<PatientCubit>().updatePatientProfile(
          patientId: authState.user!.id,
          dateOfBirth: _dateOfBirth,
          bloodType: _bloodType,
          allergies: _allergiesController.text,
          medicalHistory: _medicalHistoryController.text,
        );
  }
}
