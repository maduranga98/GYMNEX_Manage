import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymnex_manage/core/utils/app_colors.dart';
import 'package:gymnex_manage/core/utils/app_typography.dart';
import 'package:gymnex_manage/core/data/services_data.dart';

class ServicesSelectionPage extends StatefulWidget {
  final String? gymId; // Pass gym ID to update existing profile
  final List<int>? initialSelectedIndices; // Add this parameter

  const ServicesSelectionPage({
    super.key,
    this.gymId,
    this.initialSelectedIndices,
  });

  @override
  State<ServicesSelectionPage> createState() => _ServicesSelectionPageState();
}

class _ServicesSelectionPageState extends State<ServicesSelectionPage>
    with TickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<int> _selectedServiceIndices = [];
  bool _isLoading = false;
  bool _isSaving = false;

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Use the services from utility class
  static List<Map<String, dynamic>> get availableServices =>
      ServicesData.availableServices;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Initialize with provided indices if any
    if (widget.initialSelectedIndices != null) {
      _selectedServiceIndices = List.from(widget.initialSelectedIndices!);
    }

    _loadSelectedServices();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _loadSelectedServices() async {
    if (widget.gymId == null) {
      _startAnimations();
      return;
    }

    // If we already have initial indices, skip loading from database
    if (widget.initialSelectedIndices != null) {
      _startAnimations();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final doc =
          await _firestore.collection('gym_profiles').doc(widget.gymId).get();

      if (doc.exists) {
        final data = doc.data();
        final serviceIndices = data?['serviceIndices'] as List<dynamic>?;

        if (serviceIndices != null) {
          setState(() {
            _selectedServiceIndices = serviceIndices.cast<int>();
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load services: $e');
    } finally {
      setState(() => _isLoading = false);
      _startAnimations();
    }
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleController.forward();
    });
  }

  Future<void> _saveSelectedServices() async {
    // If no gymId provided, just return the indices (for setup form)
    if (widget.gymId == null) {
      if (mounted) {
        Navigator.pop(context, _selectedServiceIndices);
      }
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _firestore.collection('gym_profiles').doc(widget.gymId).update({
        'serviceIndices': _selectedServiceIndices,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Services updated successfully!',
              style: AppTypography.bodyMedium,
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );

        Navigator.pop(context, _selectedServiceIndices);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to save services: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _toggleService(int index) {
    setState(() {
      if (_selectedServiceIndices.contains(index)) {
        _selectedServiceIndices.remove(index);
      } else {
        _selectedServiceIndices.add(index);
      }
      // Keep the list sorted for consistency
      _selectedServiceIndices.sort();
    });
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

  // Static method to get services by indices (delegate to utility class)
  static List<Map<String, dynamic>> getServicesByIndices(List<int> indices) {
    return ServicesData.getServicesByIndices(indices);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text("SELECT SERVICES", style: AppTypography.h3),
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primaryText),
        actions: [
          if (_selectedServiceIndices.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_selectedServiceIndices.length}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.buttonText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading ? _buildLoadingState() : _buildServicesGrid(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.accentColor,
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text("Loading services...", style: AppTypography.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildServicesGrid() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  children: [
                    // Header Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.inputBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.accentColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.fitness_center,
                                  color: AppColors.accentColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Choose Your Services",
                                style: AppTypography.h3.copyWith(fontSize: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Select all the services and amenities your gym offers to help members know what to expect.",
                            style: AppTypography.bodyMedium,
                          ),
                          if (_selectedServiceIndices.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.accentColor.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                "${_selectedServiceIndices.length} service${_selectedServiceIndices.length == 1 ? '' : 's'} selected",
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.accentColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Services Grid
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.0,
                              ),
                          itemCount: availableServices.length,
                          itemBuilder: (context, index) {
                            final service = availableServices[index];
                            final isSelected = _selectedServiceIndices.contains(
                              index,
                            );

                            return GestureDetector(
                              onTap: () => _toggleService(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? AppColors.accentColor.withOpacity(
                                            0.1,
                                          )
                                          : AppColors.cardBackground,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? AppColors.accentColor
                                            : AppColors.inputBorder,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow:
                                      isSelected
                                          ? [
                                            BoxShadow(
                                              color: AppColors.accentColor
                                                  .withOpacity(0.2),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                          : [],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Service icon
                                    Text(
                                      service['icon'],
                                      style: const TextStyle(fontSize: 32),
                                    ),

                                    const SizedBox(height: 12),

                                    // Service name
                                    Text(
                                      service['name'],
                                      style: AppTypography.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color:
                                            isSelected
                                                ? AppColors.accentColor
                                                : AppColors.primaryText,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    const SizedBox(height: 8),

                                    // Service description
                                    Expanded(
                                      child: Text(
                                        service['description'],
                                        style: AppTypography.bodySmall.copyWith(
                                          color:
                                              isSelected
                                                  ? AppColors.secondaryText
                                                  : AppColors.mutedText,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                    // Selection indicator
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? AppColors.accentColor
                                                : Colors.transparent,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? AppColors.accentColor
                                                  : AppColors.mutedText,
                                          width: 2,
                                        ),
                                      ),
                                      child:
                                          isSelected
                                              ? const Icon(
                                                Icons.check,
                                                color: AppColors.buttonText,
                                                size: 16,
                                              )
                                              : null,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(top: BorderSide(color: AppColors.inputBorder)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selected services chips (if any)
            if (_selectedServiceIndices.isNotEmpty) ...[
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedServiceIndices.length,
                  itemBuilder: (context, index) {
                    final serviceIndex = _selectedServiceIndices[index];
                    final service = availableServices[serviceIndex];

                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.accentColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            service['icon'],
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            service['name'],
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.accentColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _toggleService(serviceIndex),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: AppColors.accentColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Action buttons
            Row(
              children: [
                // Clear all button
                if (_selectedServiceIndices.isNotEmpty)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedServiceIndices.clear();
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.mutedText,
                        side: BorderSide(color: AppColors.inputBorder),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text("CLEAR ALL", style: AppTypography.button),
                    ),
                  ),

                if (_selectedServiceIndices.isNotEmpty)
                  const SizedBox(width: 16),

                // Save button
                Expanded(
                  flex: _selectedServiceIndices.isNotEmpty ? 2 : 1,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors:
                            _selectedServiceIndices.isNotEmpty
                                ? [AppColors.accentColor, Color(0xFFB91C3C)]
                                : [AppColors.mutedText, AppColors.mutedText],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed:
                          _selectedServiceIndices.isNotEmpty && !_isSaving
                              ? _saveSelectedServices
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          _isSaving
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: AppColors.buttonText,
                                  strokeWidth: 2,
                                ),
                              )
                              : Text(
                                _selectedServiceIndices.isNotEmpty
                                    ? "SAVE SERVICES (${_selectedServiceIndices.length})"
                                    : "SELECT SERVICES",
                                style: AppTypography.button,
                              ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
