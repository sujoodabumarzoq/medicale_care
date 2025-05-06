import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapDisplay extends StatefulWidget {
  final double latitude;
  final double longitude;

  const MapDisplay({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<MapDisplay> createState() => _MapDisplayState();
}

class _MapDisplayState extends State<MapDisplay> {
  late GoogleMapController _mapController;
  late LatLng _center;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _center = LatLng(widget.latitude, widget.longitude);
    _markers = {
      Marker(
        markerId: const MarkerId('selected_location'),
        position: _center,
        infoWindow: const InfoWindow(title: 'Selected Location'),
      ),
    };
  }

  @override
  void didUpdateWidget(MapDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude || oldWidget.longitude != widget.longitude) {
      _updateLocation();
    }
  }

  void _updateLocation() {
    setState(() {
      _center = LatLng(widget.latitude, widget.longitude);
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: _center,
          infoWindow: const InfoWindow(title: 'Selected Location'),
        ),
      };
    });

    _mapController.animateCamera(
      CameraUpdate.newLatLng(_center),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: SizedBox(
        height: 300,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 14.0,
          ),
          markers: _markers,
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
        ),
      ),
    );
  }
}
