import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gymnex_manage/core/routes/app_pages.dart';

class SplashController extends GetxController {
  final RxDouble fadeValue = 0.0.obs;
  final RxDouble scaleValue = 0.8.obs;

  @override
  void onInit() {
    super.onInit();
    _startAnimations();
    _initializeApp();
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      fadeValue.value = 1.0;
      scaleValue.value = 1.0;
    });
  }

  Future<void> _initializeApp() async {
    // Short delay to allow animations to play
    await Future.delayed(const Duration(milliseconds: 2200));

    try {
      // Check if Firebase is initialized
      if (!Firebase.apps.isNotEmpty) {
        await Firebase.initializeApp();
      }

      // Check if user is already signed in
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // User is signed in, navigate to home screen
        Get.offAllNamed(Routes.HOME);
      } else {
        // User is not signed in, navigate to login screen
        Get.offAllNamed(Routes.LOGIN);
      }
    } catch (e) {
      // Handle initialization error
      Get.snackbar(
        'Error',
        'Failed to initialize app. Please check your connection.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }
}
