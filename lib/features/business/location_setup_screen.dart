import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gymnex_manage/core/utils/app_colors.dart';
import 'package:gymnex_manage/core/utils/app_typography.dart';
import 'package:gymnex_manage/widgets/custom_button.dart';

class LocationSetupScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final double? initialRadius;

  const LocationSetupScreen({
    Key? key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialRadius,
  }) : super(key: key);

  @override
  State<LocationSetupScreen> createState() => _LocationSetupScreenState();
}

class _LocationSetupScreenState extends State<LocationSetupScreen> {
  GoogleMapController? _mapController;
  bool _isLoading = true;

  // Location data
  LatLng _currentPosition = const LatLng(0, 0);
  double _radius = 100.0; // Default radius in meters

  // Map markers and circles
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();

    // If we have initial values, use them
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _currentPosition = LatLng(
        widget.initialLatitude!,
        widget.initialLongitude!,
      );
      if (widget.initialRadius != null) {
        _radius = widget.initialRadius!;
      }
      _updateMapFeatures();
      _isLoading = false;
    } else {
      // Otherwise get current location
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      _updateMapFeatures();

      // Animate camera to the position
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentPosition, zoom: 15.0),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: ${e.toString()}')),
      );
    }
  }

  void _updateMapFeatures() {
    setState(() {
      // Update marker
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('gymLocation'),
          position: _currentPosition,
          draggable: true,
          onDragEnd: (newPosition) {
            setState(() {
              _currentPosition = newPosition;
              _updateMapFeatures();
            });
          },
          infoWindow: const InfoWindow(
            title: 'Gym Location',
            snippet: 'Drag to adjust',
          ),
        ),
      );

      // Update circle (geofence)
      _circles.clear();
      _circles.add(
        Circle(
          circleId: const CircleId('geofence'),
          center: _currentPosition,
          radius: _radius,
          fillColor: AppColors.accentColor.withValues(alpha: 0.2),
          strokeColor: AppColors.accentColor,
          strokeWidth: 2,
        ),
      );
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
      body: Stack(
        children: [
          // Map
          _isLoading
              ? Center(
                child: CircularProgressIndicator(color: AppColors.accentColor),
              )
              : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentPosition,
                  zoom: 15.0,
                ),
                markers: _markers,
                circles: _circles,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                onMapCreated: (controller) {
                  _mapController = controller;

                  // Apply custom dark theme for map
                  _mapController!.setMapStyle('''
                      [
                        {
                          "elementType": "geometry",
                          "stylers": [
                            {
                              "color": "#212121"
                            }
                          ]
                        },
                        {
                          "elementType": "labels.text.fill",
                          "stylers": [
                            {
                              "color": "#757575"
                            }
                          ]
                        },
                        {
                          "elementType": "labels.text.stroke",
                          "stylers": [
                            {
                              "color": "#212121"
                            }
                          ]
                        },
                        {
                          "featureType": "administrative",
                          "elementType": "geometry",
                          "stylers": [
                            {
                              "color": "#757575"
                            }
                          ]
                        },
                        {
                          "featureType": "administrative.country",
                          "elementType": "labels.text.fill",
                          "stylers": [
                            {
                              "color": "#9e9e9e"
                            }
                          ]
                        },
                        {
                          "featureType": "administrative.land_parcel",
                          "stylers": [
                            {
                              "visibility": "off"
                            }
                          ]
                        },
                        {
                          "featureType": "administrative.locality",
                          "elementType": "labels.text.fill",
                          "stylers": [
                            {
                              "color": "#bdbdbd"
                            }
                          ]
                        },
                        {
                          "featureType": "poi",
                          "elementType": "labels.text.fill",
                          "stylers": [
                            {
                              "color": "#757575"
                            }
                          ]
                        },
                        {
                          "featureType": "poi.park",
                          "elementType": "geometry",
                          "stylers": [
                            {
                              "color": "#181818"
                            }
                          ]
                        },
                        {
                          "featureType": "poi.park",
                          "elementType": "labels.text.fill",
                          "stylers": [
                            {
                              "color": "#616161"
                            }
                          ]
                        },
                        {
                          "featureType": "poi.park",
                          "elementType": "labels.text.stroke",
                          "stylers": [
                            {
                              "color": "#1b1b1b"
                            }
                          ]
                        },
                        {
                          "featureType": "road",
                          "elementType": "geometry.fill",
                          "stylers": [
                            {
                              "color": "#2c2c2c"
                            }
                          ]
                        },
                        {
                          "featureType": "road",
                          "elementType": "labels.text.fill",
                          "stylers": [
                            {
                              "color": "#8a8a8a"
                            }
                          ]
                        },
                        {
                          "featureType": "road.arterial",
                          "elementType": "geometry",
                          "stylers": [
                            {
                              "color": "#373737"
                            }
                          ]
                        },
                        {
                          "featureType": "road.highway",
                          "elementType": "geometry",
                          "stylers": [
                            {
                              "color": "#3c3c3c"
                            }
                          ]
                        },
                        {
                          "featureType": "road.highway.controlled_access",
                          "elementType": "geometry",
                          "stylers": [
                            {
                              "color": "#4e4e4e"
                            }
                          ]
                        },
                        {
                          "featureType": "road.local",
                          "elementType": "labels.text.fill",
                          "stylers": [
                            {
                              "color": "#616161"
                            }
                          ]
                        },
                        {
                          "featureType": "transit",
                          "elementType": "labels.text.fill",
                          "stylers": [
                            {
                              "color": "#757575"
                            }
                          ]
                        },
                        {
                          "featureType": "water",
                          "elementType": "geometry",
                          "stylers": [
                            {
                              "color": "#000000"
                            }
                          ]
                        },
                        {
                          "featureType": "water",
                          "elementType": "labels.text.fill",
                          "stylers": [
                            {
                              "color": "#3d3d3d"
                            }
                          ]
                        }
                      ]
                    ''');
                },
                onTap: (latLng) {
                  setState(() {
                    _currentPosition = latLng;
                    _updateMapFeatures();
                  });
                },
              ),

          // Location and radius controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Set Check-in Radius', style: AppTypography.h3),
                  const SizedBox(height: 8),
                  Text(
                    'Drag the marker to position your gym. Adjust the radius to define the area where members can check in.',
                    style: AppTypography.bodyMedium,
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
                              _updateMapFeatures();
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
                  const SizedBox(height: 16),

                  // Location coordinates display
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Latitude',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.mutedText,
                              ),
                            ),
                            Text(
                              _currentPosition.latitude.toStringAsFixed(6),
                              style: AppTypography.bodyMedium,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Longitude',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.mutedText,
                              ),
                            ),
                            Text(
                              _currentPosition.longitude.toStringAsFixed(6),
                              style: AppTypography.bodyMedium,
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.my_location,
                            color: AppColors.accentColor,
                          ),
                          onPressed: _getCurrentLocation,
                          tooltip: 'Get Current Location',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Save button
                  CustomButton(
                    text: 'SAVE LOCATION',
                    onPressed: () {
                      // Return location data to previous screen
                      Navigator.pop(context, {
                        'latitude': _currentPosition.latitude,
                        'longitude': _currentPosition.longitude,
                        'radius': _radius,
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
