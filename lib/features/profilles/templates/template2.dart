import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Template2 extends StatefulWidget {
  final String? gymId;

  const Template2({super.key, this.gymId});

  @override
  State<Template2> createState() => _Template2State();
}

class _Template2State extends State<Template2> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? gymData;
  bool isLoading = true;
  String? error;

  late TabController _tabController;

  // Modern Color Scheme - Ocean Blue Theme
  static const Color primaryBlue = Color(0xFF0B4D8C);
  static const Color accentCyan = Color(0xFF00D4FF);
  static const Color lightBlue = Color(0xFF2196F3);
  static const Color darkBlue = Color(0xFF0A2E5C);
  static const Color backgroundLight = Color(0xFFF8FBFF);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color accent = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchGymData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchGymData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      if (widget.gymId != null) {
        DocumentSnapshot docSnapshot =
            await _firestore.collection('gym_profiles').doc(widget.gymId).get();

        if (docSnapshot.exists) {
          gymData = docSnapshot.data() as Map<String, dynamic>;
        } else {
          throw Exception('Gym profile not found');
        }
      } else {
        QuerySnapshot querySnapshot =
            await _firestore.collection('gym_profiles').limit(1).get();

        if (querySnapshot.docs.isNotEmpty) {
          gymData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        } else {
          throw Exception('No gym profiles found');
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        error = e.toString();
      });
    }
  }

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
    return Scaffold(backgroundColor: backgroundLight, body: _buildBody());
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
          CircularProgressIndicator(color: accentCyan, strokeWidth: 3),
          const SizedBox(height: 20),
          Text(
            "Loading gym profile...",
            style: TextStyle(
              fontSize: 16,
              color: textGrey,
              fontWeight: FontWeight.w500,
            ),
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
            Icon(Icons.error_outline, size: 64, color: accent),
            const SizedBox(height: 20),
            Text(
              "Failed to load gym profile",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error ?? "Unknown error occurred",
              style: TextStyle(fontSize: 14, color: textGrey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentCyan,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("RETRY"),
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
            Icon(Icons.fitness_center, size: 64, color: textLight),
            const SizedBox(height: 20),
            Text(
              "No gym profiles found",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Create a gym profile to get started",
              style: TextStyle(fontSize: 14, color: textGrey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentCyan,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("REFRESH"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGymProfile() {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          // Custom App Bar with Hero Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: primaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Hero Image
                  _buildNetworkImage(
                    imageUrl: gymData!['heroImageUrl'] ?? '',
                    fit: BoxFit.cover,
                    placeholder: Container(
                      color: primaryBlue.withValues(alpha: 0.3),
                      child: const Center(
                        child: CircularProgressIndicator(color: accentCyan),
                      ),
                    ),
                    errorWidget: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [primaryBlue, darkBlue],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.fitness_center,
                          size: 64,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ),

                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          primaryBlue.withValues(alpha: 0.7),
                          primaryBlue.withValues(alpha: 0.9),
                        ],
                      ),
                    ),
                  ),

                  // Content Overlay
                  Positioned(
                    bottom: 80,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: _buildNetworkImage(
                              imageUrl: gymData!['logoImageUrl'] ?? '',
                              fit: BoxFit.cover,
                              placeholder: Container(
                                color: Colors.grey[100],
                                child: const Icon(
                                  Icons.fitness_center,
                                  color: Colors.grey,
                                  size: 32,
                                ),
                              ),
                              errorWidget: Container(
                                color: Colors.grey[100],
                                child: const Icon(
                                  Icons.fitness_center,
                                  color: Colors.grey,
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Gym Name
                        Text(
                          gymData!['gymName'] ?? 'Gym Name',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 4,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Tagline
                        Text(
                          "Elevate Your Fitness Journey",
                          style: TextStyle(
                            fontSize: 16,
                            color: accentCyan,
                            fontWeight: FontWeight.w500,
                            shadows: const [
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 2,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons in App Bar
            actions: [
              IconButton(
                onPressed: () => _makePhoneCall(gymData!['mobile'] ?? ''),
                icon: const Icon(Icons.phone, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: accentCyan.withValues(alpha: 0.2),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ];
      },

      // Tab Bar and Content
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: cardWhite,
            child: TabBar(
              controller: _tabController,
              labelColor: primaryBlue,
              unselectedLabelColor: textGrey,
              indicatorColor: accentCyan,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: const [
                Tab(icon: Icon(Icons.info_outline, size: 20), text: "About"),
                Tab(
                  icon: Icon(Icons.fitness_center, size: 20),
                  text: "Services",
                ),
                Tab(
                  icon: Icon(Icons.card_membership, size: 20),
                  text: "Packages",
                ),
                Tab(icon: Icon(Icons.photo_library, size: 20), text: "Gallery"),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAboutTab(),
                _buildServicesTab(),
                _buildPackagesTab(),
                _buildGalleryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: accentCyan,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Info Card
            _buildModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentCyan.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.contact_phone,
                          color: accentCyan,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Contact Information",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Address
                  _buildInfoRow(
                    icon: Icons.location_on,
                    title: "Address",
                    content: gymData!['address'] ?? 'Address not provided',
                    iconColor: accent,
                  ),

                  const SizedBox(height: 16),

                  // Phone
                  GestureDetector(
                    onTap: () => _makePhoneCall(gymData!['mobile'] ?? ''),
                    child: _buildInfoRow(
                      icon: Icons.phone,
                      title: "Phone",
                      content: gymData!['mobile'] ?? 'Phone not provided',
                      iconColor: success,
                      isClickable: true,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // About Us Card
            _buildModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.info, color: primaryBlue, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "About Us",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Text(
                    gymData!['about'] ?? 'About information not provided',
                    style: TextStyle(
                      fontSize: 15,
                      color: textGrey,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Opening Hours (if available)
            if (gymData!['openingHours'] != null) _buildOpeningHoursCard(),

            const SizedBox(height: 20),

            // Awards (if available)
            if (gymData!['awards'] != null) _buildAwardsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Facilities Card
          if (gymData!['facilities'] != null)
            _buildModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: lightBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.fitness_center,
                          color: lightBlue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Our Facilities",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Text(
                    gymData!['facilities'] ??
                        'Facilities information not provided',
                    style: TextStyle(
                      fontSize: 15,
                      color: textGrey,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          // Services Grid
          _buildServicesGrid(),

          const SizedBox(height: 20),

          // Social Links (if available)
          if (gymData!['socialLinks'] != null) _buildSocialLinksCard(),
        ],
      ),
    );
  }

  Widget _buildPackagesTab() {
    final packages = (gymData!['packages'] as List<dynamic>?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            "Choose Your Perfect Plan",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "Start your fitness journey with our flexible membership options",
            style: TextStyle(fontSize: 14, color: textGrey),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          ...packages
              .map<Widget>((package) => _buildPackageCard(package))
              .toList(),

          const SizedBox(height: 20),

          // Call to Action
          _buildCTACard(),
        ],
      ),
    );
  }

  Widget _buildGalleryTab() {
    final galleryImages = (gymData!['galleryImages'] as List<dynamic>?) ?? [];

    if (galleryImages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 64, color: textLight),
            const SizedBox(height: 16),
            Text(
              "No gallery images available",
              style: TextStyle(fontSize: 16, color: textGrey),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemCount: galleryImages.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _showImageDialog(galleryImages[index]),
            child: Hero(
              tag: 'gallery_$index',
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _buildNetworkImage(
                    imageUrl: galleryImages[index],
                    fit: BoxFit.cover,
                    placeholder: Container(
                      color: Colors.grey[100],
                      child: const Center(
                        child: CircularProgressIndicator(color: accentCyan),
                      ),
                    ),
                    errorWidget: Container(
                      color: Colors.grey[100],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String content,
    required Color iconColor,
    bool isClickable = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: textLight,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  fontSize: 15,
                  color: isClickable ? accentCyan : textGrey,
                  fontWeight: FontWeight.w500,
                  decoration: isClickable ? TextDecoration.underline : null,
                ),
              ),
            ],
          ),
        ),
        if (isClickable)
          Icon(Icons.arrow_forward_ios, size: 14, color: textLight),
      ],
    );
  }

  Widget _buildOpeningHoursCard() {
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

    return _buildModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.access_time, color: warning, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                "Opening Hours",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          ...List.generate(days.length, (index) {
            final dayTime = openingHours[days[index]] ?? '';
            if (dayTime.isEmpty) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dayNames[index],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: textDark,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accentCyan.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      dayTime,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: accentCyan,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAwardsCard() {
    return _buildModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.emoji_events, color: warning, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                "Awards & Recognition",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            gymData!['awards'] ?? 'Awards information not provided',
            style: TextStyle(fontSize: 15, color: textGrey, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildServiceCard(
          icon: Icons.fitness_center,
          title: "Weight Training",
          description: "Professional equipment",
          color: accent,
        ),
        _buildServiceCard(
          icon: Icons.directions_run,
          title: "Cardio Zone",
          description: "Modern cardio machines",
          color: success,
        ),
        _buildServiceCard(
          icon: Icons.pool,
          title: "Swimming",
          description: "Olympic size pool",
          color: lightBlue,
        ),
        _buildServiceCard(
          icon: Icons.sports_martial_arts,
          title: "Group Classes",
          description: "Yoga, Pilates & more",
          color: warning,
        ),
      ],
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(fontSize: 12, color: textGrey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinksCard() {
    final socialLinks = gymData!['socialLinks'] as Map<String, dynamic>;

    return _buildModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: lightBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.share, color: lightBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                "Follow Us",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              if (socialLinks['facebook'] != null)
                Expanded(
                  child: _buildSocialButton(
                    icon: Icons.facebook,
                    label: "Facebook",
                    url: socialLinks['facebook'],
                    color: const Color(0xFF1877F2),
                  ),
                ),
              if (socialLinks['facebook'] != null &&
                  socialLinks['instagram'] != null)
                const SizedBox(width: 12),
              if (socialLinks['instagram'] != null)
                Expanded(
                  child: _buildSocialButton(
                    icon: Icons.camera_alt,
                    label: "Instagram",
                    url: socialLinks['instagram'],
                    color: const Color(0xFFE4405F),
                  ),
                ),
            ],
          ),

          if (socialLinks['website'] != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _buildSocialButton(
                icon: Icons.language,
                label: "Visit Website",
                url: socialLinks['website'],
                color: primaryBlue,
              ),
            ),
          ],
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard(Map<String, dynamic> package) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          color: cardWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Package Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryBlue, lightBlue],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    package['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    package['price'] ?? '',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: accentCyan,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Package Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  if (package['description'] != null &&
                      package['description'].isNotEmpty) ...[
                    Text(
                      package['description'],
                      style: TextStyle(
                        fontSize: 15,
                        color: textGrey,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Call to Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _makePhoneCall(gymData!['mobile'] ?? ''),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentCyan,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "GET STARTED",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCTACard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryBlue, darkBlue],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.star, color: accentCyan, size: 32),
          const SizedBox(height: 16),
          const Text(
            "Ready to Transform?",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            "Join thousands of members who have achieved their fitness goals with us",
            style: TextStyle(fontSize: 14, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _makePhoneCall(gymData!['mobile'] ?? ''),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentCyan,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "CALL NOW",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Navigate to contact or more info
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "LEARN MORE",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
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
                  placeholder: const Center(
                    child: CircularProgressIndicator(color: accentCyan),
                  ),
                  errorWidget: const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.white54,
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildNetworkImage({
    required String imageUrl,
    BoxFit? fit,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    if (imageUrl.isEmpty) {
      return errorWidget ??
          Container(
            color: Colors.grey[100],
            child: const Icon(Icons.image_not_supported, color: Colors.grey),
          );
    }

    return Image.network(
      imageUrl,
      fit: fit ?? BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return placeholder ??
            Container(
              color: Colors.grey[100],
              child: Center(
                child: CircularProgressIndicator(
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                  color: accentCyan,
                  strokeWidth: 2,
                ),
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ??
            Container(
              color: Colors.grey[100],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            );
      },
    );
  }
}
