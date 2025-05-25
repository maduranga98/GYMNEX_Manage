import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gymnex_manage/core/utils/app_colors.dart';
import 'package:gymnex_manage/core/utils/app_typography.dart';
import 'package:gymnex_manage/widgets/custom_button.dart';
import 'package:gymnex_manage/widgets/custom_text_field.dart';

class SimpleLocationSetupScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final double? initialRadius;

  const SimpleLocationSetupScreen({
    Key? key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialRadius,
  }) : super(key: key);

  @override
  State<SimpleLocationSetupScreen> createState() =>
      _SimpleLocationSetupScreenState();
}

class _SimpleLocationSetupScreenState extends State<SimpleLocationSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  // Location data
  double _radius = 100.0; // Default radius in meters
  bool _isLoading = false;
  String _errorMessage = '';
  bool _hasLocationPermission = false;

  @override
  void initState() {
    super.initState();

    // If we have initial values, use them
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _latitudeController.text = widget.initialLatitude!.toString();
      _longitudeController.text = widget.initialLongitude!.toString();
      if (widget.initialRadius != null) {
        _radius = widget.initialRadius!;
      }
    }

    // Check location permissions
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      setState(() {
        _hasLocationPermission =
            permission != LocationPermission.denied &&
            permission != LocationPermission.deniedForever;
      });
    } catch (e) {
      setState(() {
        _hasLocationPermission = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    // If we don't have permission, request it
    if (!_hasLocationPermission) {
      await _checkLocationPermission();
      if (!_hasLocationPermission) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Location permission required')));
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitudeController.text = position.latitude.toString();
        _longitudeController.text = position.longitude.toString();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error getting location: ${e.toString()}';
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_errorMessage)));
    }
  }

  void _saveLocation() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Parse values
    double? latitude = double.tryParse(_latitudeController.text);
    double? longitude = double.tryParse(_longitudeController.text);

    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter valid coordinates')));
      return;
    }

    // Return location data to previous screen
    Navigator.pop(context, {
      'latitude': latitude,
      'longitude': longitude,
      'radius': _radius,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text('Gym Location Setup', style: AppTypography.h3),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text('Set Check-in Location', style: AppTypography.h2),
              const SizedBox(height: 8),
              Text(
                'Define your gym location and the radius within which members can check in.',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 30),

              // Current location card
              Card(
                color: AppColors.cardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.my_location, color: AppColors.accentColor),
                          const SizedBox(width: 8),
                          Text(
                            'Current Location',
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          CustomButton(
                            text: 'GET LOCATION',
                            icon: Icons.gps_fixed,
                            height: 40,
                            isLoading: _isLoading,
                            onPressed: _getCurrentLocation,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Location input fields
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Latitude',
                                  style: AppTypography.bodySmall.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                CustomTextField(
                                  controller: _latitudeController,
                                  hintText: 'Enter latitude',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                        signed: true,
                                      ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    final latitude = double.tryParse(value);
                                    if (latitude == null) {
                                      return 'Invalid format';
                                    }
                                    if (latitude < -90 || latitude > 90) {
                                      return 'Invalid range';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Longitude',
                                  style: AppTypography.bodySmall.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                CustomTextField(
                                  controller: _longitudeController,
                                  hintText: 'Enter longitude',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                        signed: true,
                                      ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    final longitude = double.tryParse(value);
                                    if (longitude == null) {
                                      return 'Invalid format';
                                    }
                                    if (longitude < -180 || longitude > 180) {
                                      return 'Invalid range';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Radius card
              Card(
                color: AppColors.cardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.adjust, color: AppColors.accentColor),
                          const SizedBox(width: 8),
                          Text(
                            'Check-in Radius',
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Set the radius within which members can check in to your gym.',
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(height: 16),

                      // Radius slider
                      Row(
                        children: [
                          Icon(
                            Icons.circle_outlined,
                            color: AppColors.mutedText,
                            size: 20,
                          ),
                          Expanded(
                            child: Slider(
                              value: _radius,
                              min: 50,
                              max: 500,
                              divisions: 9,
                              activeColor: AppColors.accentColor,
                              inactiveColor: AppColors.inputBackground,
                              label: '${_radius.toInt()} m',
                              onChanged: (value) {
                                setState(() {
                                  _radius = value;
                                });
                              },
                            ),
                          ),
                          Icon(
                            Icons.circle_outlined,
                            color: AppColors.mutedText,
                            size: 28,
                          ),
                        ],
                      ),

                      // Radius value
                      Center(
                        child: Text(
                          'Radius: ${_radius.toInt()} meters',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.accentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Info text
              if (_errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 30),

              // Save button
              CustomButton(text: 'SAVE LOCATION', onPressed: _saveLocation),
            ],
          ),
        ),
      ),
    );
  }
}
