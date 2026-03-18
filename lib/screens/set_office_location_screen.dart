import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/geofence.dart';
import '../services/geofence_service.dart';
import '../widgets/custom_button.dart';

class SetOfficeLocationScreen extends StatefulWidget {
  const SetOfficeLocationScreen({super.key});

  @override
  State<SetOfficeLocationScreen> createState() =>
      _SetOfficeLocationScreenState();
}

class _SetOfficeLocationScreenState extends State<SetOfficeLocationScreen> {
  Geofence? _currentGeofence;

  LatLng? _selectedLatLng;
  double? _radiusMeters;

  bool _loadingGeofence = true;
  bool _saving = false;

  final _radiusController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  static const LatLng _defaultCenter = LatLng(21.0077, 75.5626);

  @override
  void initState() {
    super.initState();
    _loadGeofence();
  }

  Future<void> _loadGeofence() async {
    final geofence = await GeofenceService.getGeofence();
    setState(() {
      _currentGeofence = geofence;
      _loadingGeofence = false;
    });

    if (geofence != null) {
      _selectedLatLng = LatLng(geofence.latitude, geofence.longitude);
      _radiusMeters = geofence.radius;
      _radiusController.text = geofence.radius.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _radiusController.dispose();
    super.dispose();
  }

  LatLng get _initialCenter {
    if (_currentGeofence != null) {
      return LatLng(_currentGeofence!.latitude, _currentGeofence!.longitude);
    }
    return _defaultCenter;
  }

  void _onMapTap(TapPosition tapPosition, LatLng latLng) {
    setState(() {
      _selectedLatLng = latLng;
    });
  }

  Future<void> _saveGeofence() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLatLng == null) {
      _showSnackBar('Please tap on the map to select office location.');
      return;
    }

    final radius = double.tryParse(_radiusController.text.trim());
    if (radius == null || radius <= 0) {
      _showSnackBar('Please enter a valid radius (in meters).');
      return;
    }

    setState(() {
      _saving = true;
      _radiusMeters = radius;
    });

    final success = await GeofenceService.setGeofence(
      latitude: _selectedLatLng!.latitude,
      longitude: _selectedLatLng!.longitude,
      radius: radius,
    );

    setState(() {
      _saving = false;
    });

    if (success) {
      _showSnackBar('Office location updated successfully.');
      setState(() {
        _currentGeofence = Geofence(
          latitude: _selectedLatLng!.latitude,
          longitude: _selectedLatLng!.longitude,
          radius: radius,
        );
      });
    } else {
      _showSnackBar('Failed to update office location. Please try again.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('Set Office Location'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
      ),
      body: _loadingGeofence
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Office Geofence',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentGeofence == null
                            ? 'Not configured yet.'
                            : 'Lat: ${_currentGeofence!.latitude.toStringAsFixed(4)}, '
                                'Lon: ${_currentGeofence!.longitude.toStringAsFixed(4)}, '
                                'Radius: ${_currentGeofence!.radius.toStringAsFixed(0)} m',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: _initialCenter,
                          initialZoom: _currentGeofence != null ? 16 : 5,
                          onTap: _onMapTap,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: const ['a', 'b', 'c'],
                            userAgentPackageName: 'com.example.geotracker_flutter',
                          ),
                          if (_selectedLatLng != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _selectedLatLng!,
                                  width: 40,
                                  height: 40,
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 32,
                                  ),
                                ),
                              ],
                            ),
                          if (_selectedLatLng != null && _radiusMeters != null)
                            CircleLayer(
                              circles: [
                                CircleMarker(
                                  point: _selectedLatLng!,
                                  radius: _radiusMeters!,
                                  useRadiusInMeter: true,
                                  color:
                                      Colors.blueAccent.withValues(alpha: 0.15),
                                  borderColor: Colors.blueAccent,
                                  borderStrokeWidth: 2,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Form(
                    key: _formKey,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _radiusController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Radius (meters)',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter radius';
                              }
                              final parsed =
                                  double.tryParse(value.trim());
                              if (parsed == null || parsed <= 0) {
                                return 'Invalid radius';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 140,
                          child: _saving
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : CustomButton(
                                  text: 'Save',
                                  onPressed: _saveGeofence,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
    );
  }
}

