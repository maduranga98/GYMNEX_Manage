import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gymnex_manage/core/utils/app_colors.dart';
import 'package:gymnex_manage/core/utils/app_typography.dart';
import 'package:gymnex_manage/core/models/color_scheme_model.dart';
import 'package:gymnex_manage/core/data/preset_color_schemes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Template1 extends StatefulWidget {
  final String? gymId; // Optional - if provided, fetch specific gym

  const Template1({super.key, this.gymId});

  @override
  State<Template1> createState() => _Template1State();
}

class _Template1State extends State<Template1> {
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? gymData;
  GymColorScheme? colorScheme;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchGymData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Fetch gym data from Firebase and load color scheme
  Future<void> _fetchGymData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      QuerySnapshot querySnapshot;

      if (widget.gymId != null) {
        // Fetch specific gym by ID
        DocumentSnapshot docSnapshot =
            await _firestore.collection('gym_profiles').doc(widget.gymId).get();

        if (docSnapshot.exists) {
          gymData = docSnapshot.data() as Map<String, dynamic>;
        } else {
          throw Exception('Gym profile not found');
        }
      } else {
        // Fetch the first available gym profile (you can modify this logic)
        querySnapshot =
            await _firestore.collection('gym_profiles').limit(1).get();

        if (querySnapshot.docs.isNotEmpty) {
          gymData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        } else {
          throw Exception('No gym profiles found');
        }
      }

      // Load color scheme from gym data
      _loadColorScheme();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        error = e.toString();
      });
      print('Error fetching gym data: $e');
    }
  }

  // Load color scheme from gym data or use default
  void _loadColorScheme() {
    if (gymData != null && gymData!['colorScheme'] != null) {
      try {
        final colorSchemeData = gymData!['colorScheme'] as Map<String, dynamic>;
        colorScheme = GymColorScheme.fromMap(colorSchemeData);
      } catch (e) {
        print('Error loading color scheme: $e');
        // Fallback to default scheme
        colorScheme = PresetColorSchemes.presets.first;
      }
    } else {
      // Use default color scheme
      colorScheme = PresetColorSchemes.presets.first;
    }
  }

  // Get colors from the loaded scheme or fallback to AppColors
  Color get backgroundColor =>
      colorScheme?.backgroundColor ?? AppColors.scaffoldBackground;
  Color get cardColor => colorScheme?.cardColor ?? AppColors.cardBackground;
  Color get primaryTextColor =>
      colorScheme?.primaryTextColor ?? AppColors.primaryText;
  Color get secondaryTextColor =>
      colorScheme?.secondaryTextColor ?? AppColors.secondaryText;
  Color get headingColor => colorScheme?.headingColor ?? AppColors.primaryText;
  Color get accentColor => colorScheme?.accentColor ?? AppColors.accentColor;
  Color get buttonColor => colorScheme?.buttonColor ?? AppColors.buttonColor;
  Color get borderColor => colorScheme?.borderColor ?? AppColors.inputBorder;

  // Refresh data
  Future<void> _refreshData() async {
    await _fetchGymData();
  }

  Future<void> _launchUrl(String url) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: _buildBody(),

      // Floating Action Button for Quick Contact (only show when data is loaded)
      floatingActionButton:
          gymData != null
              ? FloatingActionButton(
                onPressed: () => _makePhoneCall(gymData!['mobile'] ?? ''),
                backgroundColor: accentColor,
                child: Icon(Icons.phone, color: _getContrastColor(accentColor)),
              )
              : null,
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (error != null) {
      return _buildErrorState();
    }

    if (gymData == null) {
      return _buildEmptyState();
    }

    return _buildGymProfile();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: accentColor, strokeWidth: 3),
          const SizedBox(height: 20),
          Text(
            "Loading gym profile...",
            style: AppTypography.bodyLarge.copyWith(color: primaryTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 20),
            Text(
              "Failed to load gym profile",
              style: AppTypography.h3.copyWith(color: headingColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error ?? "Unknown error occurred",
              style: AppTypography.bodyMedium.copyWith(
                color: secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: _getContrastColor(buttonColor),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text("RETRY", style: AppTypography.button),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: secondaryTextColor),
            const SizedBox(height: 20),
            Text(
              "No gym profiles found",
              style: AppTypography.h3.copyWith(color: headingColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Create a gym profile to get started",
              style: AppTypography.bodyMedium.copyWith(
                color: secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: _getContrastColor(buttonColor),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text("REFRESH", style: AppTypography.button),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGymProfile() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: accentColor,
      backgroundColor: cardColor,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section with Logo Overlay
            _buildHeroSection(),

            // Main Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gym Name and Basic Info
                  _buildGymHeader(),

                  const SizedBox(height: 24),

                  // Contact Information
                  _buildContactInfo(),

                  const SizedBox(height: 32),

                  // About Us Section
                  _buildAboutSection(),

                  const SizedBox(height: 32),

                  // Opening Hours (if available)
                  if (gymData!['openingHours'] != null) ...[
                    _buildOpeningHours(),
                    const SizedBox(height: 32),
                  ],

                  // Facilities (if available)
                  if (gymData!['facilities'] != null) ...[
                    _buildFacilities(),
                    const SizedBox(height: 32),
                  ],

                  // Membership Packages
                  _buildPackages(),

                  const SizedBox(height: 32),

                  // Awards (if available)
                  if (gymData!['awards'] != null) ...[
                    _buildAwards(),
                    const SizedBox(height: 32),
                  ],

                  // Social Links (if available)
                  if (gymData!['socialLinks'] != null) ...[
                    _buildSocialLinks(),
                    const SizedBox(height: 32),
                  ],

                  // Gallery (if available)
                  if (gymData!['galleryImages'] != null) ...[
                    _buildGallery(),
                    const SizedBox(height: 32),
                  ],

                  // Footer
                  _buildFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 300,
      width: double.infinity,
      child: Stack(
        children: [
          // Hero Image
          Container(
            height: 300,
            width: double.infinity,
            child: _buildNetworkImage(
              imageUrl: gymData!['heroImageUrl'] ?? '',
              fit: BoxFit.cover,
              placeholder: Container(
                color: cardColor,
                child: Center(
                  child: CircularProgressIndicator(color: accentColor),
                ),
              ),
              errorWidget: Container(
                color: cardColor,
                child: Icon(
                  Icons.fitness_center,
                  size: 64,
                  color: secondaryTextColor,
                ),
              ),
            ),
          ),

          // Gradient Overlay
          Container(
            height: 300,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  backgroundColor.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),

          // Logo Positioned at Bottom
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accentColor, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: CachedNetworkImage(
                  imageUrl: gymData!['logoImageUrl'] ?? '',
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
                        color: cardColor,
                        child: Icon(
                          Icons.fitness_center,
                          color: secondaryTextColor,
                        ),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        color: cardColor,
                        child: Icon(
                          Icons.fitness_center,
                          color: secondaryTextColor,
                        ),
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGymHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          gymData!['gymName'] ?? 'Gym Name',
          style: AppTypography.h1.copyWith(color: headingColor),
        ),
        const SizedBox(height: 8),
        Text(
          "Transform Your Body, Transform Your Life",
          style: AppTypography.bodyLarge.copyWith(
            color: accentColor,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, color: accentColor, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Location",
                      style: AppTypography.label.copyWith(
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      gymData!['address'] ?? 'Address not provided',
                      style: AppTypography.bodyMedium.copyWith(
                        color: primaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Phone Number
          GestureDetector(
            onTap: () => _makePhoneCall(gymData!['mobile'] ?? ''),
            child: Row(
              children: [
                Icon(Icons.phone, color: accentColor, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Contact",
                        style: AppTypography.label.copyWith(
                          color: secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        gymData!['mobile'] ?? 'Phone not provided',
                        style: AppTypography.bodyMedium.copyWith(
                          color: accentColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: secondaryTextColor,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return _buildSectionContainer(
      title: "ABOUT US",
      icon: Icons.info_outline,
      child: Text(
        gymData!['about'] ?? 'About information not provided',
        style: AppTypography.bodyMedium.copyWith(color: primaryTextColor),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildOpeningHours() {
    final openingHours = gymData!['openingHours'] as Map<String, dynamic>;
    final days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    final dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return _buildSectionContainer(
      title: "OPENING HOURS",
      icon: Icons.access_time,
      child: Column(
        children: List.generate(days.length, (index) {
          final dayTime = openingHours[days[index]] ?? '';
          if (dayTime.isEmpty) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dayNames[index],
                  style: AppTypography.bodyLarge.copyWith(
                    color: primaryTextColor,
                  ),
                ),
                Text(
                  dayTime,
                  style: AppTypography.bodyMedium.copyWith(color: accentColor),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFacilities() {
    return _buildSectionContainer(
      title: "FACILITIES",
      icon: Icons.fitness_center,
      child: Text(
        gymData!['facilities'] ?? 'Facilities information not provided',
        style: AppTypography.bodyMedium.copyWith(color: primaryTextColor),
      ),
    );
  }

  Widget _buildPackages() {
    final packages = (gymData!['packages'] as List<dynamic>?) ?? [];

    return _buildSectionContainer(
      title: "MEMBERSHIP PACKAGES",
      icon: Icons.card_membership,
      child: Column(
        children:
            packages.map<Widget>((package) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            package['name'] ?? '',
                            style: AppTypography.h3.copyWith(
                              fontSize: 18,
                              color: headingColor,
                            ),
                          ),
                        ),
                        Text(
                          package['price'] ?? '',
                          style: AppTypography.h3.copyWith(
                            fontSize: 20,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                    if (package['description'] != null &&
                        package['description'].isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        package['description'],
                        style: AppTypography.bodySmall.copyWith(
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildAwards() {
    return _buildSectionContainer(
      title: "AWARDS & RECOGNITION",
      icon: Icons.emoji_events,
      child: Text(
        gymData!['awards'] ?? 'Awards information not provided',
        style: AppTypography.bodyMedium.copyWith(color: primaryTextColor),
      ),
    );
  }

  Widget _buildSocialLinks() {
    final socialLinks = gymData!['socialLinks'] as Map<String, dynamic>;

    return _buildSectionContainer(
      title: "CONNECT WITH US",
      icon: Icons.share,
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          if (socialLinks['facebook'] != null)
            _buildSocialButton(
              icon: Icons.facebook,
              label: "Facebook",
              url: socialLinks['facebook'],
              color: const Color(0xFF1877F2),
            ),
          if (socialLinks['instagram'] != null)
            _buildSocialButton(
              icon: Icons.camera_alt,
              label: "Instagram",
              url: socialLinks['instagram'],
              color: const Color(0xFFE4405F),
            ),
          if (socialLinks['website'] != null)
            _buildSocialButton(
              icon: Icons.language,
              label: "Website",
              url: socialLinks['website'],
              color: accentColor,
            ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required String url,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: AppTypography.bodyMedium.copyWith(color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildGallery() {
    final galleryImages = (gymData!['galleryImages'] as List<dynamic>?) ?? [];

    return _buildSectionContainer(
      title: "GALLERY",
      icon: Icons.photo_library,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: galleryImages.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _showImageDialog(galleryImages[index]),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: _buildNetworkImage(
                  imageUrl: galleryImages[index],
                  fit: BoxFit.cover,
                  placeholder: Container(
                    color: cardColor,
                    child: Center(
                      child: CircularProgressIndicator(color: accentColor),
                    ),
                  ),
                  errorWidget: Container(
                    color: cardColor,
                    child: Icon(Icons.broken_image, color: secondaryTextColor),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: InteractiveViewer(
                child: _buildNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: Center(
                    child: CircularProgressIndicator(color: accentColor),
                  ),
                  errorWidget: Center(
                    child: Icon(
                      Icons.broken_image,
                      color: secondaryTextColor,
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(Icons.fitness_center, color: accentColor, size: 32),
          const SizedBox(height: 12),
          Text(
            "Ready to Start Your Fitness Journey?",
            style: AppTypography.h3.copyWith(fontSize: 18, color: headingColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Contact us today to learn more about our programs and facilities.",
            style: AppTypography.bodyMedium.copyWith(color: primaryTextColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _makePhoneCall(gymData!['mobile'] ?? ''),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: _getContrastColor(buttonColor),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text("CALL NOW", style: AppTypography.button),
            ),
          ),
        ],
      ),
    );
  }

  // Custom network image builder to avoid caching issues
  Widget _buildNetworkImage({
    required String imageUrl,
    BoxFit? fit,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    if (imageUrl.isEmpty) {
      return errorWidget ??
          Container(
            color: cardColor,
            child: Icon(Icons.image_not_supported, color: secondaryTextColor),
          );
    }

    return Image.network(
      imageUrl,
      fit: fit ?? BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return placeholder ??
            Container(
              color: cardColor,
              child: Center(
                child: CircularProgressIndicator(
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                  color: accentColor,
                  strokeWidth: 2,
                ),
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ??
            Container(
              color: cardColor,
              child: Icon(Icons.broken_image, color: secondaryTextColor),
            );
      },
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTypography.h3.copyWith(
                  fontSize: 16,
                  color: headingColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  // Helper method to get contrast color for text on colored backgrounds
  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
