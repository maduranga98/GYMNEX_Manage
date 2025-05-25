import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Template4 extends StatefulWidget {
  final String? gymId;

  const Template4({super.key, this.gymId});

  @override
  State<Template4> createState() => _Template4State();
}

class _Template4State extends State<Template4> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PageController _pageController = PageController();

  Map<String, dynamic>? gymData;
  bool isLoading = true;
  String? error;
  int currentPage = 0;

  late AnimationController _rippleController;
  late AnimationController _floatController;
  late Animation<double> _rippleAnimation;
  late Animation<double> _floatAnimation;

  // Luxury Wellness Color Scheme - Soft Premium Pastels
  static const Color rosePink = Color(0xFFFFB6C1);
  static const Color lavender = Color(0xFFE6E6FA);
  static const Color champagne = Color(0xFFF7E7CE);
  static const Color mintGreen = Color(0xFFB8E6B8);
  static const Color skyBlue = Color(0xFFB8D4F0);
  static const Color peach = Color(0xFFFFDAB9);
  static const Color cream = Color(0xFFFFFDD0);
  static const Color softGray = Color(0xFFF8F9FA);
  static const Color charcoal = Color(0xFF2C3E50);
  static const Color darkGray = Color(0xFF495057);
  static const Color lightGray = Color(0xFFDEE2E6);
  static const Color white = Color(0xFFFFFFFF);
  static const Color gold = Color(0xFFFFD700);
  static const Color silver = Color(0xFFC0C0C0);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _fetchGymData();
  }

  void _initializeAnimations() {
    _rippleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _floatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeInOut),
    );

    _floatAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _floatController.dispose();
    _pageController.dispose();
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
    return Scaffold(
      backgroundColor: softGray,
      body: _buildBody(),
      floatingActionButton: gymData != null ? _buildLuxuryFAB() : null,
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
          colors: [
            softGray,
            lavender.withValues(alpha: 0.3),
            rosePink.withValues(alpha: 0.2),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _rippleAnimation,
              builder: (context, child) {
                return Container(
                  width: 100 + (_rippleAnimation.value * 20),
                  height: 100 + (_rippleAnimation.value * 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        rosePink.withValues(alpha: 1 - _rippleAnimation.value),
                        lavender.withValues(
                          alpha: 0.5 - _rippleAnimation.value * 0.5,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.spa, size: 40, color: charcoal),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              "Preparing Your Wellness Journey...",
              style: TextStyle(
                fontSize: 16,
                color: charcoal,
                fontWeight: FontWeight.w300,
                letterSpacing: 1,
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
          colors: [softGray, peach.withValues(alpha: 0.2)],
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
                  color: white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: rosePink.withValues(alpha: 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Icon(Icons.cloud_off, size: 48, color: charcoal),
              ),
              const SizedBox(height: 24),
              Text(
                "Connection Interrupted",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: charcoal,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                error ?? "Please check your connection",
                style: TextStyle(
                  fontSize: 14,
                  color: darkGray,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildLuxuryButton(
                text: "Try Again",
                onPressed: _refreshData,
                gradient: [rosePink, lavender],
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
          colors: [softGray, mintGreen.withValues(alpha: 0.2)],
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
                  color: white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: mintGreen.withValues(alpha: 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Icon(Icons.self_improvement, size: 48, color: charcoal),
              ),
              const SizedBox(height: 24),
              Text(
                "No Wellness Centers Found",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: charcoal,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Begin your journey by creating a profile",
                style: TextStyle(
                  fontSize: 14,
                  color: darkGray,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildLuxuryButton(
                text: "Refresh",
                onPressed: _refreshData,
                gradient: [mintGreen, skyBlue],
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
      color: rosePink,
      backgroundColor: white,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Elegant Hero Section
          _buildLuxuryHeroSliver(),

          // Main Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Floating Logo Card
                _buildFloatingLogoCard(),

                // Wellness Quote
                _buildWellnessQuote(),

                // Contact Information
                _buildElegantContact(),

                // About Section
                _buildAboutWellness(),

                // Services Carousel
                _buildServicesCarousel(),

                // Packages Section
                _buildLuxuryPackages(),

                // Gallery Masonry
                if (gymData!['galleryImages'] != null) _buildGalleryMasonry(),

                // Amenities
                _buildAmenities(),

                // Opening Hours
                if (gymData!['openingHours'] != null) _buildElegantHours(),

                // Social & Awards
                _buildSocialAwards(),

                // Final CTA
                _buildWellnessCTA(),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLuxuryHeroSliver() {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Hero Image with Soft Overlay
            _buildNetworkImage(
              imageUrl: gymData!['heroImageUrl'] ?? '',
              fit: BoxFit.cover,
              placeholder: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [lavender, rosePink, champagne],
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: charcoal,
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [lavender, rosePink, champagne],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.spa, size: 80, color: charcoal),
                ),
              ),
            ),

            // Soft Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    white.withValues(alpha: 0.1),
                    white.withValues(alpha: 0.3),
                    white.withValues(alpha: 0.7),
                    white,
                  ],
                ),
              ),
            ),

            // Floating Particles Effect
            AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Positioned(
                  top: 100 + _floatAnimation.value,
                  right: 50,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: rosePink.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),

            AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Positioned(
                  top: 150 - _floatAnimation.value * 0.5,
                  left: 80,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: lavender.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingLogoCard() {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value * 0.3),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: rosePink.withValues(alpha: 0.15),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
                BoxShadow(
                  color: lavender.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: champagne.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
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
                          gradient: LinearGradient(colors: [champagne, peach]),
                        ),
                        child: const Icon(Icons.spa, color: charcoal, size: 32),
                      ),
                      errorWidget: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [champagne, peach]),
                        ),
                        child: const Icon(Icons.spa, color: charcoal, size: 32),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Gym Name
                Text(
                  gymData!['gymName'] ?? 'Wellness Center',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    color: charcoal,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Elegant Divider
                Container(
                  width: 60,
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [rosePink, lavender]),
                  ),
                ),

                const SizedBox(height: 12),

                // Tagline
                Text(
                  "Where Wellness Meets Luxury",
                  style: TextStyle(
                    fontSize: 14,
                    color: darkGray,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWellnessQuote() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            lavender.withValues(alpha: 0.3),
            rosePink.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: rosePink.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.format_quote, size: 32, color: rosePink),
          const SizedBox(height: 16),
          Text(
            "Wellness is not a destination, it's a journey of self-discovery and transformation.",
            style: TextStyle(
              fontSize: 16,
              color: charcoal,
              fontWeight: FontWeight.w300,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            width: 40,
            height: 1,
            color: rosePink.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildElegantContact() {
    return Container(
      margin: const EdgeInsets.all(30),
      child: Row(
        children: [
          Expanded(
            child: _buildContactTile(
              icon: Icons.place,
              title: "Visit Us",
              subtitle: gymData!['address'] ?? 'Our Location',
              gradient: [mintGreen, skyBlue],
              onTap: () {},
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _buildContactTile(
              icon: Icons.phone,
              title: "Call Us",
              subtitle: gymData!['mobile'] ?? 'Our Number',
              gradient: [rosePink, peach],
              onTap: () => _makePhoneCall(gymData!['mobile'] ?? ''),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: white, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: charcoal,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: darkGray,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutWellness() {
    return Container(
      margin: const EdgeInsets.all(30),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: champagne.withValues(alpha: 0.2),
            blurRadius: 30,
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [champagne, gold.withValues(alpha: 0.3)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.self_improvement, color: charcoal, size: 20),
              ),
              const SizedBox(width: 16),
              Text(
                "Our Philosophy",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: charcoal,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            gymData!['about'] ??
                'We believe in holistic wellness that nurtures both body and mind. Our sanctuary offers a premium experience where luxury meets health, creating the perfect environment for your transformation journey.',
            style: TextStyle(
              fontSize: 15,
              color: darkGray,
              fontWeight: FontWeight.w300,
              height: 1.7,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildServicesCarousel() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              "Wellness Services",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: charcoal,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 180,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              itemBuilder: (context, index) {
                final services = [
                  {
                    'icon': Icons.fitness_center,
                    'title': 'Personal\nTraining',
                    'colors': [rosePink, peach],
                  },
                  {
                    'icon': Icons.spa,
                    'title': 'Spa &\nWellness',
                    'colors': [lavender, skyBlue],
                  },
                  {
                    'icon': Icons.pool,
                    'title': 'Aqua\nTherapy',
                    'colors': [skyBlue, mintGreen],
                  },
                  {
                    'icon': Icons.self_improvement,
                    'title': 'Mindfulness\n& Yoga',
                    'colors': [mintGreen, champagne],
                  },
                  {
                    'icon': Icons.restaurant,
                    'title': 'Nutrition\nCoaching',
                    'colors': [champagne, peach],
                  },
                  {
                    'icon': Icons.bedtime,
                    'title': 'Recovery\n& Sleep',
                    'colors': [lavender, rosePink],
                  },
                ];

                return _buildServiceCarouselCard(
                  icon: services[index]['icon'] as IconData,
                  title: services[index]['title'] as String,
                  gradient: services[index]['colors'] as List<Color>,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCarouselCard({
    required IconData icon,
    required String title,
    required List<Color> gradient,
  }) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: white, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: charcoal,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLuxuryPackages() {
    final packages = (gymData!['packages'] as List<dynamic>?) ?? [];

    return Container(
      margin: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Membership Plans",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: charcoal,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "Choose your perfect wellness journey",
            style: TextStyle(
              fontSize: 14,
              color: darkGray,
              fontWeight: FontWeight.w300,
            ),
          ),

          const SizedBox(height: 30),

          ...packages
              .map<Widget>((package) => _buildLuxuryPackageCard(package))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildLuxuryPackageCard(Map<String, dynamic> package) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: champagne.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  champagne.withValues(alpha: 0.3),
                  rosePink.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package['name'] ?? '',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          color: charcoal,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (package['description'] != null &&
                          package['description'].toString().isNotEmpty)
                        Text(
                          package['description'],
                          style: TextStyle(
                            fontSize: 14,
                            color: darkGray,
                            fontWeight: FontWeight.w300,
                            height: 1.5,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      package['price'] ?? '',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w300,
                        color: charcoal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            rosePink.withValues(alpha: 0.3),
                            lavender.withValues(alpha: 0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Premium",
                        style: TextStyle(
                          fontSize: 10,
                          color: charcoal,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Footer Section
          Padding(
            padding: const EdgeInsets.all(30),
            child: _buildLuxuryButton(
              text: "Begin Journey",
              onPressed: () => _makePhoneCall(gymData!['mobile'] ?? ''),
              gradient: [rosePink, lavender],
              isFullWidth: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryMasonry() {
    final galleryImages = (gymData!['galleryImages'] as List<dynamic>?) ?? [];

    return Container(
      margin: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Wellness Gallery",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: charcoal,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 20),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 0.8,
            ),
            itemCount: galleryImages.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _showImageDialog(galleryImages[index]),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: lavender.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
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
                          gradient: LinearGradient(colors: [champagne, peach]),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: charcoal,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [lightGray, softGray],
                          ),
                        ),
                        child: const Icon(Icons.broken_image, color: darkGray),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAmenities() {
    final facilities = gymData!['facilities'];
    if (facilities == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(30),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            skyBlue.withValues(alpha: 0.2),
            mintGreen.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: skyBlue.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      skyBlue.withValues(alpha: 0.3),
                      mintGreen.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.spa, color: charcoal, size: 20),
              ),
              const SizedBox(width: 16),
              Text(
                "Premium Amenities",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: charcoal,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            facilities,
            style: TextStyle(
              fontSize: 15,
              color: darkGray,
              fontWeight: FontWeight.w300,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElegantHours() {
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

    return Container(
      margin: const EdgeInsets.all(30),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: peach.withValues(alpha: 0.15),
            blurRadius: 30,
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      peach.withValues(alpha: 0.3),
                      champagne.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.schedule, color: charcoal, size: 20),
              ),
              const SizedBox(width: 16),
              Text(
                "Opening Hours",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: charcoal,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          ...List.generate(days.length, (index) {
            final dayTime = openingHours[days[index]] ?? '';
            if (dayTime.isEmpty) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: lightGray.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dayNames[index],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: charcoal,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          rosePink.withValues(alpha: 0.2),
                          lavender.withValues(alpha: 0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      dayTime,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: charcoal,
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

  Widget _buildSocialAwards() {
    return Container(
      margin: const EdgeInsets.all(30),
      child: Column(
        children: [
          // Awards Section
          if (gymData!['awards'] != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    gold.withValues(alpha: 0.1),
                    champagne.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: gold.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              gold.withValues(alpha: 0.3),
                              champagne.withValues(alpha: 0.3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.emoji_events,
                          color: charcoal,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "Recognition",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: charcoal,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    gymData!['awards'],
                    style: TextStyle(
                      fontSize: 15,
                      color: darkGray,
                      fontWeight: FontWeight.w300,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

          // Social Links
          if (gymData!['socialLinks'] != null) _buildSocialLinksSection(),
        ],
      ),
    );
  }

  Widget _buildSocialLinksSection() {
    final socialLinks = gymData!['socialLinks'] as Map<String, dynamic>;

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: lavender.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Connect With Us",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: charcoal,
              letterSpacing: 0.5,
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
                    gradient: [
                      const Color(0xFF1877F2).withValues(alpha: 0.8),
                      skyBlue,
                    ],
                  ),
                ),
              if (socialLinks['facebook'] != null &&
                  socialLinks['instagram'] != null)
                const SizedBox(width: 15),
              if (socialLinks['instagram'] != null)
                Expanded(
                  child: _buildSocialButton(
                    icon: Icons.camera_alt,
                    label: "Instagram",
                    url: socialLinks['instagram'],
                    gradient: [rosePink, peach],
                  ),
                ),
            ],
          ),

          if (socialLinks['website'] != null) ...[
            const SizedBox(height: 15),
            _buildSocialButton(
              icon: Icons.language,
              label: "Visit Website",
              url: socialLinks['website'],
              gradient: [mintGreen, skyBlue],
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Icon(icon, color: white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: white,
                fontWeight: FontWeight.w400,
                fontSize: 13,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWellnessCTA() {
    return Container(
      margin: const EdgeInsets.all(30),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            rosePink.withValues(alpha: 0.1),
            lavender.withValues(alpha: 0.1),
            champagne.withValues(alpha: 0.1),
            mintGreen.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: rosePink.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _rippleAnimation,
            builder: (context, child) {
              return Container(
                width: 60 + (_rippleAnimation.value * 10),
                height: 60 + (_rippleAnimation.value * 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      rosePink.withValues(
                        alpha: 0.8 - _rippleAnimation.value * 0.3,
                      ),
                      lavender.withValues(
                        alpha: 0.5 - _rippleAnimation.value * 0.2,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.favorite, size: 24, color: charcoal),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          Text(
            "Begin Your Wellness Journey",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: charcoal,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          Text(
            "Transform your life with our holistic approach to wellness and luxury fitness experiences.",
            style: TextStyle(
              fontSize: 14,
              color: darkGray,
              fontWeight: FontWeight.w300,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 30),

          Row(
            children: [
              Expanded(
                child: _buildLuxuryButton(
                  text: "Contact Us",
                  onPressed: () => _makePhoneCall(gymData!['mobile'] ?? ''),
                  gradient: [rosePink, lavender],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildLuxuryOutlineButton(
                  text: "Learn More",
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLuxuryFAB() {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value * 0.5),
          child: FloatingActionButton(
            onPressed: () => _makePhoneCall(gymData!['mobile'] ?? ''),
            backgroundColor: white,
            elevation: 8,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [rosePink, lavender]),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(Icons.phone, color: white, size: 24),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLuxuryButton({
    required String text,
    required VoidCallback onPressed,
    required List<Color> gradient,
    bool isFullWidth = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: isFullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(25),
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLuxuryOutlineButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: rosePink.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: charcoal,
              letterSpacing: 0.5,
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
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: rosePink.withValues(alpha: 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: InteractiveViewer(
                    child: _buildNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      placeholder: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [champagne, peach]),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: charcoal,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [lightGray, softGray],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: darkGray,
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
              gradient: LinearGradient(colors: [lightGray, softGray]),
            ),
            child: const Icon(Icons.image_not_supported, color: darkGray),
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
                  gradient: LinearGradient(colors: [champagne, peach]),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: charcoal,
                    strokeWidth: 2,
                  ),
                ),
              ),
      errorWidget:
          (context, url, error) =>
              errorWidget ??
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [lightGray, softGray]),
                ),
                child: const Icon(Icons.broken_image, color: darkGray),
              ),
    );
  }
}
