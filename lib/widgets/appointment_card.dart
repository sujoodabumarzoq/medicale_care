import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/appointment_model.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback onTap;
  final bool showCancelButton;
  final VoidCallback? onCancel;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onTap,
    this.showCancelButton = false,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatar(context),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildDoctorInfo(context),
                            _buildStatusBadge(context),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildAppointmentDateTimeInfo(context),
                      ],
                    ),
                  ),
                ],
              ),
              if (showCancelButton && onCancel != null) ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('Cancel Appointment'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    // Determine if we're showing doctor or patient info
    final isPatientView = appointment.doctorName != null;
    final name = isPatientView ? appointment.doctorName! : appointment.patientName!;
    final imageUrl = isPatientView ? appointment.doctorImageUrl : appointment.patientImageUrl;

    return CircleAvatar(
      radius: 25,
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
      child: imageUrl == null
          ? Text(
              name.substring(0, 1),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            )
          : null,
    );
  }

  Widget _buildDoctorInfo(BuildContext context) {
    // Determine if we're showing doctor or patient info
    final isPatientView = appointment.doctorName != null;
    final name = isPatientView ? 'Dr. ${appointment.doctorName!}' : appointment.patientName!;
    final specialty = isPatientView ? appointment.doctorSpecialty : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (specialty != null)
          Text(
            specialty,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
      ],
    );
  }

  Widget _buildAppointmentDateTimeInfo(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMMM d, y');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
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
          ],
        ),
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
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color color;
    String text;

    switch (appointment.status) {
      case 'pending':
        color = Colors.orange;
        text = 'Pending';
        break;
      case 'confirmed':
        color = Colors.green;
        text = 'Confirmed';
        break;
      case 'cancelled':
        color = Colors.red;
        text = 'Cancelled';
        break;
      case 'completed':
        color = Colors.blue;
        text = 'Completed';
        break;
      default:
        color = Colors.grey;
        text = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
