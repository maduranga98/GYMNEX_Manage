import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymnex_manage/core/models/check_in.dart';
import 'package:gymnex_manage/core/models/member.dart';
import 'package:gymnex_manage/core/routes/app_pages.dart';
import 'package:gymnex_manage/core/services/auth_service.dart';
import 'package:gymnex_manage/core/services/member_service.dart';

class HomeController extends GetxController {
  final authService = Get.find<AuthService>();
  final memberService = Get.find<MemberService>();

  final currentIndex = 0.obs;
  final userName = "Admin".obs;
  final userEmail = "admin@gymnex.com".obs;
  final userPhotoUrl = "".obs;

  final activeMembersCount = 0.obs;
  final todayCheckInsCount = 0.obs;
  final expiringThisWeekCount = 0.obs;
  final revenueThisMonth = 0.0.obs;

  final recentCheckIns = <CheckIn>[].obs;
  final expiringMemberships = <Member>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserInfo();
    fetchDashboardData();
  }

  void fetchUserInfo() {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        userName.value = currentUser.displayName ?? "Admin";
        userEmail.value = currentUser.email ?? "admin@gymnex.com";
        userPhotoUrl.value = currentUser.photoURL ?? "";
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user info: $e");
      }
    }
  }

  Future<void> fetchDashboardData() async {
    // Simulating data fetch
  }

  Future<void> refreshData() async {
    await fetchDashboardData();
  }

  void changePage(int index) {
    currentIndex.value = index;
  }

  void navigateTo(int index) {
    currentIndex.value = index;
    Get.back(); // Close drawer
  }

  void viewNotifications() {
    // Implement notifications view
  }

  void openSettings() {
    // Implement settings view
  }

  void viewAllMembers() {
    // Navigate to all members screen
  }

  void viewCheckIns() {
    // Navigate to check-ins screen
  }

  void viewExpiringMemberships() {
    // Navigate to expiring memberships screen
  }

  void viewFinancials() {
    // Navigate to financials screen
  }

  void viewAllCheckIns() {
    // Navigate to all check-ins screen
  }

  void viewAllExpiringMemberships() {
    // Navigate to all expiring memberships screen
  }

  void viewMemberDetails(String memberId) {
    // Navigate to member details screen
  }

  void scanForCheckIn() {
    // Implement QR code scanning for check in
  }

  void addNewMember() {
    // Navigate to add new member screen
  }

  void managePayments() {
    // Navigate to payments screen
  }

  void viewReports() {
    // Navigate to reports screen
  }

  void showQuickActions() {
    // Show quick actions bottom sheet
  }

  void openHelp() {
    // Open help & support screen
  }

  void logout() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Get.theme.cardColor,
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              authService.signOut();
              Get.offAllNamed(Routes.LOGIN);
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}
