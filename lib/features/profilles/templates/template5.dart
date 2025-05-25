import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;

class Template5 extends StatefulWidget {
  final String? gymId;

  const Template5({super.key, this.gymId});

  @override
  State<Template5> createState() => _Template5State();
}

class _Template5State extends State<Template5> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? gymData;
  bool isLoading = true;
  String? error;

  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  // Athletic Performance Color Scheme - Bold Sports Theme
  static const Color athleticRed = Color(0xFFE53E3E);
  static const Color powerBlue = Color(0xFF3182CE);
  static const Color energyGreen = Color(0xFF38A169);
  static const Color thunderYellow = Color(0xFFD69E2E);
  static const Color titaniumGray = Color(0xFF4A5568);
  static const Color carbonBlack = Color(0xFF1A202C);
  static const Color steelBlue = Color(0xFF2D3748);
  static const Color brightWhite = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF7FAFC);
  static const Color mediumGray = Color(0xFFE2E8F0);
  static const Color darkText = Color(0xFF2D3748);
  static const Color lightText = Color(0xFF718096);
  static const Color accentOrange = Color(0xFFED8936);
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color eliteGold = Color(0xFFFFB020);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _fetchGymData();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
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

      _scaleController.forward();
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
    return Scaffold(
      backgroundColor: lightGray,
      body: _buildBody(),
      floatingActionButton: gymData != null ? _buildAthleticFAB() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: gymData != null ? _buildBottomBar() : null,
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [carbonBlack, steelBlue, powerBlue],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [athleticRed, powerBlue, energyGreen],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: athleticRed.withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.speed, size: 48, color: brightWhite),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            ShaderMask(
              shaderCallback:
                  (bounds) => LinearGradient(
                    colors: [athleticRed, thunderYellow, energyGreen],
                  ).createShader(bounds),
              child: const Text(
                "LOADING PERFORMANCE...",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: brightWhite,
                  letterSpacing: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [carbonBlack, athleticRed.withValues(alpha: 0.2)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [athleticRed, accentOrange]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: athleticRed.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(Icons.warning, size: 48, color: brightWhite),
              ),
              const SizedBox(height: 24),
              ShaderMask(
                shaderCallback:
                    (bounds) => LinearGradient(
                      colors: [athleticRed, accentOrange],
                    ).createShader(bounds),
                child: const Text(
                  "TRAINING INTERRUPTED",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: brightWhite,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                error ?? "Connection failed. Let's get back to training!",
                style: const TextStyle(
                  fontSize: 14,
                  color: lightText,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildAthleticButton(
                text: "RETRY WORKOUT",
                onPressed: _refreshData,
                gradient: [energyGreen, neonCyan],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [carbonBlack, powerBlue.withValues(alpha: 0.2)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [powerBlue, energyGreen]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: powerBlue.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.fitness_center,
                  size: 48,
                  color: brightWhite,
                ),
              ),
              const SizedBox(height: 24),
              ShaderMask(
                shaderCallback:
                    (bounds) => LinearGradient(
                      colors: [powerBlue, energyGreen],
                    ).createShader(bounds),
                child: const Text(
                  "NO TRAINING CENTERS",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: brightWhite,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Time to build your performance empire",
                style: TextStyle(
                  fontSize: 14,
                  color: lightText,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildAthleticButton(
                text: "START TRAINING",
                onPressed: _refreshData,
                gradient: [thunderYellow, eliteGold],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGymProfile() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: athleticRed,
      backgroundColor: brightWhite,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Dynamic Hero Section
          _buildAthleticHeroSliver(),

          // Main Content
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    children: [
                      // Performance Stats
                      _buildPerformanceStats(),

                      // Action Cards
                      _buildActionCards(),

                      // About Section
                      _buildAthleticAbout(),

                      // Training Programs
                      _buildTrainingPrograms(),

                      // Membership Plans
                      _buildMembershipPlans(),

                      // Training Gallery
                      if (gymData!['galleryImages'] != null)
                        _buildTrainingGallery(),

                      // Schedule & Hours
                      if (gymData!['openingHours'] != null)
                        _buildTrainingSchedule(),

                      // Achievements & Social
                      _buildAchievementsSection(),

                      // Final Push CTA
                      _buildFinalPushCTA(),

                      const SizedBox(height: 120),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAthleticHeroSliver() {
    return SliverAppBar(
      expandedHeight: 450,
      pinned: true,
      backgroundColor: carbonBlack,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Hero Image with Dynamic Overlay
            _buildNetworkImage(
              imageUrl: gymData!['heroImageUrl'] ?? '',
              fit: BoxFit.cover,
              placeholder: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [carbonBlack, athleticRed, powerBlue, energyGreen],
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: brightWhite,
                    strokeWidth: 3,
                  ),
                ),
              ),
              errorWidget: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [carbonBlack, athleticRed, powerBlue, energyGreen],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.speed, size: 80, color: brightWhite),
                ),
              ),
            ),

            // Dynamic Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    carbonBlack.withValues(alpha: 0.3),
                    carbonBlack.withValues(alpha: 0.7),
                    carbonBlack.withValues(alpha: 0.9),
                    carbonBlack,
                  ],
                ),
              ),
            ),

            // Animated Elements
            Positioned(
              top: 100,
              right: 30,
              child: AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [athleticRed, thunderYellow],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Performance Indicators
            Positioned(
              top: 150,
              left: 50,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value * 0.8,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: neonCyan.withValues(alpha: 0.8),
                        boxShadow: [
                          BoxShadow(
                            color: neonCyan.withValues(alpha: 0.5),
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Main Content
            Positioned(
              bottom: 60,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo with Power Effect
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: athleticRed.withValues(alpha: 0.6),
                          blurRadius: 25,
                          spreadRadius: 5,
                        ),
                        BoxShadow(
                          color: powerBlue.withValues(alpha: 0.4),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: _buildNetworkImage(
                        imageUrl: gymData!['logoImageUrl'] ?? '',
                        fit: BoxFit.cover,
                        placeholder: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [athleticRed, powerBlue],
                            ),
                          ),
                          child: const Icon(
                            Icons.speed,
                            color: brightWhite,
                            size: 40,
                          ),
                        ),
                        errorWidget: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [athleticRed, powerBlue],
                            ),
                          ),
                          child: const Icon(
                            Icons.speed,
                            color: brightWhite,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Gym Name with Athletic Style
                  ShaderMask(
                    shaderCallback:
                        (bounds) => LinearGradient(
                          colors: [athleticRed, thunderYellow, energyGreen],
                        ).createShader(bounds),
                    child: Text(
                      gymData!['gymName'] ?? 'ATHLETIC CENTER',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: brightWhite,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 4,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Power Tagline
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          athleticRed.withValues(alpha: 0.9),
                          powerBlue.withValues(alpha: 0.9),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: neonCyan, width: 2),
                    ),
                    child: const Text(
                      "⚡ UNLEASH YOUR ATHLETIC POTENTIAL ⚡",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: brightWhite,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Action buttons in app bar
      actions: [
        IconButton(
          onPressed: () => _makePhoneCall(gymData!['mobile'] ?? ''),
          icon: const Icon(Icons.phone, color: brightWhite),
          style: IconButton.styleFrom(
            backgroundColor: athleticRed.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildPerformanceStats() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [carbonBlack, steelBlue],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: athleticRed.withValues(alpha: 0.3),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "PERFORMANCE METRICS",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: brightWhite,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatCard("2500+", "ATHLETES", athleticRed, Icons.people),
              _buildStatDivider(),
              _buildStatCard("8", "YEARS", thunderYellow, Icons.timeline),
              _buildStatDivider(),
              _buildStatCard(
                "24/7",
                "TRAINING",
                energyGreen,
                Icons.access_time,
              ),
              _buildStatDivider(),
              _buildStatCard(
                "50+",
                "PROGRAMS",
                powerBlue,
                Icons.fitness_center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String number,
    String label,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          ShaderMask(
            shaderCallback:
                (bounds) => LinearGradient(
                  colors: [color, brightWhite],
                ).createShader(bounds),
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: brightWhite,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: lightText,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 60,
      color: brightWhite.withValues(alpha: 0.2),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildActionCards() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: _buildActionCard(
              icon: Icons.location_on,
              title: "VISIT US",
              subtitle: "Find Location",
              gradient: [athleticRed, accentOrange],
              onTap: () {},
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildActionCard(
              icon: Icons.phone,
              title: "CALL NOW",
              subtitle: "Get Started",
              gradient: [energyGreen, neonCyan],
              onTap: () => _makePhoneCall(gymData!['mobile'] ?? ''),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildActionCard(
              icon: Icons.schedule,
              title: "BOOK NOW",
              subtitle: "Reserve Slot",
              gradient: [powerBlue, thunderYellow],
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: brightWhite, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: brightWhite,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 9,
                color: brightWhite,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAthleticAbout() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: brightWhite,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [athleticRed, powerBlue]),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.info, color: brightWhite, size: 24),
              ),
              const SizedBox(width: 16),
              ShaderMask(
                shaderCallback:
                    (bounds) => LinearGradient(
                      colors: [athleticRed, powerBlue],
                    ).createShader(bounds),
                child: const Text(
                  "OUR MISSION",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: brightWhite,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            gymData!['about'] ??
                'Dedicated to pushing athletic performance to new heights. We combine cutting-edge training methods with world-class facilities to help athletes reach their peak potential.',
            style: const TextStyle(
              fontSize: 16,
              color: darkText,
              fontWeight: FontWeight.w400,
              height: 1.7,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingPrograms() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback:
                (bounds) => LinearGradient(
                  colors: [athleticRed, thunderYellow],
                ).createShader(bounds),
            child: const Text(
              "🏋️ TRAINING PROGRAMS",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: brightWhite,
                letterSpacing: 1,
              ),
            ),
          ),

          const SizedBox(height: 20),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.1,
            children: [
              _buildProgramCard(
                title: "STRENGTH\nTRAINING",
                icon: Icons.fitness_center,
                gradient: [athleticRed, accentOrange],
                description: "Build raw power",
              ),
              _buildProgramCard(
                title: "CARDIO\nENDURANCE",
                icon: Icons.directions_run,
                gradient: [energyGreen, neonCyan],
                description: "Boost stamina",
              ),
              _buildProgramCard(
                title: "ATHLETIC\nPERFORMANCE",
                icon: Icons.speed,
                gradient: [powerBlue, thunderYellow],
                description: "Elite training",
              ),
              _buildProgramCard(
                title: "SPORTS\nCONDITIONING",
                icon: Icons.sports,
                gradient: [thunderYellow, eliteGold],
                description: "Sport-specific",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgramCard({
    required String title,
    required IconData icon,
    required List<Color> gradient,
    required String description,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: brightWhite.withValues(alpha: 0.1),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: brightWhite, size: 32),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: brightWhite,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: brightWhite,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipPlans() {
    final packages = (gymData!['packages'] as List<dynamic>?) ?? [];

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback:
                (bounds) => LinearGradient(
                  colors: [powerBlue, energyGreen],
                ).createShader(bounds),
            child: const Text(
              "💪 MEMBERSHIP PLANS",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: brightWhite,
                letterSpacing: 1,
              ),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            "Choose your path to athletic excellence",
            style: TextStyle(
              fontSize: 14,
              color: lightText,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 25),

          ...packages
              .map<Widget>((package) => _buildAthleticMembershipCard(package))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildAthleticMembershipCard(Map<String, dynamic> package) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [carbonBlack, steelBlue.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: athleticRed.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: athleticRed.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    athleticRed.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback:
                                (bounds) => LinearGradient(
                                  colors: [athleticRed, thunderYellow],
                                ).createShader(bounds),
                            child: Text(
                              package['name'] ?? '',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: brightWhite,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (package['description'] != null &&
                              package['description'].toString().isNotEmpty)
                            Text(
                              package['description'],
                              style: const TextStyle(
                                fontSize: 14,
                                color: lightText,
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 20),

                    Column(
                      children: [
                        ShaderMask(
                          shaderCallback:
                              (bounds) => LinearGradient(
                                colors: [energyGreen, neonCyan],
                              ).createShader(bounds),
                          child: Text(
                            package['price'] ?? '',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: brightWhite,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildAthleticButton(
                          text: "START NOW",
                          onPressed:
                              () => _makePhoneCall(gymData!['mobile'] ?? ''),
                          gradient: [athleticRed, accentOrange],
                          isSmall: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingGallery() {
    final galleryImages = (gymData!['galleryImages'] as List<dynamic>?) ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback:
                (bounds) => LinearGradient(
                  colors: [thunderYellow, eliteGold],
                ).createShader(bounds),
            child: const Text(
              "📸 TRAINING GALLERY",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: brightWhite,
                letterSpacing: 1,
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: galleryImages.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _showImageDialog(galleryImages[index]),
                  child: Container(
                    width: 180,
                    margin: const EdgeInsets.only(right: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: athleticRed.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: _buildNetworkImage(
                            imageUrl: galleryImages[index],
                            fit: BoxFit.cover,
                            placeholder: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [carbonBlack, steelBlue],
                                ),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: athleticRed,
                                ),
                              ),
                            ),
                            errorWidget: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [titaniumGray, carbonBlack],
                                ),
                              ),
                              child: const Icon(
                                Icons.broken_image,
                                color: lightText,
                              ),
                            ),
                          ),
                        ),

                        // Overlay gradient
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                carbonBlack.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                        ),

                        // Image counter
                        Positioned(
                          bottom: 15,
                          right: 15,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: athleticRed,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "${index + 1}/${galleryImages.length}",
                              style: const TextStyle(
                                color: brightWhite,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingSchedule() {
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
    final dayNames = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final dayIcons = [
      Icons.speed,
      Icons.trending_up,
      Icons.local_fire_department,
      Icons.flash_on,
      Icons.sports,
      Icons.timer,
      Icons.star,
    ];

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [powerBlue, energyGreen],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: powerBlue.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "⏰ TRAINING SCHEDULE",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: brightWhite,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 20),

          ...List.generate(days.length, (index) {
            final dayTime = openingHours[days[index]] ?? '';
            if (dayTime.isEmpty) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: brightWhite.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: brightWhite.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: brightWhite.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(dayIcons[index], color: brightWhite, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    dayNames[index],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: brightWhite,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: thunderYellow.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      dayTime,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: carbonBlack,
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

  Widget _buildAchievementsSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Awards Section
          if (gymData!['awards'] != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [eliteGold, thunderYellow]),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: eliteGold.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "🏆 ACHIEVEMENTS",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: carbonBlack,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    gymData!['awards'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: carbonBlack,
                      fontWeight: FontWeight.w500,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

          // Social Links
          if (gymData!['socialLinks'] != null) _buildSocialSection(),
        ],
      ),
    );
  }

  Widget _buildSocialSection() {
    final socialLinks = gymData!['socialLinks'] as Map<String, dynamic>;

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: brightWhite,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback:
                (bounds) => LinearGradient(
                  colors: [athleticRed, powerBlue],
                ).createShader(bounds),
            child: const Text(
              "🔗 CONNECT WITH US",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: brightWhite,
                letterSpacing: 1,
              ),
            ),
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
                    gradient: [const Color(0xFF1877F2), powerBlue],
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
                    gradient: [athleticRed, accentOrange],
                  ),
                ),
            ],
          ),

          if (socialLinks['website'] != null) ...[
            const SizedBox(height: 12),
            _buildSocialButton(
              icon: Icons.language,
              label: "Visit Website",
              url: socialLinks['website'],
              gradient: [energyGreen, neonCyan],
              isFullWidth: true,
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
    required List<Color> gradient,
    bool isFullWidth = false,
  }) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Container(
        width: isFullWidth ? double.infinity : null,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Icon(icon, color: brightWhite, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: brightWhite,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalPushCTA() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            carbonBlack,
            athleticRed.withValues(alpha: 0.1),
            powerBlue.withValues(alpha: 0.1),
            energyGreen.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: athleticRed.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: athleticRed.withValues(alpha: 0.3),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [athleticRed, powerBlue, energyGreen],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: athleticRed.withValues(alpha: 0.6),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.flash_on, size: 32, color: brightWhite),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          ShaderMask(
            shaderCallback:
                (bounds) => LinearGradient(
                  colors: [athleticRed, thunderYellow, energyGreen],
                ).createShader(bounds),
            child: const Text(
              "READY TO DOMINATE?",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: brightWhite,
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            "Push your limits. Break your records. Become unstoppable.",
            style: TextStyle(
              fontSize: 14,
              color: lightText,
              fontWeight: FontWeight.w400,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 30),

          Row(
            children: [
              Expanded(
                child: _buildAthleticButton(
                  text: "CALL NOW",
                  onPressed: () => _makePhoneCall(gymData!['mobile'] ?? ''),
                  gradient: [athleticRed, accentOrange],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildAthleticOutlineButton(
                  text: "LEARN MORE",
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [carbonBlack, steelBlue]),
        boxShadow: [
          BoxShadow(
            color: athleticRed.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomNavItem(Icons.home, "Home"),
          _buildBottomNavItem(Icons.fitness_center, "Programs"),
          _buildBottomNavItem(Icons.schedule, "Schedule"),
          _buildBottomNavItem(Icons.person, "Profile"),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: brightWhite, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: lightText,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAthleticFAB() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: FloatingActionButton.extended(
            onPressed: () => _makePhoneCall(gymData!['mobile'] ?? ''),
            backgroundColor: athleticRed,
            icon: const Icon(Icons.phone, color: brightWhite),
            label: const Text(
              "CALL",
              style: TextStyle(
                color: brightWhite,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            elevation: 15,
          ),
        );
      },
    );
  }

  Widget _buildAthleticButton({
    required String text,
    required VoidCallback onPressed,
    required List<Color> gradient,
    bool isSmall = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isSmall ? 12 : 16,
          horizontal: isSmall ? 16 : 24,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(isSmall ? 12 : 15),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isSmall ? 11 : 14,
              fontWeight: FontWeight.w900,
              color: brightWhite,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAthleticOutlineButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: athleticRed, width: 2),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: athleticRed,
              letterSpacing: 1,
            ),
          ),
        ),
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
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: athleticRed.withValues(alpha: 0.3),
                      blurRadius: 25,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: InteractiveViewer(
                    child: _buildNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      placeholder: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [carbonBlack, steelBlue],
                          ),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: athleticRed,
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                      errorWidget: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [titaniumGray, carbonBlack],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: lightText,
                            size: 48,
                          ),
                        ),
                      ),
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
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [titaniumGray, carbonBlack]),
            ),
            child: const Icon(Icons.image_not_supported, color: lightText),
          );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit ?? BoxFit.cover,
      placeholder:
          (context, url) =>
              placeholder ??
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [carbonBlack, steelBlue]),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: athleticRed,
                    strokeWidth: 3,
                  ),
                ),
              ),
      errorWidget:
          (context, url, error) =>
              errorWidget ??
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [titaniumGray, carbonBlack]),
                ),
                child: const Icon(Icons.broken_image, color: lightText),
              ),
    );
  }
}
