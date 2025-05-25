import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:gymnex_manage/core/models/member.dart';
import 'package:gymnex_manage/core/services/member_service.dart';
import 'package:gymnex_manage/core/utils/app_colors.dart';
import 'package:gymnex_manage/core/utils/app_typography.dart';
import 'package:gymnex_manage/features/members/member_detail.dart';
import 'package:gymnex_manage/features/members/member_edit.dart';
import 'package:gymnex_manage/widgets/custom_button.dart';
import 'package:intl/intl.dart';

class MemberList extends StatefulWidget {
  const MemberList({Key? key}) : super(key: key);

  @override
  State<MemberList> createState() => _MemberListState();
}

class _MemberListState extends State<MemberList>
    with SingleTickerProviderStateMixin {
  final MemberService _memberService = MemberService();
  final TextEditingController _searchController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Filter states
  String _searchQuery = '';
  String _statusFilter = 'all';
  String _typeFilter = 'all';
  bool _isExpiring = false;

  // UI states
  bool _isLoading = false;
  bool _isError = false;
  String _errorMessage = '';
  bool _isGridView = false;

  // Animation controller for filter panel
  late AnimationController _animationController;
  final List<String> _memberTypes = [
    'all',
    'Regular',
    'VIP',
    'Student',
    'Senior',
    'Staff',
  ];
  final List<String> _memberStatus = ['all', 'active', 'inactive', 'expired'];

  // For selecting multiple members
  late List<String> _selectedMemberIds = [];
  bool _isMultiSelectMode = false;

  // ScrollController for implementing infinite scroll
  final ScrollController _scrollController = ScrollController();
  bool _hasMoreData = true;
  int _pageSize = 15;
  DocumentSnapshot? _lastDocument;
  List<Member> _members = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Listen to scroll for implementing pagination
    _scrollController.addListener(_scrollListener);

    // Initial data load
    _fetchInitialMembers();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMoreData) {
      _fetchMoreMembers();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Initial data fetch
  Future<void> _fetchInitialMembers() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      final businessId = await _getCurrentBusinessId();
      if (businessId != null) {
        final QuerySnapshot snapshot =
            await _buildQuery(businessId).limit(_pageSize).get();

        if (snapshot.docs.isEmpty) {
          setState(() {
            _members = [];
            _isLoading = false;
            _hasMoreData = false;
          });
          return;
        }

        _members =
            snapshot.docs.map((doc) => Member.fromFirestore(doc)).toList();

        // Set last document for pagination
        _lastDocument = snapshot.docs.last;

        setState(() {
          _isLoading = false;
          _hasMoreData = snapshot.docs.length == _pageSize;
        });
      } else {
        setState(() {
          _isLoading = false;
          _isError = true;
          _errorMessage = 'Failed to get current business';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = 'Error loading members: ${e.toString()}';
      });
    }
  }

  // Fetch more data for pagination
  Future<void> _fetchMoreMembers() async {
    if (!_hasMoreData || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final businessId = await _getCurrentBusinessId();
      if (businessId != null && _lastDocument != null) {
        final QuerySnapshot snapshot =
            await _buildQuery(
              businessId,
            ).startAfterDocument(_lastDocument!).limit(_pageSize).get();

        if (snapshot.docs.isEmpty) {
          setState(() {
            _isLoading = false;
            _hasMoreData = false;
          });
          return;
        }

        final newMembers =
            snapshot.docs.map((doc) => Member.fromFirestore(doc)).toList();

        // Update last document for next pagination query
        _lastDocument = snapshot.docs.last;

        setState(() {
          _members.addAll(newMembers);
          _isLoading = false;
          _hasMoreData = snapshot.docs.length == _pageSize;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasMoreData = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = 'Error loading more members: ${e.toString()}';
      });
    }
  }

  // Get current business ID from Firebase
  Future<String?> _getCurrentBusinessId() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      if (userDoc.exists && userDoc.data() != null) {
        return userDoc.data()!['selectedBusiness'] as String?;
      }

      return userId; // Fallback to user ID if no selected business
    } catch (e) {
      print('Error getting current business: $e');
      return null;
    }
  }

  // Build Firestore query based on filters
  Query _buildQuery(String businessId) {
    Query query = FirebaseFirestore.instance
        .collection('members')
        .where('businessId', isEqualTo: businessId);

    // Apply status filter
    if (_statusFilter != 'all') {
      query = query.where('status', isEqualTo: _statusFilter);
    }

    // Apply member type filter
    if (_typeFilter != 'all') {
      query = query.where('type', isEqualTo: _typeFilter);
    }

    // Apply expiring membership filter
    if (_isExpiring) {
      // Get date for 2 weeks from now
      final twoWeeksFromNow = DateTime.now().add(const Duration(days: 14));
      query = query
          .where(
            'membershipExpiryDate',
            isLessThan: Timestamp.fromDate(twoWeeksFromNow),
          )
          .where(
            'membershipExpiryDate',
            isGreaterThan: Timestamp.fromDate(DateTime.now()),
          );
    }

    // Apply search if we have a query
    // Note: This is a simplified approach for search. For production,
    // consider using a more sophisticated solution like Algolia or ElasticSearch
    if (_searchQuery.isNotEmpty) {
      // This will get documents where name starts with search query
      // Firebase doesn't support contains or regex natively
      query = query
          .where(
            'searchName',
            isGreaterThanOrEqualTo: _searchQuery.toLowerCase(),
          )
          .where(
            'searchName',
            isLessThanOrEqualTo: _searchQuery.toLowerCase() + '\uf8ff',
          );
    }

    // Sort by name by default
    return query.orderBy(_searchQuery.isNotEmpty ? 'searchName' : 'name');
  }

  // Handle refresh - pull to refresh
  Future<void> _handleRefresh() async {
    _lastDocument = null;
    await _fetchInitialMembers();
    return;
  }

  void _applySearch(String value) {
    setState(() {
      _searchQuery = value.trim();
      _lastDocument = null; // Reset pagination
    });
    _fetchInitialMembers();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _lastDocument = null; // Reset pagination
    });
    _fetchInitialMembers();
  }

  void _toggleStatusFilter(String status) {
    setState(() {
      _statusFilter = status;
      _lastDocument = null; // Reset pagination
    });
    _fetchInitialMembers();
    _animationController.reverse(); // Close filter panel
  }

  void _toggleTypeFilter(String type) {
    setState(() {
      _typeFilter = type;
      _lastDocument = null; // Reset pagination
    });
    _fetchInitialMembers();
    _animationController.reverse(); // Close filter panel
  }

  void _toggleExpiringFilter(bool value) {
    setState(() {
      _isExpiring = value;
      _lastDocument = null; // Reset pagination
    });
    _fetchInitialMembers();
  }

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  void _toggleMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedMemberIds.clear();
      }
    });
  }

  void _toggleSelectMember(String memberId) {
    setState(() {
      if (_selectedMemberIds.contains(memberId)) {
        _selectedMemberIds.remove(memberId);
      } else {
        _selectedMemberIds.add(memberId);
      }
    });
  }

  void _navigateToAddMember() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberEditScreen(isNewMember: true),
      ),
    );

    if (result == true) {
      _handleRefresh();
    }
  }

  void _navigateToMemberDetail(Member member) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberDetailScreen(member: member),
      ),
    );

    if (result == true) {
      _handleRefresh();
    }
  }

  void _handleBulkAction() {
    if (_selectedMemberIds.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Actions for ${_selectedMemberIds.length} Member${_selectedMemberIds.length > 1 ? 's' : ''}',
                  style: AppTypography.h3,
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'MARK AS ACTIVE',
                  icon: Icons.check_circle_outline,
                  onPressed: () {
                    _bulkUpdateStatus('active');
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: 'MARK AS INACTIVE',
                  icon: Icons.cancel_outlined,
                  onPressed: () {
                    _bulkUpdateStatus('inactive');
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: 'DELETE MEMBERS',
                  icon: Icons.delete_outline,
                  backgroundColor: Colors.red,
                  onPressed: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation();
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _bulkUpdateStatus(String status) {
    // Show loading dialog
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.cardBackground,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Updating members...', style: AppTypography.bodyMedium),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    // Process updates
    Future.wait(
          _selectedMemberIds.map(
            (id) => _memberService.updateMemberStatus(id, status),
          ),
        )
        .then((_) {
          Get.back(); // Close dialog
          Get.snackbar(
            'Success',
            'Updated ${_selectedMemberIds.length} member${_selectedMemberIds.length > 1 ? 's' : ''}',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          setState(() {
            _selectedMemberIds.clear();
            _isMultiSelectMode = false;
          });
          _handleRefresh();
        })
        .catchError((error) {
          Get.back(); // Close dialog
          Get.snackbar(
            'Error',
            'Failed to update members: $error',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        });
  }

  void _showDeleteConfirmation() {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
              const SizedBox(height: 16),
              Text(
                'Delete ${_selectedMemberIds.length} Member${_selectedMemberIds.length > 1 ? 's' : ''}?',
                style: AppTypography.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'This action cannot be undone. All member data will be permanently removed.',
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.secondaryText,
                        side: BorderSide(color: AppColors.divider),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('CANCEL'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _bulkDeleteMembers();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('DELETE'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _bulkDeleteMembers() {
    // Show loading dialog
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.cardBackground,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Deleting members...', style: AppTypography.bodyMedium),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    // Process deletes
    Future.wait(_selectedMemberIds.map((id) => _memberService.deleteMember(id)))
        .then((_) {
          Get.back(); // Close dialog
          Get.snackbar(
            'Success',
            'Deleted ${_selectedMemberIds.length} member${_selectedMemberIds.length > 1 ? 's' : ''}',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          setState(() {
            _selectedMemberIds.clear();
            _isMultiSelectMode = false;
          });
          _handleRefresh();
        })
        .catchError((error) {
          Get.back(); // Close dialog
          Get.snackbar(
            'Error',
            'Failed to delete members: $error',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text("Members", style: AppTypography.h3),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          if (_isMultiSelectMode) ...[
            IconButton(
              icon: Icon(Icons.select_all, color: AppColors.primaryText),
              onPressed: () {
                setState(() {
                  if (_selectedMemberIds.length == _members.length) {
                    _selectedMemberIds.clear();
                  } else {
                    _selectedMemberIds = _members.map((m) => m.id).toList();
                  }
                });
              },
              tooltip: 'Select All',
            ),
            IconButton(
              icon: Icon(Icons.close, color: AppColors.primaryText),
              onPressed: _toggleMultiSelectMode,
              tooltip: 'Cancel Selection',
            ),
          ] else ...[
            IconButton(
              icon: Icon(
                _isGridView ? Icons.view_list : Icons.grid_view,
                color: AppColors.primaryText,
              ),
              onPressed: _toggleViewMode,
              tooltip: _isGridView ? 'List View' : 'Grid View',
            ),
            IconButton(
              icon: Icon(
                _animationController.value == 0 ? Icons.tune : Icons.close,
                color: AppColors.primaryText,
              ),
              onPressed: () {
                if (_animationController.value == 0) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }
              },
              tooltip: 'Filters',
            ),
            IconButton(
              icon: Icon(Icons.select_all, color: AppColors.primaryText),
              onPressed: _toggleMultiSelectMode,
              tooltip: 'Select Multiple',
            ),
          ],
        ],
      ),
      floatingActionButton:
          _isMultiSelectMode
              ? FloatingActionButton.extended(
                onPressed: _handleBulkAction,
                backgroundColor: AppColors.accentColor,
                icon: Icon(Icons.check),
                label: Text('${_selectedMemberIds.length} SELECTED'),
              )
              : FloatingActionButton(
                onPressed: _navigateToAddMember,
                backgroundColor: AppColors.accentColor,
                child: Icon(Icons.add),
              ),
      body: Column(
        children: [
          // Search and filter section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: AppTypography.inputText,
                      decoration: InputDecoration(
                        hintText: 'Search members...',
                        hintStyle: AppTypography.inputHint,
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.mutedText,
                        ),
                        suffixIcon:
                            _searchQuery.isNotEmpty
                                ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: AppColors.mutedText,
                                  ),
                                  onPressed: _clearSearch,
                                )
                                : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 8,
                        ),
                      ),
                      onSubmitted: _applySearch,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter chips (animated panel)
          SizeTransition(
            sizeFactor: _animationController,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                border: Border(
                  bottom: BorderSide(color: AppColors.divider, width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filters',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _statusFilter = 'all';
                            _typeFilter = 'all';
                            _isExpiring = false;
                            _lastDocument = null;
                          });
                          _fetchInitialMembers();
                          _animationController.reverse();
                        },
                        child: Text(
                          'Reset All',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Status filters
                  Text('Status', style: AppTypography.bodySmall),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          _memberStatus.map((status) {
                            final isSelected = _statusFilter == status;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(
                                  status == 'all'
                                      ? 'All Status'
                                      : status.substring(0, 1).toUpperCase() +
                                          status.substring(1),
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : AppColors.primaryText,
                                    fontSize: 12,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (_) => _toggleStatusFilter(status),
                                backgroundColor: AppColors.background,
                                selectedColor: AppColors.accentColor,
                                checkmarkColor: Colors.white,
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Member type filters
                  Text('Membership Type', style: AppTypography.bodySmall),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          _memberTypes.map((type) {
                            final isSelected = _typeFilter == type;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(
                                  type == 'all' ? 'All Types' : type,
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : AppColors.primaryText,
                                    fontSize: 12,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (_) => _toggleTypeFilter(type),
                                backgroundColor: AppColors.background,
                                selectedColor: AppColors.accentColor,
                                checkmarkColor: Colors.white,
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Expiring soon toggle
                  SwitchListTile(
                    title: Text(
                      'Expiring in next 14 days',
                      style: AppTypography.bodyMedium,
                    ),
                    value: _isExpiring,
                    onChanged: _toggleExpiringFilter,
                    activeColor: AppColors.accentColor,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ],
              ),
            ),
          ),

          // Applied filters chips
          if (_statusFilter != 'all' || _typeFilter != 'all' || _isExpiring)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (_statusFilter != 'all')
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(
                          label: Text(
                            'Status: ${_statusFilter.substring(0, 1).toUpperCase() + _statusFilter.substring(1)}',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                          backgroundColor: AppColors.accentColor,
                          deleteIcon: Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                          onDeleted: () {
                            setState(() {
                              _statusFilter = 'all';
                              _lastDocument = null;
                            });
                            _fetchInitialMembers();
                          },
                        ),
                      ),
                    if (_typeFilter != 'all')
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(
                          label: Text(
                            'Type: $_typeFilter',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                          backgroundColor: AppColors.accentColor,
                          deleteIcon: Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                          onDeleted: () {
                            setState(() {
                              _typeFilter = 'all';
                              _lastDocument = null;
                            });
                            _fetchInitialMembers();
                          },
                        ),
                      ),
                    if (_isExpiring)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(
                          label: Text(
                            'Expiring Soon',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                          backgroundColor: AppColors.accentColor,
                          deleteIcon: Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                          onDeleted: () {
                            setState(() {
                              _isExpiring = false;
                              _lastDocument = null;
                            });
                            _fetchInitialMembers();
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // Member count summary
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_members.length} member${_members.length != 1 ? 's' : ''}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.mutedText,
                  ),
                ),
                if (_hasMoreData && !_isLoading)
                  TextButton(
                    onPressed: _fetchMoreMembers,
                    child: Text(
                      'Load More',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.accentColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Content area
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _members.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.accentColor),
      );
    }

    if (_isError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                'Error Loading Members',
                style: AppTypography.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'RETRY',
                icon: Icons.refresh,
                onPressed: _handleRefresh,
              ),
            ],
          ),
        ),
      );
    }

    if (_members.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 64, color: AppColors.mutedText),
              const SizedBox(height: 16),
              Text(
                'No Members Found',
                style: AppTypography.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isNotEmpty ||
                        _statusFilter != 'all' ||
                        _typeFilter != 'all' ||
                        _isExpiring
                    ? 'Try changing your search or filters'
                    : 'Add your first member to get started',
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'ADD MEMBER',
                icon: Icons.add,
                onPressed: _navigateToAddMember,
              ),
            ],
          ),
        ),
      );
    }

    // Use RefreshIndicator for pull-to-refresh
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppColors.accentColor,
      child: Stack(
        children: [
          // Main content list/grid
          _isGridView ? _buildGridView() : _buildListView(),

          // Loading indicator at the bottom for pagination
          if (_isLoading && _members.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                alignment: Alignment.center,
                color: AppColors.scaffoldBackground.withValues(alpha: 0.8),
                child: CircularProgressIndicator(
                  color: AppColors.accentColor,
                  strokeWidth: 3,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        80,
      ), // Bottom padding for FAB
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _members.length,
      itemBuilder: (context, index) {
        final member = _members[index];
        return _buildMemberListItem(member);
      },
    );
  }

  Widget _buildMemberAvatar(Member member, {double size = 50}) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.primaryColor,
      backgroundImage:
          member.photoUrl.isNotEmpty ? NetworkImage(member.photoUrl) : null,
      child:
          member.photoUrl.isEmpty
              ? Text(
                member.name.isNotEmpty ? member.name[0].toUpperCase() : "?",
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.bold,
                ),
              )
              : null,
    );
  }

  Widget _buildMemberListItem(Member member) {
    final isSelected = _selectedMemberIds.contains(member.id);
    final membershipStatus = _getMembershipStatusInfo(member);

    return Dismissible(
      key: Key('member_${member.id}'),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: Colors.green,
        child: Icon(Icons.check_circle, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Mark as active
          await _memberService.updateMemberStatus(member.id, 'active');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${member.name} marked as active')),
          );
          _handleRefresh();
          return false;
        } else {
          // Show delete confirmation
          return await _confirmDelete(member);
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color:
            isSelected
                ? AppColors.accentColor.withValues(alpha: 0.1)
                : AppColors.cardBackground,
        child: InkWell(
          onTap:
              _isMultiSelectMode
                  ? () => _toggleSelectMember(member.id)
                  : () => _navigateToMemberDetail(member),
          onLongPress: () {
            if (!_isMultiSelectMode) {
              _toggleMultiSelectMode();
              _toggleSelectMember(member.id);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Selection indicator or avatar
                _isMultiSelectMode
                    ? Checkbox(
                      value: isSelected,
                      onChanged: (_) => _toggleSelectMember(member.id),
                      activeColor: AppColors.accentColor,
                    )
                    : _buildMemberAvatar(member),
                const SizedBox(width: 12),

                // Member info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        member.email,
                        style: AppTypography.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: membershipStatus.color.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              member.status.toUpperCase(),
                              style: AppTypography.caption.copyWith(
                                color: membershipStatus.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            member.membershipPlan,
                            style: AppTypography.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Expiry info
                if (member.membershipExpiryDate != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Expires',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.mutedText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat(
                          'MMM d, yyyy',
                        ).format(member.membershipExpiryDate!),
                        style: AppTypography.bodySmall.copyWith(
                          color: membershipStatus.expiryColor,
                          fontWeight:
                              member.status == 'expired'
                                  ? FontWeight.bold
                                  : null,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberGridItem(Member member) {
    final isSelected = _selectedMemberIds.contains(member.id);
    final membershipStatus = _getMembershipStatusInfo(member);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color:
          isSelected
              ? AppColors.accentColor.withValues(alpha: 0.1)
              : AppColors.cardBackground,
      child: InkWell(
        onTap:
            _isMultiSelectMode
                ? () => _toggleSelectMember(member.id)
                : () => _navigateToMemberDetail(member),
        onLongPress: () {
          if (!_isMultiSelectMode) {
            _toggleMultiSelectMode();
            _toggleSelectMember(member.id);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Selection checkbox overlay
              Stack(
                alignment: Alignment.topRight,
                children: [
                  // Avatar
                  Center(
                    child: SizedBox(
                      width: 70,
                      height: 70,
                      child: _buildMemberAvatar(member, size: 70),
                    ),
                  ),

                  // Selection indicator
                  if (_isMultiSelectMode)
                    Container(
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppColors.accentColor
                                : AppColors.cardBackground,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              isSelected
                                  ? AppColors.accentColor
                                  : AppColors.divider,
                        ),
                      ),
                      child: Icon(
                        isSelected ? Icons.check : Icons.circle_outlined,
                        size: 20,
                        color: isSelected ? Colors.white : AppColors.mutedText,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Name with ellipsis
              Text(
                member.name,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 4),

              // Email with ellipsis
              Text(
                member.email,
                style: AppTypography.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Membership info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: membershipStatus.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  member.status.toUpperCase(),
                  style: AppTypography.caption.copyWith(
                    color: membershipStatus.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Membership plan
              Text(
                member.membershipPlan,
                style: AppTypography.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),

              // Expiry date if available
              if (member.membershipExpiryDate != null) ...[
                const Spacer(),
                Text(
                  'Expires ${DateFormat('MMM d, yyyy').format(member.membershipExpiryDate!)}',
                  style: AppTypography.caption.copyWith(
                    color: membershipStatus.expiryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        80,
      ), // Bottom padding for FAB
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: _members.length,
      itemBuilder: (context, index) {
        final member = _members[index];
        return _buildMemberGridItem(member);
      },
    );
  }

  StatusInfo _getMembershipStatusInfo(Member member) {
    switch (member.status) {
      case 'active':
        return StatusInfo(
          color: Colors.green,
          expiryColor:
              _isExpiringWithin(member.membershipExpiryDate, 14)
                  ? Colors.orange
                  : AppColors.secondaryText,
        );
      case 'inactive':
        return StatusInfo(
          color: Colors.grey,
          expiryColor: AppColors.secondaryText,
        );
      case 'expired':
        return StatusInfo(color: Colors.red, expiryColor: Colors.red);
      default:
        return StatusInfo(
          color: AppColors.accentColor,
          expiryColor: AppColors.secondaryText,
        );
    }
  }

  bool _isExpiringWithin(DateTime? date, int days) {
    if (date == null) return false;
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    return difference >= 0 && difference <= days;
  }

  Future<bool> _confirmDelete(Member member) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                backgroundColor: AppColors.cardBackground,
                title: Text('Delete Member', style: AppTypography.h3),
                content: Text(
                  'Are you sure you want to delete ${member.name}? This cannot be undone.',
                  style: AppTypography.bodyMedium,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'CANCEL',
                      style: TextStyle(color: AppColors.secondaryText),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('DELETE', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
        ) ??
        false;
  }
}

class StatusInfo {
  final Color color;
  final Color expiryColor;

  StatusInfo({required this.color, required this.expiryColor});
}
