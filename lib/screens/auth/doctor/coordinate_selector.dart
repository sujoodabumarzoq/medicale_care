import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CoordinateSelector extends StatefulWidget {
  final Function(double, double) onCoordinatesSelected;
  final double initialLatitude;
  final double initialLongitude;

  const CoordinateSelector({
    super.key,
    required this.onCoordinatesSelected,
    this.initialLatitude = 31.354675,
    this.initialLongitude = 34.308826,
  });

  @override
  State<CoordinateSelector> createState() => _CoordinateSelectorState();
}

class _CoordinateSelectorState extends State<CoordinateSelector> {
  late GoogleMapController _mapController;
  late LatLng _selectedPosition;
  late Set<Marker> _markers;

  @override
  void initState() {
    super.initState();
    _selectedPosition = LatLng(widget.initialLatitude, widget.initialLongitude);
    _markers = {
      Marker(
        markerId: const MarkerId('selected_position'),
        position: _selectedPosition,
        draggable: true,
        onDragEnd: (newPosition) {
          setState(() {
            _selectedPosition = newPosition;
          });
        },
      ),
    };
  }

  void _showMapSelector() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Location'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 400,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selectedPosition,
                zoom: 14.0,
              ),
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              onTap: (LatLng position) {
                setState(() {
                  _selectedPosition = position;
                  _markers = {
                    Marker(
                      markerId: const MarkerId('selected_position'),
                      position: position,
                      draggable: true,
                      onDragEnd: (newPosition) {
                        setState(() {
                          _selectedPosition = newPosition;
                        });
                      },
                    ),
                  };
                });
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                widget.onCoordinatesSelected(_selectedPosition.latitude, _selectedPosition.longitude);
                Navigator.pop(context);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _showMapSelector,
      child: const Text('Select Location on Map'),
    );
  }
}

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
    return SizedBox(
      height: 600,
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
    );
  }
}

// Example usage in a page:
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  double _latitude = 37.7749;
  double _longitude = -122.4194;

  void _updateCoordinates(double lat, double lng) {
    setState(() {
      _latitude = lat;
      _longitude = lng;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CoordinateSelector(
                  onCoordinatesSelected: _updateCoordinates,
                  initialLatitude: _latitude,
                  initialLongitude: _longitude,
                ),
                Text(
                  'Lat: ${_latitude.toStringAsFixed(6)}\nLng: ${_longitude.toStringAsFixed(6)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),
            MapDisplay(
              latitude: _latitude,
              longitude: _longitude,
            ),
          ],
        ),
      ),
    );
  }
}
