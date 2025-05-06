import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicale_care/cubits/emergency/emergency_state.dart';
import 'package:medicale_care/models/emergency_contact_modal.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../cubits/emergency/emergency_cubit.dart';

class EmergencyContactScreen extends StatefulWidget {
  const EmergencyContactScreen({super.key});

  @override
  State<EmergencyContactScreen> createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    context.read<EmergencyCubit>().loadAllEmergencyContacts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  static void launchCall(String? url, BuildContext context) {
    if (url.validate().isNotEmpty) {
      if (isIOS) {
        commonLaunchUrl('tel://${url!}', context, launchMode: LaunchMode.externalApplication);
      } else {
        commonLaunchUrl('tel:${url!}', context, launchMode: LaunchMode.externalApplication);
      }
    }
  }

  static Future<void> commonLaunchUrl(String address, BuildContext context, {LaunchMode launchMode = LaunchMode.inAppWebView}) async {
    try {
      final uri = Uri.parse(address);

      final launched = await launchUrl(uri, mode: launchMode);

      if (!launched) {
        if (context.mounted) {
          Fluttertoast.showToast(
            msg: 'Could not launch $address',
            toastLength: Toast.LENGTH_SHORT,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Fluttertoast.showToast(
          msg: 'Could not launch $address',
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    }
  }

  Future<void> _callNumber(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch phone call'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Services'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Hospitals'),
            Tab(text: 'Ambulance'),
            Tab(text: 'Fire'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEmergencyList(type: null),
          _buildEmergencyList(type: 'hospital'),
          _buildEmergencyList(type: 'ambulance'),
          _buildEmergencyList(type: 'fire'),
        ],
      ),
    );
  }

  Widget _buildEmergencyList({String? type, String? otherType}) {
    return BlocBuilder<EmergencyCubit, EmergencyState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.hasError) {
          return Center(
            child: Text(
              state.errorMessage ?? 'Failed to load emergency contacts',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        List<EmergencyContactModel> contacts = state.contacts;

        if (type != null) {
          contacts = contacts.where((contact) => contact.type == type).toList();

          if (otherType != null) {
            contacts = [
              ...contacts,
              ...state.contacts.where((contact) => contact.type.toString().trim() == otherType.toString().trim()),
            ];
          }
        }

        if (contacts.isEmpty) {
          return const Center(
            child: Text('No emergency contacts found'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final contact = contacts[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getColorForType(contact.type),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconForType(contact.type),
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  contact.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(contact.address),
                    const SizedBox(height: 4),
                    Text(
                      contact.is24Hours ? 'Open 24 Hours' : 'Limited Hours',
                      style: TextStyle(
                        color: contact.is24Hours ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.call),
                  color: Colors.green,
                  onPressed: () {
                    launchCall(contact.phoneNumber, context);
                  },
                ),
                onTap: () {
                  launchCall(contact.phoneNumber, context);
                },
              ),
            );
          },
        );
      },
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'hospital':
        return Icons.local_hospital;
      case 'ambulance':
        return Icons.emergency;
      case 'fire':
        return Icons.local_fire_department;

      default:
        return Icons.emergency;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'hospital':
        return Colors.red;
      case 'ambulance':
        return Colors.orange;
      case 'fire':
        return Colors.deepOrange;

      default:
        return Colors.purple;
    }
  }
}
