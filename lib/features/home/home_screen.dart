import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymnex_manage/core/routes/app_pages.dart';
import 'package:gymnex_manage/core/utils/app_colors.dart';
import 'package:gymnex_manage/core/utils/app_typography.dart';
import 'package:gymnex_manage/features/members/member%20list/member_list.dart';
import 'package:gymnex_manage/widgets/custom_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;

  // Business data
  String _businessName = "GYMNEX";
  String _businessLogo = "";
  List<Map<String, dynamic>> _userBusinesses = [];
  String? _selectedBusinessId;

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadUserBusinesses();
  }

  Future<void> _loadUserBusinesses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // First, get the user's businesses
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null && userData['businesses'] != null) {
          final List<dynamic> businessIds = userData['businesses'];

          // Store the selected business ID
          _selectedBusinessId =
              userData['selectedBusiness'] ?? businessIds.first;

          // Fetch details for each business
          for (var businessId in businessIds) {
            final businessDoc =
                await _firestore.collection('gyms').doc(businessId).get();

            if (businessDoc.exists) {
              final businessData = businessDoc.data();
              if (businessData != null) {
                _userBusinesses.add({
                  'id': businessId,
                  'name': businessData['name'] ?? 'Unnamed Gym',
                  'logoUrl': businessData['logoUrl'] ?? '',
                });

                // If this is the selected business, update the main variables
                if (businessId == _selectedBusinessId) {
                  _businessName = businessData['name'] ?? 'GYMNEX';
                  _businessLogo = businessData['logoUrl'] ?? '';
                }
              }
            }
          }
        } else {
          // User has no businesses yet, we'll load from gyms collection
          final gymDoc = await _firestore.collection('gyms').doc(userId).get();

          if (gymDoc.exists) {
            final gymData = gymDoc.data();
            if (gymData != null) {
              _businessName = gymData['name'] ?? 'GYMNEX';
              _businessLogo = gymData['logoUrl'] ?? '';

              _userBusinesses.add({
                'id': userId,
                'name': _businessName,
                'logoUrl': _businessLogo,
              });

              _selectedBusinessId = userId;

              // Update the user document with this business
              await _firestore.collection('users').doc(userId).set({
                'businesses': [userId],
                'selectedBusiness': userId,
              }, SetOptions(merge: true));
            }
          }
        }
      } else {
        // User document doesn't exist yet, check if they have a gym
        final gymDoc = await _firestore.collection('gyms').doc(userId).get();

        if (gymDoc.exists) {
          final gymData = gymDoc.data();
          if (gymData != null) {
            _businessName = gymData['name'] ?? 'GYMNEX';
            _businessLogo = gymData['logoUrl'] ?? '';

            _userBusinesses.add({
              'id': userId,
              'name': _businessName,
              'logoUrl': _businessLogo,
            });

            _selectedBusinessId = userId;

            // Create user document with this business
            await _firestore.collection('users').doc(userId).set({
              'businesses': [userId],
              'selectedBusiness': userId,
            });
          }
        }
      }
    } catch (e) {
      print('Error loading businesses: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _switchBusiness(String businessId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Update selected business in Firestore
      await _firestore.collection('users').doc(userId).update({
        'selectedBusiness': businessId,
      });

      // Find the business details
      final business = _userBusinesses.firstWhere(
        (business) => business['id'] == businessId,
        orElse: () => {'name': 'GYMNEX', 'logoUrl': ''},
      );

      setState(() {
        _selectedBusinessId = businessId;
        _businessName = business['name'];
        _businessLogo = business['logoUrl'];
      });

      // Close the drawer
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Switched to ${business['name']}')),
      );
    } catch (e) {
      print('Error switching business: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error switching business: ${e.toString()}')),
      );
    }
  }

  void _addNewBusiness() {
    // Create a new gym document first
    _createNewGymDocument().then((newBusinessId) {
      if (newBusinessId != null) {
        // Navigate to gym setup screen with this new ID
        Get.toNamed(Routes.GYM_SETUP, arguments: {'businessId': newBusinessId});
      }
    });
  }

  Future<String?> _createNewGymDocument() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      // Create a new document with a unique ID
      final docRef = _firestore.collection('gyms').doc();
      final newBusinessId = docRef.id;

      // Initialize with basic data
      await docRef.set({
        'name': 'New Gym',
        'owner': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Add this business to the user's businesses
      await _firestore.collection('users').doc(userId).update({
        'businesses': FieldValue.arrayUnion([newBusinessId]),
      });

      // Add to local list
      _userBusinesses.add({
        'id': newBusinessId,
        'name': 'New Gym',
        'logoUrl': '',
      });

      return newBusinessId;
    } catch (e) {
      print('Error creating new business: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating new business: ${e.toString()}')),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_businessLogo.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  _businessLogo,
                  height: 32,
                  width: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 32,
                      width: 32,
                      color: AppColors.cardBackground,
                      child: Icon(
                        Icons.fitness_center,
                        size: 18,
                        color: AppColors.mutedText,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(_businessName, style: AppTypography.h3),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: AppColors.primaryText,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: AppColors.primaryText),
            onPressed:
                () => Get.toNamed(
                  Routes.GYM_SETUP,
                  arguments: {'businessId': _selectedBusinessId},
                ),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(color: AppColors.accentColor),
              )
              : SafeArea(child: _buildPage(_currentIndex)),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    image:
                        _businessLogo.isNotEmpty
                            ? DecorationImage(
                              image: NetworkImage(_businessLogo),
                              fit: BoxFit.cover,
                            )
                            : null,
                  ),
                  child:
                      _businessLogo.isEmpty
                          ? Icon(
                            Icons.fitness_center,
                            size: 30,
                            color: AppColors.primaryText,
                          )
                          : null,
                ),
                const SizedBox(height: 12),
                Text(
                  _businessName,
                  style: AppTypography.h3.copyWith(color: Colors.white),
                ),
                Text(
                  _auth.currentUser?.email ?? "admin@gymnex.com",
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Business switcher section
          if (_userBusinesses.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                "YOUR BUSINESSES",
                style: AppTypography.label.copyWith(color: AppColors.mutedText),
              ),
            ),

            ..._userBusinesses.map(
              (business) => ListTile(
                selected: business['id'] == _selectedBusinessId,
                selectedTileColor: AppColors.accentColor.withOpacity(0.1),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.cardBackground,
                    image:
                        business['logoUrl'].isNotEmpty
                            ? DecorationImage(
                              image: NetworkImage(business['logoUrl']),
                              fit: BoxFit.cover,
                            )
                            : null,
                  ),
                  child:
                      business['logoUrl'].isEmpty
                          ? Icon(
                            Icons.fitness_center,
                            size: 20,
                            color: AppColors.mutedText,
                          )
                          : null,
                ),
                title: Text(
                  business['name'],
                  style: AppTypography.bodyMedium.copyWith(
                    color:
                        business['id'] == _selectedBusinessId
                            ? AppColors.accentColor
                            : AppColors.primaryText,
                    fontWeight:
                        business['id'] == _selectedBusinessId
                            ? FontWeight.w600
                            : FontWeight.normal,
                  ),
                ),
                onTap: () => _switchBusiness(business['id']),
              ),
            ),
          ],

          // Add new business option (always show)
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.accentColor.withOpacity(0.1),
                border: Border.all(color: AppColors.accentColor, width: 1),
              ),
              child: Icon(Icons.add, size: 20, color: AppColors.accentColor),
            ),
            title: Text(
              "Add New Business",
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.accentColor,
              ),
            ),
            onTap: _addNewBusiness,
          ),

          Divider(color: AppColors.divider),

          // Navigation items
          _buildDrawerItem(
            icon: Icons.dashboard_outlined,
            title: "Dashboard",
            onTap: () {
              _changePage(0);
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.people_alt_outlined,
            title: "Members",
            onTap: () {
              _changePage(1);
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.fitness_center_outlined,
            title: "Classes",
            onTap: () {
              _changePage(2);
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.payment_outlined,
            title: "Payments",
            onTap: () {
              _changePage(3);
              Navigator.pop(context);
            },
          ),
          Divider(color: AppColors.divider),
          _buildDrawerItem(
            icon: Icons.settings_outlined,
            title: "Gym Setup",
            onTap: () {
              Navigator.pop(context);
              Get.toNamed(
                Routes.GYM_SETUP,
                arguments: {'businessId': _selectedBusinessId},
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.help_outline,
            title: "Help & Support",
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.logout,
            title: "Logout",
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryText),
      title: Text(title, style: AppTypography.bodyMedium),
      onTap: onTap,
    );
  }

  void _changePage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _changePage,
      backgroundColor: AppColors.cardBackground,
      selectedItemColor: AppColors.accentColor,
      unselectedItemColor: AppColors.mutedText,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: "Dashboard",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_alt_outlined),
          activeIcon: Icon(Icons.people_alt),
          label: "Members",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fitness_center_outlined),
          activeIcon: Icon(Icons.fitness_center),
          label: "Classes",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.payment_outlined),
          activeIcon: Icon(Icons.payment),
          label: "Payments",
        ),
      ],
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return _buildDashboardPage();
      case 1:
        return MemberList();

      case 2:
        return _buildPlaceholderPage("Classes", Icons.fitness_center_outlined);
      case 3:
        return _buildPlaceholderPage("Payments", Icons.payment_outlined);
      default:
        return _buildDashboardPage();
    }
  }

  Widget _buildDashboardPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cardBackground,
                border: Border.all(color: AppColors.accentColor, width: 2),
                image:
                    _businessLogo.isNotEmpty
                        ? DecorationImage(
                          image: NetworkImage(_businessLogo),
                          fit: BoxFit.cover,
                        )
                        : null,
              ),
              child:
                  _businessLogo.isEmpty
                      ? Icon(
                        Icons.fitness_center,
                        size: 50,
                        color: AppColors.accentColor,
                      )
                      : null,
            ),
            const SizedBox(height: 24),
            Text(
              "Welcome to $_businessName",
              style: AppTypography.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "Your gym management system is ready to use.",
              style: AppTypography.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            CustomButton(
              text: "GYM SETUP",
              icon: Icons.settings,
              onPressed:
                  () => Get.toNamed(
                    Routes.GYM_SETUP,
                    arguments: {'businessId': _selectedBusinessId},
                  ),
            ),
            const SizedBox(height: 20),
            Text(
              "Configure your gym's information and settings",
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderPage(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppColors.mutedText),
          const SizedBox(height: 24),
          Text("$title Coming Soon", style: AppTypography.h2),
          const SizedBox(height: 16),
          Text(
            "This feature is under development",
            style: AppTypography.bodyLarge,
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: Text("Logout", style: AppTypography.h3),
            content: Text(
              "Are you sure you want to logout?",
              style: AppTypography.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: AppTypography.button.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _auth.signOut();
                  Get.offAllNamed(Routes.LOGIN);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentColor,
                  foregroundColor: Colors.white,
                ),
                child: Text("Logout"),
              ),
            ],
          ),
    );
  }
}
