import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medicale_care/cubits/appointment/appointment_state.dart';
import 'package:medicale_care/cubits/doctor/doctor_state.dart';
import 'package:medicale_care/screens/patient/appointment_success_screen.dart';

import '../../cubits/appointment/appointment_cubit.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/doctor/doctor_cubit.dart';

class BookAppointmentScreen extends StatefulWidget {
  final String doctorId;

  const BookAppointmentScreen({super.key, required this.doctorId});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _symptomsController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTimeSlot;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<DoctorCubit>().loadDoctorDetails(widget.doctorId);
    context.read<AppointmentCubit>().loadDoctorAvailability(widget.doctorId);
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDoctorInfo(),
            const SizedBox(height: 24),
            _buildDateSelector(),
            const SizedBox(height: 24),
            _buildTimeSlots(),
            const SizedBox(height: 24),
            _buildAppointmentDetails(),
            const SizedBox(height: 32),
            BlocBuilder<AppointmentCubit, AppointmentState>(
              builder: (context, state) {
                final isBookingInProgress = state.isBookingInProgress;
                final hasSelectedTimeSlot = _selectedTimeSlot != null;

                return ElevatedButton(
                  onPressed: isBookingInProgress || !hasSelectedTimeSlot ? null : _bookAppointment,
                  child: isBookingInProgress
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Book Appointment'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorInfo() {
    return BlocBuilder<DoctorCubit, DoctorState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.hasError || state.selectedDoctor == null) {
          return const Center(
            child: Text('Failed to load doctor details'),
          );
        }

        final doctor = state.selectedDoctor!;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  backgroundImage: doctor.user.profileImageUrl != null ? NetworkImage(doctor.user.profileImageUrl!) : null,
                  child: doctor.user.profileImageUrl == null
                      ? Text(
                          doctor.user.fullName.substring(0, 1),
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
                        'Dr. ${doctor.user.fullName}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        doctor.specialty != null ? doctor.specialty!.name : '',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Consultation Fee: \$${doctor.consultationFee.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 14, // Show next 14 days
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index));
              final isSelected = _selectedDate.year == date.year && _selectedDate.month == date.month && _selectedDate.day == date.day;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                    _selectedTimeSlot = null; // Reset time slot when date changes
                  });
                  context.read<AppointmentCubit>().selectDate(date);
                },
                child: Container(
                  width: 70,
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('E').format(date),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd').format(date),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM').format(date),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlots() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Time Slot',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        BlocBuilder<DoctorCubit, DoctorState>(
          builder: (context, doctorState) {
            if (doctorState.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (doctorState.hasError || doctorState.selectedDoctor == null) {
              return const Center(
                child: Text('Failed to load doctor details'),
              );
            }

            return BlocBuilder<AppointmentCubit, AppointmentState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Get day of week (0-6, Sunday to Saturday)
                final dayOfWeek = _selectedDate.weekday % 7;

                // Filter availabilities for the selected day
                final dayAvailabilities = state.availabilities.where((avail) => avail.dayOfWeek == dayOfWeek).toList();

                if (dayAvailabilities.isEmpty) {
                  return const Center(
                    child: Text('No available time slots for this day'),
                  );
                }

                // Generate time slots based on availabilities
                final timeSlots = <String>[];
                for (final avail in dayAvailabilities) {
                  // Parse start and end times
                  final startParts = avail.startTime.split(':');
                  final endParts = avail.endTime.split(':');

                  final startHour = int.parse(startParts[0]);
                  final startMinute = int.parse(startParts[1]);
                  final endHour = int.parse(endParts[0]);
                  final endMinute = int.parse(endParts[1]);

                  // Create a DateTime object for today with the start time
                  final startTime = DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    startHour,
                    startMinute,
                  );

                  // Create a DateTime object for today with the end time
                  final endTime = DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    endHour,
                    endMinute,
                  );

                  // Generate 30-minute slots
                  var currentSlot = startTime;
                  while (currentSlot.isBefore(endTime)) {
                    final slotTime = DateFormat('HH:mm').format(currentSlot);
                    timeSlots.add(slotTime);
                    currentSlot = currentSlot.add(const Duration(minutes: 30));
                  }
                }

                if (timeSlots.isEmpty) {
                  return const Center(
                    child: Text('No available time slots for this day'),
                  );
                }

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: timeSlots.map((timeSlot) {
                    final isSelected = _selectedTimeSlot == timeSlot;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTimeSlot = timeSlot;
                        });
                        context.read<AppointmentCubit>().selectTimeSlot(timeSlot);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Theme.of(context).primaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          timeSlot,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAppointmentDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Appointment Details',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _symptomsController,
          decoration: const InputDecoration(
            labelText: 'Symptoms',
            hintText: 'Describe your symptoms',
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Additional Notes',
            hintText: 'Any additional information for the doctor',
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  void _bookAppointment() async {
    final authState = context.read<AuthCubit>().state;
    if (!authState.isAuthenticated || authState.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to be logged in to book an appointment'),
        ),
      );
      return;
    }

    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time slot'),
        ),
      );
      return;
    }

    // Parse selected time
    final timeParts = _selectedTimeSlot!.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    // Create appointment start time
    final appointmentDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    final startTime = '$hour:$minute';

    // Calculate end time (30 minutes after start)
    final endDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      hour,
      minute,
    ).add(const Duration(minutes: 30));

    final endTime = '${endDateTime.hour}:${endDateTime.minute}';

    final success = await context.read<AppointmentCubit>().bookAppointment(
          patientId: authState.user!.id,
          doctorId: widget.doctorId,
          appointmentDate: appointmentDate,
          startTime: startTime,
          endTime: endTime,
          symptoms: _symptomsController.text,
          notes: _notesController.text,
        );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AppointmentSuccessScreen(
            doctorId: widget.doctorId,
            appointmentDate: _selectedDate,
            appointmentTime: _selectedTimeSlot!,
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to book appointment. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
