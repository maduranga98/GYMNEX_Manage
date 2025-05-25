import 'package:flutter/material.dart';
import 'package:gymnex_manage/core/data/preset_color_schemes.dart';
import 'package:gymnex_manage/core/models/color_scheme_model.dart';
import 'package:gymnex_manage/core/utils/app_colors.dart';
import 'package:gymnex_manage/core/utils/app_typography.dart';
import 'package:gymnex_manage/core/data/services_data.dart';
import 'package:gymnex_manage/features/profilles/widgets/color_selection_section.dart';
import 'package:gymnex_manage/features/profilles/widgets/color_selection_toggle.dart';
import 'package:gymnex_manage/features/profilles/widgets/serviceselection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class Setup extends StatefulWidget {
  const Setup({super.key});

  @override
  State<Setup> createState() => _SetupState();
}

class _SetupState extends State<Setup> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  bool _showColorCustomization = false;
  late GymColorScheme _selectedColorScheme;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Controllers for text fields
  final _gymNameController = TextEditingController();
  final _aboutController = TextEditingController();
  final _addressController = TextEditingController();
  final _mobileController = TextEditingController();

  // Optional sections controllers
  final _mondayController = TextEditingController();
  final _tuesdayController = TextEditingController();
  final _wednesdayController = TextEditingController();
  final _thursdayController = TextEditingController();
  final _fridayController = TextEditingController();
  final _saturdayController = TextEditingController();
  final _sundayController = TextEditingController();

  final _facilitiesController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _websiteController = TextEditingController();
  final _awardsController = TextEditingController();

  // Package controllers
  final _packageNameController = TextEditingController();
  final _packagePriceController = TextEditingController();
  final _packageDescriptionController = TextEditingController();

  // State variables
  File? _heroImage;
  File? _logoImage;
  List<File> _galleryImages = [];
  List<Map<String, String>> _packages = [];
  List<int> _selectedServiceIndices = []; // Added for services

  // Optional sections toggles
  bool _showOpeningHours = false;
  bool _showFacilities = false;
  bool _showServices = false; // Added for services
  bool _showSocialLinks = false;
  bool _showAwards = false;
  bool _showGallery = false;

  // Loading state
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    super.initState();
    _selectedColorScheme = PresetColorSchemes.presets.first;
  }

  @override
  void dispose() {
    _gymNameController.dispose();
    _aboutController.dispose();
    _addressController.dispose();
    _mobileController.dispose();
    _mondayController.dispose();
    _tuesdayController.dispose();
    _wednesdayController.dispose();
    _thursdayController.dispose();
    _fridayController.dispose();
    _saturdayController.dispose();
    _sundayController.dispose();
    _facilitiesController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _websiteController.dispose();
    _awardsController.dispose();
    _packageNameController.dispose();
    _packagePriceController.dispose();
    _packageDescriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String type) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        if (type == 'hero') {
          _heroImage = File(image.path);
        } else if (type == 'logo') {
          _logoImage = File(image.path);
        }
      });
    }
  }

  void _onColorSchemeChanged(GymColorScheme newScheme) {
    setState(() {
      _selectedColorScheme = newScheme;
    });
  }

  Future<void> _pickGalleryImages() async {
    final List<XFile> images = await _picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (images.isNotEmpty) {
      setState(() {
        _galleryImages.addAll(images.map((img) => File(img.path)).toList());
        if (_galleryImages.length > 6) {
          _galleryImages = _galleryImages.take(6).toList();
        }
      });
    }
  }

  void _addPackage() {
    if (_packageNameController.text.isNotEmpty &&
        _packagePriceController.text.isNotEmpty) {
      setState(() {
        _packages.add({
          'name': _packageNameController.text,
          'price': _packagePriceController.text,
          'description': _packageDescriptionController.text,
        });
        _packageNameController.clear();
        _packagePriceController.clear();
        _packageDescriptionController.clear();
      });
    }
  }

  void _removePackage(int index) {
    setState(() {
      _packages.removeAt(index);
    });
  }

  void _removeGalleryImage(int index) {
    setState(() {
      _galleryImages.removeAt(index);
    });
  }

  // Navigate to services selection page
  Future<void> _navigateToServicesSelection() async {
    final result = await Navigator.push<List<int>>(
      context,
      MaterialPageRoute(
        builder:
            (context) => ServicesSelectionPage(
              gymId: null, // Will be set during save
              initialSelectedIndices: _selectedServiceIndices,
            ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedServiceIndices = result;
      });
    }
  }

  Future<String?> _uploadImage(File image, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(image);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<List<String>> _uploadGalleryImages(
    List<File> images,
    String gymId,
  ) async {
    List<String> urls = [];
    for (int i = 0; i < images.length; i++) {
      final url = await _uploadImage(
        images[i],
        'gym_profiles/$gymId/gallery/image_$i.jpg',
      );
      if (url != null) {
        urls.add(url);
      }
    }
    return urls;
  }

  Future<void> _saveGymProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_heroImage == null) {
      _showErrorSnackBar('Please add a hero image');
      return;
    }

    if (_logoImage == null) {
      _showErrorSnackBar('Please add a logo');
      return;
    }

    if (_packages.isEmpty) {
      _showErrorSnackBar('Please add at least one package');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Generate document ID
      final docRef = _firestore.collection('gym_profiles').doc();
      final gymId = docRef.id;

      // Upload hero image
      final heroImageUrl = await _uploadImage(
        _heroImage!,
        'gym_profiles/$gymId/hero.jpg',
      );
      if (heroImageUrl == null) {
        throw Exception('Failed to upload hero image');
      }

      // Upload logo
      final logoImageUrl = await _uploadImage(
        _logoImage!,
        'gym_profiles/$gymId/logo.jpg',
      );
      if (logoImageUrl == null) {
        throw Exception('Failed to upload logo');
      }

      // Upload gallery images if any
      List<String> galleryUrls = [];
      if (_galleryImages.isNotEmpty) {
        galleryUrls = await _uploadGalleryImages(_galleryImages, gymId);
      }

      // Prepare gym profile data
      Map<String, dynamic> gymProfileData = {
        'id': gymId,
        'gymName': _gymNameController.text.trim(),
        'about': _aboutController.text.trim(),
        'address': _addressController.text.trim(),
        'mobile': _mobileController.text.trim(),
        'heroImageUrl': heroImageUrl,
        'logoImageUrl': logoImageUrl,
        'packages': _packages,
        'colorScheme': _selectedColorScheme.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add optional sections if enabled
      if (_showOpeningHours) {
        gymProfileData['openingHours'] = {
          'monday': _mondayController.text.trim(),
          'tuesday': _tuesdayController.text.trim(),
          'wednesday': _wednesdayController.text.trim(),
          'thursday': _thursdayController.text.trim(),
          'friday': _fridayController.text.trim(),
          'saturday': _saturdayController.text.trim(),
          'sunday': _sundayController.text.trim(),
        };
      }

      if (_showFacilities && _facilitiesController.text.trim().isNotEmpty) {
        gymProfileData['facilities'] = _facilitiesController.text.trim();
      }

      // Add services if enabled and selected
      if (_showServices && _selectedServiceIndices.isNotEmpty) {
        gymProfileData['serviceIndices'] = _selectedServiceIndices;
      }

      if (_showSocialLinks) {
        Map<String, String> socialLinks = {};
        if (_facebookController.text.trim().isNotEmpty) {
          socialLinks['facebook'] = _facebookController.text.trim();
        }
        if (_instagramController.text.trim().isNotEmpty) {
          socialLinks['instagram'] = _instagramController.text.trim();
        }
        if (_websiteController.text.trim().isNotEmpty) {
          socialLinks['website'] = _websiteController.text.trim();
        }
        if (socialLinks.isNotEmpty) {
          gymProfileData['socialLinks'] = socialLinks;
        }
      }

      if (_showAwards && _awardsController.text.trim().isNotEmpty) {
        gymProfileData['awards'] = _awardsController.text.trim();
      }

      if (_showGallery && galleryUrls.isNotEmpty) {
        gymProfileData['galleryImages'] = galleryUrls;
      }

      // Save to Firestore
      await docRef.set(gymProfileData);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gym profile setup completed successfully!',
              style: AppTypography.bodyMedium,
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate back or to next screen
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error saving gym profile: $e');
      _showErrorSnackBar('Failed to save gym profile. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTypography.bodyMedium),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text("GYM PROFILE SETUP", style: AppTypography.h3),
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primaryText),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              trackVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Image Section
                    _buildSectionCard(
                      title: "HERO IMAGE*",
                      child: _buildImagePicker(
                        image: _heroImage,
                        onTap: () => _pickImage('hero'),
                        height: 200,
                        placeholder: "Add a powerful hero image for your gym",
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Logo Section
                    _buildSectionCard(
                      title: "LOGO*",
                      child: _buildImagePicker(
                        image: _logoImage,
                        onTap: () => _pickImage('logo'),
                        height: 120,
                        placeholder: "Upload your gym logo",
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Basic Information
                    _buildSectionCard(
                      title: "BASIC INFORMATION",
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _gymNameController,
                            label: "Gym Name*",
                            hint: "Enter your gym name",
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Gym name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _aboutController,
                            label: "About Us*",
                            hint: "Tell us about your gym's mission and vision",
                            maxLines: 4,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'About us is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _addressController,
                            label: "Address*",
                            hint: "Enter your complete gym address",
                            maxLines: 2,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Address is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _mobileController,
                            label: "Mobile Number*",
                            hint: "Enter contact number",
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Mobile number is required';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Packages Section
                    _buildSectionCard(
                      title: "MEMBERSHIP PACKAGES*",
                      child: Column(
                        children: [
                          // Add Package Form
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.inputBackground,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.inputBorder),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: _buildTextField(
                                        controller: _packageNameController,
                                        label: "Package Name",
                                        hint: "e.g., Premium Monthly",
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _packagePriceController,
                                        label: "Price",
                                        hint: "₹2999",
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _packageDescriptionController,
                                  label: "Description (Optional)",
                                  hint: "Package features and benefits...",
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _addPackage,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.accentColor,
                                      foregroundColor: AppColors.buttonText,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      "ADD PACKAGE",
                                      style: AppTypography.button,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Display Added Packages
                          if (_packages.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            ..._packages.asMap().entries.map((entry) {
                              int index = entry.key;
                              Map<String, String> package = entry.value;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.inputBackground,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.inputBorder,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            package['name']!,
                                            style: AppTypography.bodyLarge,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            package['price']!,
                                            style: AppTypography.bodyLarge
                                                .copyWith(
                                                  color: AppColors.accentColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          if (package['description']!
                                              .isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              package['description']!,
                                              style: AppTypography.bodySmall,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _removePackage(index),
                                      icon: const Icon(Icons.delete_outline),
                                      color: AppColors.error,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],

                          if (_packages.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                "No packages added yet",
                                style: AppTypography.bodyMedium.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Optional Sections Header
                    Text(
                      "OPTIONAL SECTIONS",
                      style: AppTypography.h3.copyWith(
                        color: AppColors.secondaryText,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Optional Sections Toggles
                    _buildOptionalSectionToggle(
                      title: "Opening Hours",
                      icon: Icons.access_time,
                      value: _showOpeningHours,
                      onChanged:
                          (value) => setState(() => _showOpeningHours = value),
                    ),

                    if (_showOpeningHours) ...[
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        title: "OPENING HOURS",
                        child: Column(
                          children: [
                            _buildTimeField("Monday", _mondayController),
                            _buildTimeField("Tuesday", _tuesdayController),
                            _buildTimeField("Wednesday", _wednesdayController),
                            _buildTimeField("Thursday", _thursdayController),
                            _buildTimeField("Friday", _fridayController),
                            _buildTimeField("Saturday", _saturdayController),
                            _buildTimeField("Sunday", _sundayController),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    _buildOptionalSectionToggle(
                      title: "Facilities",
                      icon: Icons.fitness_center,
                      value: _showFacilities,
                      onChanged:
                          (value) => setState(() => _showFacilities = value),
                    ),

                    if (_showFacilities) ...[
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        title: "GYM FACILITIES",
                        child: _buildTextField(
                          controller: _facilitiesController,
                          label: "Facilities",
                          hint:
                              "Cardio Zone, Weight Training, Swimming Pool, Sauna...",
                          maxLines: 3,
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Services & Amenities Toggle
                    _buildOptionalSectionToggle(
                      title: "Services & Amenities",
                      icon: Icons.room_service,
                      value: _showServices,
                      onChanged:
                          (value) => setState(() => _showServices = value),
                    ),

                    if (_showServices) ...[
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        title: "SERVICES & AMENITIES",
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Select the services and amenities your gym offers to help members know what to expect.",
                              style: AppTypography.bodyMedium,
                            ),

                            const SizedBox(height: 20),

                            // Services selection button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _navigateToServicesSelection,
                                icon: Icon(
                                  _selectedServiceIndices.isEmpty
                                      ? Icons.add
                                      : Icons.edit,
                                  color: AppColors.accentColor,
                                ),
                                label: Text(
                                  _selectedServiceIndices.isEmpty
                                      ? "SELECT SERVICES"
                                      : "EDIT SERVICES (${_selectedServiceIndices.length} selected)",
                                  style: AppTypography.button.copyWith(
                                    color: AppColors.accentColor,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  side: const BorderSide(
                                    color: AppColors.accentColor,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),

                            // Display selected services
                            if (_selectedServiceIndices.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              Text(
                                "Selected Services:",
                                style: AppTypography.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children:
                                    _selectedServiceIndices.map((index) {
                                      final services =
                                          ServicesData.getServicesByIndices([
                                            index,
                                          ]);
                                      if (services.isEmpty)
                                        return const SizedBox.shrink();

                                      final service = services.first;
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.accentColor
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: AppColors.accentColor
                                                .withOpacity(0.3),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              service['icon'],
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              service['name'],
                                              style: AppTypography.bodySmall
                                                  .copyWith(
                                                    color:
                                                        AppColors.accentColor,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    _buildOptionalSectionToggle(
                      title: "Social Links",
                      icon: Icons.share,
                      value: _showSocialLinks,
                      onChanged:
                          (value) => setState(() => _showSocialLinks = value),
                    ),

                    if (_showSocialLinks) ...[
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        title: "SOCIAL MEDIA",
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _facebookController,
                              label: "Facebook",
                              hint: "https://facebook.com/yourgym",
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              controller: _instagramController,
                              label: "Instagram",
                              hint: "https://instagram.com/yourgym",
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              controller: _websiteController,
                              label: "Website",
                              hint: "https://yourgym.com",
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    _buildOptionalSectionToggle(
                      title: "Awards & Recognition",
                      icon: Icons.emoji_events,
                      value: _showAwards,
                      onChanged: (value) => setState(() => _showAwards = value),
                    ),

                    if (_showAwards) ...[
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        title: "AWARDS & ACHIEVEMENTS",
                        child: _buildTextField(
                          controller: _awardsController,
                          label: "Awards & Recognition",
                          hint:
                              "Best Gym 2024, Excellence in Fitness Training...",
                          maxLines: 3,
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    _buildOptionalSectionToggle(
                      title: "Photo Gallery",
                      icon: Icons.photo_library,
                      value: _showGallery,
                      onChanged:
                          (value) => setState(() => _showGallery = value),
                    ),

                    if (_showGallery) ...[
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        title: "GALLERY (MAX 6 IMAGES)",
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed:
                                    _galleryImages.length < 6
                                        ? _pickGalleryImages
                                        : null,
                                icon: const Icon(
                                  Icons.add_photo_alternate,
                                  color: AppColors.accentColor,
                                ),
                                label: Text(
                                  _galleryImages.isEmpty
                                      ? "ADD GALLERY IMAGES"
                                      : "ADD MORE (${_galleryImages.length}/6)",
                                  style: AppTypography.button.copyWith(
                                    color: AppColors.accentColor,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  side: const BorderSide(
                                    color: AppColors.accentColor,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            if (_galleryImages.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 1.5,
                                    ),
                                itemCount: _galleryImages.length,
                                itemBuilder: (context, index) {
                                  return Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: AppColors.inputBorder,
                                          ),
                                          image: DecorationImage(
                                            image: FileImage(
                                              _galleryImages[index],
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: GestureDetector(
                                          onTap:
                                              () => _removeGalleryImage(index),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: AppColors.error,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Color Customization Toggle
                    ColorSelectionToggle(
                      value: _showColorCustomization,
                      onChanged:
                          (value) =>
                              setState(() => _showColorCustomization = value),
                    ),

                    // Color Selection Section
                    if (_showColorCustomization) ...[
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        title: "COLOR THEME",
                        child: ColorSelectionSection(
                          initialColorScheme: _selectedColorScheme,
                          onColorSchemeChanged: _onColorSchemeChanged,
                        ),
                      ),
                    ],
                    const SizedBox(height: 40),

                    // Submit Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.accentColor, Color(0xFFB91C3C)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentColor.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveGymProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: AppColors.buttonText,
                                    strokeWidth: 2,
                                  ),
                                )
                                : Text(
                                  "COMPLETE SETUP",
                                  style: AppTypography.h3.copyWith(
                                    fontSize: 16,
                                    color: AppColors.buttonText,
                                  ),
                                ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: AppColors.overlay,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.accentColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.h3.copyWith(fontSize: 16)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTypography.inputText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.label,
        hintText: hint,
        hintStyle: AppTypography.inputHint,
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.focusedBorder,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildImagePicker({
    required File? image,
    required VoidCallback onTap,
    required double height,
    required String placeholder,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.inputBorder),
          image:
              image != null
                  ? DecorationImage(image: FileImage(image), fit: BoxFit.cover)
                  : null,
        ),
        child:
            image == null
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: 48,
                      color: AppColors.iconInactive,
                    ),
                    const SizedBox(height: 12),
                    Text(placeholder, style: AppTypography.bodyMedium),
                  ],
                )
                : null,
      ),
    );
  }

  Widget _buildTimeField(String day, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(day, style: AppTypography.bodyLarge),
          ),
          Expanded(
            child: _buildTextField(
              controller: controller,
              label: "",
              hint: "9:00 AM - 10:00 PM",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionalSectionToggle({
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value ? AppColors.accentColor : AppColors.inputBorder,
          width: value ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: value ? AppColors.accentColor : AppColors.iconInactive,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: AppTypography.bodyLarge.copyWith(
                color: value ? AppColors.primaryText : AppColors.secondaryText,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accentColor,
            inactiveThumbColor: AppColors.mutedText,
            inactiveTrackColor: AppColors.inputBackground,
          ),
        ],
      ),
    );
  }
}
