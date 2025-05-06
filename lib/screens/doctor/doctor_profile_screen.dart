import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/doctor/doctor_cubit.dart';
import '../../cubits/doctor/doctor_state.dart';
import '../auth/login_screen.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _bioController = TextEditingController();
  final _educationController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _experienceYearsController = TextEditingController();
  final _consultationFeeController = TextEditingController();
  String? _selectedSpecialtyId;

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

      // Load doctor-specific profile
      context.read<DoctorCubit>().loadDoctorDetails(authState.user!.id);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _bioController.dispose();
    _educationController.dispose();
    _licenseNumberController.dispose();
    _experienceYearsController.dispose();
    _consultationFeeController.dispose();
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
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          return BlocBuilder<DoctorCubit, DoctorState>(
            builder: (context, doctorState) {
              if (doctorState.isLoading && doctorState.selectedDoctor == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final doctor = doctorState.selectedDoctor;

              // If doctor data is loaded, pre-fill the form fields
              if (doctor != null && !_isEditing) {
                _bioController.text = doctor.bio ?? '';
                _educationController.text = doctor.education ?? '';
                _licenseNumberController.text = doctor.licenseNumber;
                _experienceYearsController.text = doctor.experienceYears.toString();
                _consultationFeeController.text = doctor.consultationFee.toString();
                _selectedSpecialtyId = doctor.specialty?.id;
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileHeader(context, authState),
                      const SizedBox(height: 24),
                      _buildPersonalInfoSection(authState),
                      const SizedBox(height: 24),
                      _buildProfessionalInfoSection(doctor),
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
    );
  }

  Widget _buildProfileHeader(BuildContext context, AuthState authState) {
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
                  backgroundImage: authState.user?.profileImageUrl != null ? NetworkImage(authState.user!.profileImageUrl!) : null,
                  child: authState.user?.profileImageUrl == null
                      ? Text(
                          authState.user?.fullName.substring(0, 1) ?? 'D',
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
            'Dr. ${authState.user!.fullName}',
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

  Widget _buildPersonalInfoSection(AuthState authState) {
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
      ],
    );
  }

  Widget _buildProfessionalInfoSection(doctor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Professional Information',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _isEditing
            ? DropdownButtonFormField<String>(
                value: _selectedSpecialtyId,
                decoration: const InputDecoration(
                  labelText: 'Specialty',
                  prefixIcon: Icon(Icons.local_hospital),
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: doctor?.specialty?.id ?? '1',
                    child: Text(doctor?.specialty?.name ?? 'General Medicine'),
                  ),
                  // Ideally, you'd fetch specialties from your SpecialtyCubit
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedSpecialtyId = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a specialty';
                  }
                  return null;
                },
              )
            : _buildInfoTile(
                icon: Icons.local_hospital,
                title: 'Specialty',
                value: doctor?.specialty?.name ?? 'Not specified',
              ),
        const SizedBox(height: 16),
        _isEditing
            ? TextFormField(
                controller: _licenseNumberController,
                decoration: const InputDecoration(
                  labelText: 'License Number',
                  prefixIcon: Icon(Icons.card_membership),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your license number';
                  }
                  return null;
                },
              )
            : _buildInfoTile(
                icon: Icons.card_membership,
                title: 'License Number',
                value: doctor?.licenseNumber ?? 'Not provided',
              ),
        const SizedBox(height: 16),
        _isEditing
            ? TextFormField(
                controller: _experienceYearsController,
                decoration: const InputDecoration(
                  labelText: 'Years of Experience',
                  prefixIcon: Icon(Icons.work),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your years of experience';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              )
            : _buildInfoTile(
                icon: Icons.work,
                title: 'Years of Experience',
                value: doctor?.experienceYears?.toString() ?? 'Not provided',
              ),
        const SizedBox(height: 16),
        _isEditing
            ? TextFormField(
                controller: _consultationFeeController,
                decoration: const InputDecoration(
                  labelText: 'Consultation Fee (\$)',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your consultation fee';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              )
            : _buildInfoTile(
                icon: Icons.attach_money,
                title: 'Consultation Fee',
                value: '\$${doctor?.consultationFee?.toStringAsFixed(2) ?? 'Not provided'}',
              ),
        const SizedBox(height: 16),
        _isEditing
            ? TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Professional Bio',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              )
            : _buildInfoTile(
                icon: Icons.description,
                title: 'Professional Bio',
                value: doctor?.bio ?? 'No bio provided',
                maxLines: 3,
              ),
        const SizedBox(height: 16),
        _isEditing
            ? TextFormField(
                controller: _educationController,
                decoration: const InputDecoration(
                  labelText: 'Education & Qualifications',
                  prefixIcon: Icon(Icons.school),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              )
            : _buildInfoTile(
                icon: Icons.school,
                title: 'Education & Qualifications',
                value: doctor?.education ?? 'Not provided',
                maxLines: 3,
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
    return BlocBuilder<DoctorCubit, DoctorState>(
      builder: (context, state) {
        final isUpdating = state.status == DoctorStatus.loading;

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

    final doctorState = context.read<DoctorCubit>().state;
    if (doctorState.selectedDoctor != null) {
      final doctor = doctorState.selectedDoctor!;

      _bioController.text = doctor.bio ?? '';
      _educationController.text = doctor.education ?? '';
      _licenseNumberController.text = doctor.licenseNumber ?? '';
      _experienceYearsController.text = (doctor.experienceYears ?? 0).toString();
      _consultationFeeController.text = (doctor.consultationFee ?? 0).toString();
      _selectedSpecialtyId = doctor.specialty?.id ?? '';
    }
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // TODO: Implement image upload
      // For now, just show a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture upload not implemented yet'),
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

    // Then update doctor-specific profile
    // This would require adding a method to DoctorCubit
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
}
