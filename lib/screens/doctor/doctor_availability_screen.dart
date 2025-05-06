import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicale_care/cubits/auth/auth_cubit.dart';
import 'package:medicale_care/cubits/auth/auth_state.dart';
import 'package:medicale_care/cubits/doctor/doctor_cubit.dart';
import 'package:medicale_care/cubits/doctor/doctor_state.dart';
import 'package:medicale_care/models/doctor_availability_model.dart';
import 'package:medicale_care/repositories/doctor_repository.dart';

class DoctorAvailabilityScreen extends StatefulWidget {
  const DoctorAvailabilityScreen({super.key});

  @override
  State<DoctorAvailabilityScreen> createState() => _DoctorAvailabilityScreenState();
}

class _DoctorAvailabilityScreenState extends State<DoctorAvailabilityScreen> {
  final List<String> _daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  final Map<int, List<DoctorAvailabilityModel>> _availabilityByDay = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    final authState = context.read<AuthCubit>().state;
    if (!authState.isAuthenticated || authState.user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final doctorRepository = DoctorRepository();
      final availabilities = await doctorRepository.getDoctorAvailability(
        authState.user!.id,
      );

      // Group by day of week
      _availabilityByDay.clear();
      for (final availability in availabilities) {
        if (!_availabilityByDay.containsKey(availability.dayOfWeek)) {
          _availabilityByDay[availability.dayOfWeek] = [];
        }
        _availabilityByDay[availability.dayOfWeek]!.add(availability);
      }

      // Sort time slots for each day
      for (final day in _availabilityByDay.keys) {
        _availabilityByDay[day]!.sort((a, b) => a.startTime.compareTo(b.startTime));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load availability: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addOrEditTimeSlot(int dayOfWeek, [DoctorAvailabilityModel? existingSlot]) async {
    final authState = context.read<AuthCubit>().state;
    if (!authState.isAuthenticated || authState.user == null) return;

    TimeOfDay? startTime;
    TimeOfDay? endTime;

    if (existingSlot != null) {
      final startParts = existingSlot.startTime.split(':');
      startTime = TimeOfDay(
        hour: int.parse(startParts[0]),
        minute: int.parse(startParts[1]),
      );

      final endParts = existingSlot.endTime.split(':');
      endTime = TimeOfDay(
        hour: int.parse(endParts[0]),
        minute: int.parse(endParts[1]),
      );
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => TimeSlotDialog(
        dayOfWeek: dayOfWeek,
        initialStartTime: startTime,
        initialEndTime: endTime,
      ),
    );

    if (result != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final doctorRepository = DoctorRepository();

        // Format times as HH:MM
        final formattedStartTime = '${result['startTime'].hour.toString().padLeft(2, '0')}:${result['startTime'].minute.toString().padLeft(2, '0')}';
        final formattedEndTime = '${result['endTime'].hour.toString().padLeft(2, '0')}:${result['endTime'].minute.toString().padLeft(2, '0')}';

        final success = await doctorRepository.setDoctorAvailability(
          doctorId: authState.user!.id,
          dayOfWeek: dayOfWeek,
          startTime: formattedStartTime,
          endTime: formattedEndTime,
        );

        if (success) {
          await _loadAvailability();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(existingSlot != null ? 'Time slot updated successfully' : 'Time slot added successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to save time slot'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving time slot: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _deleteTimeSlot(DoctorAvailabilityModel slot) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Time Slot'),
        content: const Text('Are you sure you want to delete this time slot?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final doctorRepository = DoctorRepository();
      final success = await doctorRepository.deleteDoctorAvailability(slot.id);

      if (success) {
        await _loadAvailability();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Time slot deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete time slot'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting time slot: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Availability'),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          if (!authState.isAuthenticated || authState.user == null) {
            return const Center(
              child: Text('You need to be logged in to manage availability'),
            );
          }

          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadAvailability,
            child: Column(
              children: [
                _buildAvailabilityToggle(authState.user!.id),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _daysOfWeek.length,
                    itemBuilder: (context, index) {
                      // Convert to 0-6 index, Monday as 0 (to match the _daysOfWeek list)
                      // But our database uses 0-6 for Sunday-Saturday
                      final dayIndex = (index + 1) % 7;
                      final dayName = _daysOfWeek[index];
                      final timeSlots = _availabilityByDay[dayIndex] ?? [];

                      return _buildDayCard(dayIndex, dayName, timeSlots);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvailabilityToggle(String doctorId) {
    return BlocBuilder<DoctorCubit, DoctorState>(
      builder: (context, state) {
        final isAvailable = state.selectedDoctor?.isAvailable ?? false;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          color: Colors.grey.shade100,
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Available for new appointments:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Switch(
                value: isAvailable,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (value) {
                  context.read<DoctorCubit>().toggleDoctorAvailability(
                        doctorId: doctorId,
                        isAvailable: value,
                      );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDayCard(int dayIndex, String dayName, List<DoctorAvailabilityModel> timeSlots) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            title: Text(
              dayName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _addOrEditTimeSlot(dayIndex),
            ),
          ),
          if (timeSlots.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No time slots available for this day',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: timeSlots.length,
              itemBuilder: (context, index) {
                final slot = timeSlots[index];
                return ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text('${slot.startTime} - ${slot.endTime}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _addOrEditTimeSlot(dayIndex, slot),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteTimeSlot(slot),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class TimeSlotDialog extends StatefulWidget {
  final int dayOfWeek;
  final TimeOfDay? initialStartTime;
  final TimeOfDay? initialEndTime;

  const TimeSlotDialog({
    super.key,
    required this.dayOfWeek,
    this.initialStartTime,
    this.initialEndTime,
  });

  @override
  State<TimeSlotDialog> createState() => _TimeSlotDialogState();
}

class _TimeSlotDialogState extends State<TimeSlotDialog> {
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    _startTime = widget.initialStartTime ?? const TimeOfDay(hour: 9, minute: 0);
    _endTime = widget.initialEndTime ?? const TimeOfDay(hour: 17, minute: 0);
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );

    if (pickedTime != null && pickedTime != _startTime) {
      setState(() {
        _startTime = pickedTime;

        // Ensure end time is after start time
        if (_compareTimeOfDay(_startTime, _endTime) >= 0) {
          // Add 1 hour to start time for end time
          _endTime = TimeOfDay(
            hour: (_startTime.hour + 1) % 24,
            minute: _startTime.minute,
          );
        }
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );

    if (pickedTime != null && pickedTime != _endTime) {
      if (_compareTimeOfDay(pickedTime, _startTime) > 0) {
        setState(() {
          _endTime = pickedTime;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time must be after start time'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  int _compareTimeOfDay(TimeOfDay time1, TimeOfDay time2) {
    if (time1.hour < time2.hour) return -1;
    if (time1.hour > time2.hour) return 1;
    if (time1.minute < time2.minute) return -1;
    if (time1.minute > time2.minute) return 1;
    return 0;
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.initialStartTime != null ? 'Edit' : 'Add'} Time Slot'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          InkWell(
            onTap: _selectStartTime,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Start Time',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.access_time),
              ),
              child: Text(_formatTime(_startTime)),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _selectEndTime,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'End Time',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.access_time),
              ),
              child: Text(_formatTime(_endTime)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_compareTimeOfDay(_endTime, _startTime) <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('End time must be after start time'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            Navigator.of(context).pop({
              'startTime': _startTime,
              'endTime': _endTime,
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
