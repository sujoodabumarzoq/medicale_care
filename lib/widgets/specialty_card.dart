import 'package:flutter/material.dart';

import '../models/specialty_model.dart';

class SpecialtyCard extends StatelessWidget {
  final SpecialtyModel specialty;
  final VoidCallback onTap;

  const SpecialtyCard({
    super.key,
    required this.specialty,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconData(specialty.icon ?? specialty.name),
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              specialty.name,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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
