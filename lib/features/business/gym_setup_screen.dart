import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gymnex_manage/core/utils/app_colors.dart';
import 'package:gymnex_manage/core/utils/app_typography.dart';
import 'package:gymnex_manage/core/utils/qr_generator.dart';
import 'package:gymnex_manage/features/business/simple_location_setup.dart';
import 'package:gymnex_manage/widgets/custom_button.dart';
import 'package:gymnex_manage/widgets/custom_text_field.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class GymSetupScreen extends StatefulWidget {
  const GymSetupScreen({super.key});

  @override
  State<GymSetupScreen> createState() => _GymSetupScreenState();
}

class _GymSetupScreenState extends State<GymSetupScreen> {
  final formKey = GlobalKey<FormState>();
  double? latitude;
  double? longitude;
  double? geofenceRadius;
  final GlobalKey qrKey = GlobalKey();
  // Text controllers
  final gymNameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final taxRateController = TextEditingController();

  // State variables
  String logoImagePath = '';
  List<bool> businessDays = List.generate(7, (index) => true);
  String openingTime = '06:00 AM';
  String closingTime = '10:00 PM';
  List<Map<String, dynamic>> membershipPlans = [];
  String selectedCurrency = 'USD';
  bool isSaving = false;
  String? businessId;

  // Currency list
  final List<String> currencies = [
    'USD',
    'EUR',
    'GBP',
    'CAD',
    'AUD',
    'INR',
    'JPY',
    'CNY',
  ];

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  void _openLocationSetup() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SimpleLocationSetupScreen(
              initialLatitude: latitude,
              initialLongitude: longitude,
              initialRadius: geofenceRadius,
            ),
      ),
    );

    if (result != null) {
      setState(() {
        latitude = result['latitude'];
        longitude = result['longitude'];
        geofenceRadius = result['radius'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Get the business ID from arguments
    if (Get.arguments != null && Get.arguments['businessId'] != null) {
      businessId = Get.arguments['businessId'];
    }
    loadGymData();
  }

  @override
  void dispose() {
    gymNameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    emailController.dispose();
    taxRateController.dispose();
    super.dispose();
  }

  Future<void> loadGymData() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Use the businessId if provided, otherwise use userId
      final docId = businessId ?? userId;

      final gymDoc = await _firestore.collection('gyms').doc(docId).get();

      if (gymDoc.exists) {
        final data = gymDoc.data();

        if (data != null && mounted) {
          setState(() {
            gymNameController.text = data['name'] ?? '';
            addressController.text = data['address'] ?? '';
            phoneController.text = data['phone'] ?? '';
            emailController.text = data['email'] ?? '';
            logoImagePath = data['logoUrl'] ?? '';

            // Load location data
            latitude = data['latitude'];
            longitude = data['longitude'];
            geofenceRadius = data['geofenceRadius']?.toDouble();

            if (data['businessDays'] != null) {
              final List<dynamic> days = data['businessDays'];
              for (int i = 0; i < days.length && i < businessDays.length; i++) {
                businessDays[i] = days[i];
              }
            }

            openingTime = data['openingTime'] ?? '06:00 AM';
            closingTime = data['closingTime'] ?? '10:00 PM';

            if (data['membershipPlans'] != null) {
              membershipPlans = List<Map<String, dynamic>>.from(
                data['membershipPlans'],
              );
            }

            selectedCurrency = data['currency'] ?? 'USD';
            taxRateController.text = data['taxRate']?.toString() ?? '0';
          });
        }
      }
    } catch (e) {
      print('Error loading gym data: $e');
    }
  }

  Future<void> pickLogoImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final File imageFile = File(image.path);

      // Upload to Firebase Storage
      try {
        setState(() {
          isSaving = true;
        });

        final userId = _auth.currentUser?.uid;
        if (userId == null) return;

        final Reference ref = _storage
            .ref()
            .child('gym_logos')
            .child('$userId.jpg');
        final UploadTask uploadTask = ref.putFile(imageFile);

        final TaskSnapshot snapshot = await uploadTask;
        final String downloadUrl = await snapshot.ref.getDownloadURL();

        setState(() {
          logoImagePath = downloadUrl;
          isSaving = false;
        });
      } catch (e) {
        setState(() {
          isSaving = false;
        });
        print('Error uploading logo: $e');
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload logo image. Please try again.'),
          ),
        );
      }
    }
  }

  void toggleDay(int index) {
    if (index >= 0 && index < businessDays.length) {
      setState(() {
        businessDays[index] = !businessDays[index];
      });
    }
  }

  Future<void> selectOpeningTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _parseTimeString(openingTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.accentColor,
              onPrimary: Colors.white,
              surface: AppColors.cardBackground,
              onSurface: AppColors.primaryText,
            ),
            dialogBackgroundColor: AppColors.background,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        openingTime = _formatTimeOfDay(picked);
      });
    }
  }

  Future<void> selectClosingTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _parseTimeString(closingTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.accentColor,
              onPrimary: Colors.white,
              surface: AppColors.cardBackground,
              onSurface: AppColors.primaryText,
            ),
            dialogBackgroundColor: AppColors.background,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        closingTime = _formatTimeOfDay(picked);
      });
    }
  }

  TimeOfDay _parseTimeString(String timeStr) {
    // Parse a time string like "06:00 AM" to TimeOfDay
    final parts = timeStr.split(' ');
    final timeParts = parts[0].split(':');
    int hour = int.parse(timeParts[0]);
    final int minute = int.parse(timeParts[1]);

    if (parts[1] == 'PM' && hour < 12) {
      hour += 12;
    } else if (parts[1] == 'AM' && hour == 12) {
      hour = 0;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    // Convert TimeOfDay to string format "06:00 AM"
    final hour = timeOfDay.hourOfPeriod == 0 ? 12 : timeOfDay.hourOfPeriod;
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }

  void showAddPlanDialog(
    BuildContext context, [
    Map<String, dynamic>? planToEdit,
  ]) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController durationController = TextEditingController();

    String durationType = 'Months';
    final List<String> durationTypes = ['Days', 'Weeks', 'Months', 'Years'];

    // If editing an existing plan, pre-fill the values
    if (planToEdit != null) {
      nameController.text = planToEdit['name'] ?? '';
      priceController.text = planToEdit['price']?.toString() ?? '';
      durationController.text = planToEdit['duration']?.toString() ?? '';
      durationType = planToEdit['durationType'] ?? 'Months';
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.cardBackground,
              title: Text(
                planToEdit != null
                    ? 'Edit Membership Plan'
                    : 'Add Membership Plan',
                style: AppTypography.h3,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Plan Name
                    CustomTextField(
                      controller: nameController,
                      hintText: 'Plan Name (e.g. Basic, Premium)',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a plan name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Plan Price
                    CustomTextField(
                      controller: priceController,
                      hintText: 'Price',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Plan Duration
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: CustomTextField(
                            controller: durationController,
                            hintText: 'Duration',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.inputBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.inputBorder,
                                width: 1,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: durationType,
                                style: AppTypography.bodyMedium,
                                dropdownColor: AppColors.cardBackground,
                                items:
                                    durationTypes
                                        .map(
                                          (type) => DropdownMenuItem<String>(
                                            value: type,
                                            child: Text(type),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setDialogState(() {
                                      durationType = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: AppTypography.button.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isEmpty ||
                        priceController.text.isEmpty ||
                        durationController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                      return;
                    }

                    final double? price = double.tryParse(priceController.text);
                    final int? duration = int.tryParse(durationController.text);

                    if (price == null || duration == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Invalid price or duration value'),
                        ),
                      );
                      return;
                    }

                    final plan = {
                      'name': nameController.text,
                      'price': price,
                      'duration': duration,
                      'durationType': durationType,
                    };

                    setState(() {
                      if (planToEdit != null) {
                        // Edit existing plan
                        final index = membershipPlans.indexWhere(
                          (element) => element['name'] == planToEdit['name'],
                        );

                        if (index != -1) {
                          membershipPlans[index] = plan;
                        }
                      } else {
                        // Add new plan
                        membershipPlans.add(plan);
                      }
                    });

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void editPlan(Map<String, dynamic> plan) {
    showAddPlanDialog(context, plan);
  }

  void deletePlan(Map<String, dynamic> plan) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: Text('Delete Plan', style: AppTypography.h3),
            content: Text(
              'Are you sure you want to delete "${plan['name']}" plan?',
              style: AppTypography.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: AppTypography.button.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    membershipPlans.removeWhere(
                      (element) => element['name'] == plan['name'],
                    );
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text('Delete'),
              ),
            ],
          ),
    );
  }

  Future<void> saveGymData() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isSaving = true;
    });

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Use the businessId if provided, otherwise use userId
      final docId = businessId ?? userId;

      final gymData = {
        'name': gymNameController.text,
        'address': addressController.text,
        'phone': phoneController.text,
        'email': emailController.text,
        'logoUrl': logoImagePath,
        'businessDays': businessDays,
        'openingTime': openingTime,
        'closingTime': closingTime,
        'membershipPlans': membershipPlans,
        'currency': selectedCurrency,
        'taxRate': double.tryParse(taxRateController.text) ?? 0,
        'updatedAt': FieldValue.serverTimestamp(),
        // Add location data
        'latitude': latitude,
        'longitude': longitude,
        'geofenceRadius': geofenceRadius,
      };

      await _firestore
          .collection('gyms')
          .doc(docId)
          .set(gymData, SetOptions(merge: true));

      // If this is a new business, add it to the user's businesses
      if (businessId != null && businessId != userId) {
        // Check if this business is already in the user's list
        final userDoc = await _firestore.collection('users').doc(userId).get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          if (userData != null) {
            List<dynamic> businesses = userData['businesses'] ?? [];

            if (!businesses.contains(businessId)) {
              businesses.add(businessId);
              await _firestore.collection('users').doc(userId).update({
                'businesses': businesses,
              });
            }
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gym settings saved successfully')),
        );

        // Return to home screen after saving
        Get.back();
      }
    } catch (e) {
      print('Error saving gym data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving gym data: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text("Gym Setup", style: AppTypography.h3),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Business Information Section
                  _buildSectionHeader("Business Information"),
                  const SizedBox(height: 16),

                  // Gym Logo
                  Center(
                    child: GestureDetector(
                      onTap: () => pickLogoImage(),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.divider,
                            width: 2,
                          ),
                          image:
                              logoImagePath.isNotEmpty
                                  ? DecorationImage(
                                    image: NetworkImage(logoImagePath),
                                    fit: BoxFit.cover,
                                  )
                                  : null,
                        ),
                        child:
                            logoImagePath.isEmpty
                                ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo_outlined,
                                      size: 40,
                                      color: AppColors.mutedText,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Add Logo",
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.mutedText,
                                      ),
                                    ),
                                  ],
                                )
                                : null,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Gym Name
                  CustomTextField(
                    controller: gymNameController,
                    hintText: 'Gym Name',
                    prefixIcon: Icon(
                      Icons.fitness_center_outlined,
                      color: AppColors.mutedText,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your gym name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Gym Address
                  CustomTextField(
                    controller: addressController,
                    hintText: 'Address',
                    prefixIcon: Icon(
                      Icons.location_on_outlined,
                      color: AppColors.mutedText,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your gym address';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Contact Information
                  CustomTextField(
                    controller: phoneController,
                    hintText: 'Phone Number',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      color: AppColors.mutedText,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your gym phone number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: emailController,
                    hintText: 'Email Address',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: AppColors.mutedText,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your gym email';
                      }
                      if (!GetUtils.isEmail(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  // Business Hours
                  _buildSectionHeader("Business Hours"),
                  const SizedBox(height: 16),

                  // Business Days
                  Row(
                    children: [
                      Expanded(child: _buildDayToggle("Mon", 0)),
                      Expanded(child: _buildDayToggle("Tue", 1)),
                      Expanded(child: _buildDayToggle("Wed", 2)),
                      Expanded(child: _buildDayToggle("Thu", 3)),
                      Expanded(child: _buildDayToggle("Fri", 4)),
                      Expanded(child: _buildDayToggle("Sat", 5)),
                      Expanded(child: _buildDayToggle("Sun", 6)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Opening Hours
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Opening Time",
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => selectOpeningTime(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.inputBackground,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.inputBorder,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 20,
                                      color: AppColors.mutedText,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      openingTime,
                                      style: AppTypography.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Closing Time",
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => selectClosingTime(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.inputBackground,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.inputBorder,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 20,
                                      color: AppColors.mutedText,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      closingTime,
                                      style: AppTypography.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Membership Plans
                  _buildSectionHeader("Membership Plans"),
                  const SizedBox(height: 16),

                  // Existing Plans
                  membershipPlans.isEmpty
                      ? _buildEmptyState(
                        icon: Icons.card_membership_outlined,
                        text: "No membership plans added",
                      )
                      : Column(
                        children:
                            membershipPlans
                                .map((plan) => _buildMembershipPlanTile(plan))
                                .toList(),
                      ),

                  const SizedBox(height: 16),

                  // Add Plan Button
                  CustomButton(
                    text: "ADD MEMBERSHIP PLAN",
                    isOutlined: true,
                    icon: Icons.add,
                    onPressed: () => showAddPlanDialog(context),
                  ),

                  const SizedBox(height: 32),
                  // Location and Check-in Section
                  _buildLocationSection(),
                  // Additional Settings
                  _buildSectionHeader("Additional Settings"),
                  const SizedBox(height: 16),

                  // Currency
                  Row(
                    children: [
                      Text("Currency", style: AppTypography.bodyMedium),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.inputBorder,
                            width: 1,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCurrency,
                            style: AppTypography.bodyMedium,
                            dropdownColor: AppColors.cardBackground,
                            items:
                                currencies
                                    .map(
                                      (currency) => DropdownMenuItem<String>(
                                        value: currency,
                                        child: Text(currency),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedCurrency = value;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Tax Rate
                  Row(
                    children: [
                      Text("Tax Rate (%)", style: AppTypography.bodyMedium),
                      const Spacer(),
                      SizedBox(
                        width: 100,
                        child: CustomTextField(
                          controller: taxRateController,
                          keyboardType: TextInputType.number,
                          hintText: '0.0',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Save Button
                  CustomButton(
                    text: "SAVE CHANGES",
                    isLoading: isSaving,
                    onPressed: isSaving ? null : saveGymData,
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location & Check-in', style: AppTypography.h3),
            SizedBox(height: 16),

            // Location status
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: Row(
                children: [
                  Icon(
                    latitude != null && longitude != null
                        ? Icons.check_circle
                        : Icons.location_off,
                    color:
                        latitude != null && longitude != null
                            ? Colors.green
                            : AppColors.mutedText,
                    size: 36,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          latitude != null && longitude != null
                              ? 'Location Set'
                              : 'Location Not Set',
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color:
                                latitude != null && longitude != null
                                    ? Colors.green
                                    : AppColors.mutedText,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          latitude != null && longitude != null
                              ? 'Geofence radius: ${geofenceRadius?.toInt() ?? 100} meters'
                              : 'Set your gym location to enable check-ins',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: Icon(
                      latitude != null && longitude != null
                          ? Icons.edit_location_alt
                          : Icons.add_location_alt,
                      size: 20,
                    ),
                    label: Text(
                      latitude != null && longitude != null ? 'EDIT' : 'SET',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onPressed: _openLocationSetup,
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // QR Code section
            Text(
              'Gym QR Code',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Generate a QR code for your gym to let members register easily.',
              style: AppTypography.bodySmall,
            ),
            SizedBox(height: 12),

            CustomButton(
              text: 'GENERATE QR CODE',
              icon: Icons.qr_code,
              isOutlined: true,
              onPressed: businessId != null ? _generateAndShareQRCode : null,
            ),

            if (businessId == null)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Save gym details first to generate QR code',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.mutedText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.h3),
        const SizedBox(height: 4),
        Divider(color: AppColors.divider, thickness: 1),
      ],
    );
  }

  // Update the _generateAndShareQRCode method in your gym_setup_screen.dart file

  void _generateAndShareQRCode() {
    if (businessId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please save the gym details first')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder:
                (context, controller) => Column(
                  children: [
                    // Title bar
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.divider),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text('GYM QR CODE', style: AppTypography.h3),
                          Spacer(),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: AppColors.primaryText,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),

                    // QR code content
                    Expanded(
                      child: SingleChildScrollView(
                        controller: controller,
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              'Use this QR code to let members join your gym',
                              style: AppTypography.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),

                            // QR Code
                            RepaintBoundary(
                              key: qrKey,
                              child: QRGenerator.generateGymQRCard(
                                gymId: businessId!,
                                gymName: gymNameController.text,
                                gymAddress: addressController.text,
                                gymLogo: logoImagePath,
                              ),
                            ),

                            SizedBox(height: 30),

                            // Share button
                            ElevatedButton.icon(
                              icon: Icon(Icons.share),
                              label: Text('SHARE QR CODE'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentColor,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 12,
                                ),
                              ),
                              onPressed: () async {
                                await QRGenerator.shareQRCode(
                                  qrKey,
                                  gymNameController.text.isNotEmpty
                                      ? gymNameController.text.replaceAll(
                                        ' ',
                                        '_',
                                      )
                                      : 'gymnex_gym',
                                );
                              },
                            ),

                            SizedBox(height: 20),
                            Text(
                              'ID: $businessId',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.mutedText,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  Widget _buildDayToggle(String day, int index) {
    return GestureDetector(
      onTap: () => toggleDay(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color:
              businessDays[index]
                  ? AppColors.accentColor.withValues(alpha: 0.15)
                  : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                businessDays[index] ? AppColors.accentColor : AppColors.divider,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            day,
            style: AppTypography.bodySmall.copyWith(
              color:
                  businessDays[index]
                      ? AppColors.accentColor
                      : AppColors.mutedText,
              fontWeight:
                  businessDays[index] ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMembershipPlanTile(Map<String, dynamic> plan) {
    return Card(
      color: AppColors.cardBackground,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan['name'],
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${plan['duration']} ${plan['durationType']}",
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
            Text(
              "$selectedCurrency ${plan['price']}",
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.accentColor,
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: Icon(Icons.edit_outlined, color: AppColors.secondaryText),
              onPressed: () => editPlan(plan),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: AppColors.secondaryText),
              onPressed: () => deletePlan(plan),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String text}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: AppColors.mutedText),
          const SizedBox(height: 16),
          Text(
            text,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}
