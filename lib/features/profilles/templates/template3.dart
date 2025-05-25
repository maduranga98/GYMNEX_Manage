import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Template3 extends StatefulWidget {
  final String? gymId;

  const Template3({super.key, this.gymId});

  @override
  State<Template3> createState() => _Template3State();
}

class _Template3State extends State<Template3> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? gymData;
  bool isLoading = true;
  String? error;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Vibrant Energy Color Scheme - Neon Fitness Theme
  static const Color energyOrange = Color(0xFFFF6B35);
  static const Color electricBlue = Color(0xFF004CFF);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color hotPink = Color(0xFFFF1B8D);
  static const Color deepPurple = Color(0xFF6B35FF);
  static const Color darkCharcoal = Color(0xFF1A1A1A);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFF666666);
  static const Color white = Color(0xFFFFFFFF);
  static const Color yellow = Color(0xFFFFD700);
  static const Color lime = Color(0xFF32CD32);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fetchGymData();
  }

  @override
  void dispose() {
    _animationController.dispose();
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

      _animationController.forward();
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
      backgroundColor: darkCharcoal,
      body: _buildBody(),
      floatingActionButton: gymData != null ? _buildFloatingButtons() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
          colors: [darkCharcoal, energyOrange.withValues(alpha: 0.1)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [energyOrange, hotPink]),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: white, strokeWidth: 3),
              ),
            ),
            const SizedBox(height: 24),
            ShaderMask(
              shaderCallback:
                  (bounds) => LinearGradient(
                    colors: [energyOrange, electricBlue],
                  ).createShader(bounds),
              child: const Text(
                "LOADING POWER...",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: white,
                  letterSpacing: 2,
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
          colors: [darkCharcoal, hotPink.withValues(alpha: 0.1)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [hotPink, energyOrange]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.error_outline, size: 64, color: white),
              ),
              const SizedBox(height: 24),
              ShaderMask(
                shaderCallback:
                    (bounds) => LinearGradient(
                      colors: [hotPink, energyOrange],
                    ).createShader(bounds),
                child: const Text(
                  "WORKOUT INTERRUPTED",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: white,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                error ?? "Something went wrong",
                style: const TextStyle(fontSize: 14, color: mediumGray),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildEnergyButton(
                text: "TRY AGAIN",
                onPressed: _refreshData,
                gradient: [neonGreen, lime],
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
          colors: [darkCharcoal, deepPurple.withValues(alpha: 0.1)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [deepPurple, electricBlue]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.fitness_center, size: 64, color: white),
              ),
              const SizedBox(height: 24),
              ShaderMask(
                shaderCallback:
                    (bounds) => LinearGradient(
                      colors: [deepPurple, electricBlue],
                    ).createShader(bounds),
                child: const Text(
                  "NO GYMS FOUND",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: white,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Time to create your fitness empire",
                style: TextStyle(fontSize: 14, color: mediumGray),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildEnergyButton(
                text: "REFRESH",
                onPressed: _refreshData,
                gradient: [energyOrange, yellow],
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
      color: energyOrange,
      backgroundColor: darkCharcoal,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Hero Section
          _buildHeroSliver(),

          // Main Content
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        // Energy Stats Row
                        _buildEnergyStats(),

                        // Quick Contact
                        _buildQuickContact(),

                        // About Section
                        _buildAboutSection(),

                        // Services Grid
                        _buildServicesGrid(),

                        // Packages
                        _buildPackagesSection(),

                        // Gallery
                        if (gymData!['galleryImages'] != null)
                          _buildGallerySection(),

                        // Opening Hours
                        if (gymData!['openingHours'] != null)
                          _buildOpeningHoursSection(),

                        // Awards & Social
                        _buildAwardsAndSocial(),

                        // Call to Action
                        _buildFinalCTA(),

                        const SizedBox(height: 100), // Bottom padding for FAB
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

  Widget _buildHeroSliver() {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: darkCharcoal,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Hero Image
            _buildNetworkImage(
              imageUrl: gymData!['heroImageUrl'] ?? '',
              fit: BoxFit.cover,
              placeholder: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [energyOrange, hotPink, electricBlue],
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: white),
                ),
              ),
              errorWidget: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [energyOrange, hotPink, electricBlue],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.fitness_center, size: 80, color: white),
                ),
              ),
            ),

            // Animated Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    darkCharcoal.withValues(alpha: 0.4),
                    darkCharcoal.withValues(alpha: 0.8),
                    darkCharcoal,
                  ],
                ),
              ),
            ),

            // Floating Logo and Title
            Positioned(
              bottom: 60,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  // Logo with Glow Effect
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: energyOrange.withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
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
                              colors: [energyOrange, hotPink],
                            ),
                          ),
                          child: const Icon(
                            Icons.fitness_center,
                            color: white,
                            size: 40,
                          ),
                        ),
                        errorWidget: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [energyOrange, hotPink],
                            ),
                          ),
                          child: const Icon(
                            Icons.fitness_center,
                            color: white,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Gym Name with Neon Effect
                  ShaderMask(
                    shaderCallback:
                        (bounds) => LinearGradient(
                          colors: [energyOrange, yellow, neonGreen],
                        ).createShader(bounds),
                    child: Text(
                      gymData!['gymName'] ?? 'POWER GYM',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: white,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Animated Tagline
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          hotPink.withValues(alpha: 0.8),
                          electricBlue.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "🔥 UNLEASH YOUR POTENTIAL 🔥",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: white,
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
    );
  }

  Widget _buildEnergyStats() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [energyOrange, hotPink],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: energyOrange.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem("1000+", "MEMBERS", neonGreen),
          _buildStatDivider(),
          _buildStatItem("5", "YEARS", yellow),
          _buildStatDivider(),
          _buildStatItem("24/7", "ACCESS", electricBlue),
        ],
      ),
    );
  }

  Widget _buildStatItem(String number, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          ShaderMask(
            shaderCallback:
                (bounds) =>
                    LinearGradient(colors: [color, white]).createShader(bounds),
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: white,
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
      height: 40,
      color: white.withValues(alpha: 0.3),
      margin: const EdgeInsets.symmetric(horizontal: 10),
    );
  }

  Widget _buildQuickContact() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: _buildContactCard(
              icon: Icons.location_on,
              title: "LOCATION",
              subtitle: gymData!['address'] ?? 'Address',
              gradient: [electricBlue, deepPurple],
              onTap: () {},
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildContactCard(
              icon: Icons.phone,
              title: "CALL NOW",
              subtitle: gymData!['mobile'] ?? 'Phone',
              gradient: [neonGreen, lime],
              onTap: () => _makePhoneCall(gymData!['mobile'] ?? ''),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
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
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: white, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: white,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: white),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: white,
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [energyOrange, hotPink]),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.info, color: white, size: 24),
              ),
              const SizedBox(width: 16),
              ShaderMask(
                shaderCallback:
                    (bounds) => LinearGradient(
                      colors: [energyOrange, hotPink],
                    ).createShader(bounds),
                child: const Text(
                  "ABOUT US",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            gymData!['about'] ??
                'Transform your body, transform your life. Join our community of fitness warriors and unleash your true potential.',
            style: const TextStyle(
              fontSize: 16,
              color: darkCharcoal,
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildServicesGrid() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback:
                (bounds) => LinearGradient(
                  colors: [electricBlue, deepPurple],
                ).createShader(bounds),
            child: const Text(
              "💪 POWER SERVICES",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: white,
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
              _buildServiceCard(
                icon: "🏋️",
                title: "WEIGHT\nTRAINING",
                gradient: [energyOrange, yellow],
              ),
              _buildServiceCard(
                icon: "🏃",
                title: "CARDIO\nZONE",
                gradient: [hotPink, deepPurple],
              ),
              _buildServiceCard(
                icon: "🧘",
                title: "YOGA &\nPILATES",
                gradient: [neonGreen, lime],
              ),
              _buildServiceCard(
                icon: "🥊",
                title: "BOXING &\nMMA",
                gradient: [electricBlue, deepPurple],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required String icon,
    required String title,
    required List<Color> gradient,
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
            color: gradient.first.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: white,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPackagesSection() {
    final packages = (gymData!['packages'] as List<dynamic>?) ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback:
                (bounds) => LinearGradient(
                  colors: [hotPink, electricBlue],
                ).createShader(bounds),
            child: const Text(
              "🔥 POWER PACKAGES",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: white,
                letterSpacing: 1,
              ),
            ),
          ),

          const SizedBox(height: 20),

          ...packages
              .map<Widget>((package) => _buildEnergyPackageCard(package))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildEnergyPackageCard(Map<String, dynamic> package) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [darkCharcoal, energyOrange.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: energyOrange.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: energyOrange.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
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
                              colors: [energyOrange, yellow],
                            ).createShader(bounds),
                        child: Text(
                          package['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (package['description'] != null &&
                          package['description'].isNotEmpty)
                        Text(
                          package['description'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: mediumGray,
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
                            colors: [neonGreen, lime],
                          ).createShader(bounds),
                      child: Text(
                        package['price'] ?? '',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildEnergyButton(
                      text: "JOIN NOW",
                      onPressed: () => _makePhoneCall(gymData!['mobile'] ?? ''),
                      gradient: [hotPink, deepPurple],
                      isSmall: true,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGallerySection() {
    final galleryImages = (gymData!['galleryImages'] as List<dynamic>?) ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback:
                (bounds) => LinearGradient(
                  colors: [deepPurple, electricBlue],
                ).createShader(bounds),
            child: const Text(
              "📸 ENERGY GALLERY",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: white,
                letterSpacing: 1,
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: galleryImages.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _showImageDialog(galleryImages[index]),
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: energyOrange.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: _buildNetworkImage(
                        imageUrl: galleryImages[index],
                        fit: BoxFit.cover,
                        placeholder: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [energyOrange, hotPink],
                            ),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(color: white),
                          ),
                        ),
                        errorWidget: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [mediumGray, darkCharcoal],
                            ),
                          ),
                          child: const Icon(Icons.broken_image, color: white),
                        ),
                      ),
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

  Widget _buildOpeningHoursSection() {
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
    final dayEmojis = ['💪', '🔥', '⚡', '💥', '🚀', '🎯', '✨'];

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [electricBlue, deepPurple],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: electricBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "⏰ POWER HOURS",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: white,
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
                color: white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Text(dayEmojis[index], style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Text(
                    dayNames[index],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: white,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: neonGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      dayTime,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: white,
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

  Widget _buildAwardsAndSocial() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Awards Section
          if (gymData!['awards'] != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [yellow, energyOrange]),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: yellow.withValues(alpha: 0.3),
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
                      color: darkCharcoal,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    gymData!['awards'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: darkCharcoal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Social Links
          if (gymData!['socialLinks'] != null) _buildSocialLinksRow(),
        ],
      ),
    );
  }

  Widget _buildSocialLinksRow() {
    final socialLinks = gymData!['socialLinks'] as Map<String, dynamic>;

    return Row(
      children: [
        if (socialLinks['facebook'] != null)
          Expanded(
            child: _buildSocialCard(
              icon: Icons.facebook,
              label: "FACEBOOK",
              url: socialLinks['facebook'],
              gradient: [const Color(0xFF1877F2), electricBlue],
            ),
          ),
        if (socialLinks['facebook'] != null && socialLinks['instagram'] != null)
          const SizedBox(width: 15),
        if (socialLinks['instagram'] != null)
          Expanded(
            child: _buildSocialCard(
              icon: Icons.camera_alt,
              label: "INSTAGRAM",
              url: socialLinks['instagram'],
              gradient: [hotPink, deepPurple],
            ),
          ),
        if (socialLinks['website'] != null) ...[
          if (socialLinks['facebook'] != null ||
              socialLinks['instagram'] != null)
            const SizedBox(width: 15),
          Expanded(
            child: _buildSocialCard(
              icon: Icons.language,
              label: "WEBSITE",
              url: socialLinks['website'],
              gradient: [neonGreen, lime],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSocialCard({
    required IconData icon,
    required String label,
    required String url,
    required List<Color> gradient,
  }) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: white, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalCTA() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [darkCharcoal, energyOrange, hotPink, electricBlue],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: energyOrange.withValues(alpha: 0.4),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text("🚀", style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text(
            "READY TO IGNITE\nYOUR FITNESS?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: white,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            "Join the energy revolution and transform your life today!",
            style: TextStyle(fontSize: 14, color: white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildEnergyButton(
                  text: "CALL NOW",
                  onPressed: () => _makePhoneCall(gymData!['mobile'] ?? ''),
                  gradient: [neonGreen, lime],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildEnergyButton(
                  text: "GET INFO",
                  onPressed: () {},
                  gradient: [yellow, energyOrange],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: () => _makePhoneCall(gymData!['mobile'] ?? ''),
          backgroundColor: neonGreen,
          child: const Icon(Icons.phone, color: darkCharcoal),
          heroTag: "phone",
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          onPressed: () {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
            );
          },
          backgroundColor: energyOrange,
          child: const Icon(Icons.keyboard_arrow_up, color: white),
          heroTag: "scroll",
        ),
      ],
    );
  }

  Widget _buildEnergyButton({
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
          borderRadius: BorderRadius.circular(isSmall ? 15 : 20),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isSmall ? 12 : 14,
              fontWeight: FontWeight.w900,
              color: white,
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
                      color: energyOrange.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
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
                            colors: [energyOrange, hotPink],
                          ),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(color: white),
                        ),
                      ),
                      errorWidget: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [darkCharcoal, mediumGray],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: white,
                            size: 64,
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
              gradient: LinearGradient(colors: [mediumGray, darkCharcoal]),
            ),
            child: const Icon(Icons.image_not_supported, color: white),
          );
    }

    return Image.network(
      imageUrl,
      fit: fit ?? BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return placeholder ??
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [energyOrange, hotPink]),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                  color: white,
                  strokeWidth: 2,
                ),
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ??
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [mediumGray, darkCharcoal]),
              ),
              child: const Icon(Icons.broken_image, color: white),
            );
      },
    );
  }
}
