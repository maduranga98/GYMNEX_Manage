import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gymnex_manage/core/routes/app_pages.dart';
import 'package:gymnex_manage/core/utils/app_colors.dart';
import 'package:gymnex_manage/core/utils/app_typography.dart';
import 'package:gymnex_manage/widgets/custom_button.dart';

class RegisterController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isLoading = false.obs;
  final agreeToTerms = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    if (!agreeToTerms.value) {
      Get.snackbar(
        'Error',
        'Please agree to the Terms of Service and Privacy Policy.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        borderRadius: 10,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    isLoading.value = true;

    try {
      // Create user with email and password
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      // Add user details to Firestore
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'role': 'user',
        });

        // Update user profile
        await userCredential.user!.updateDisplayName(
          nameController.text.trim(),
        );

        // Navigate to home screen
        Get.offAllNamed(Routes.HOME);

        // Success message
        Get.snackbar(
          'Success',
          'Account created successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          borderRadius: 10,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'The email address is already in use.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid.';
          break;
        default:
          errorMessage =
              'An error occurred during registration. Please try again.';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        borderRadius: 10,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        borderRadius: 10,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUpWithGoogle() async {
    if (!agreeToTerms.value) {
      Get.snackbar(
        'Error',
        'Please agree to the Terms of Service and Privacy Policy.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        borderRadius: 10,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    isLoading.value = true;

    try {
      // Begin interactive sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        isLoading.value = false;
        return;
      }

      // Obtain auth details from request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create new credential for user
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with credential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Add user details to Firestore if new user
      if (userCredential.user != null) {
        // Check if user already exists in Firestore
        DocumentSnapshot userDoc =
            await _firestore
                .collection('users')
                .doc(userCredential.user!.uid)
                .get();

        if (!userDoc.exists) {
          // User is signing up for the first time, add to Firestore
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
                'name': userCredential.user!.displayName,
                'email': userCredential.user!.email,
                'phone': userCredential.user!.phoneNumber ?? '',
                'photoUrl': userCredential.user!.photoURL,
                'createdAt': FieldValue.serverTimestamp(),
                'role': 'user',
              });
        }

        // Navigate to home screen
        Get.offAllNamed(Routes.HOME);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign up with Google. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        borderRadius: 10,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUpWithFacebook() async {
    if (!agreeToTerms.value) {
      Get.snackbar(
        'Error',
        'Please agree to the Terms of Service and Privacy Policy.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        borderRadius: 10,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    isLoading.value = true;

    try {
      // This is a placeholder for Facebook signup
      // You would need to add the facebook_login package
      Get.snackbar(
        'Info',
        'Facebook signup is not implemented yet.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        borderRadius: 10,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign up with Facebook. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        borderRadius: 10,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void showTerms() {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Terms of Service',
                style: AppTypography.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    'By using GYMNEX, you agree to abide by the following terms and conditions...\n\n'
                    '1. User Responsibilities\n'
                    '2. Account Management\n'
                    '3. Privacy and Data Usage\n'
                    '4. Payment and Subscription\n'
                    '5. Intellectual Property\n\n'
                    'Please read the full terms and conditions on our website.',
                    style: AppTypography.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(text: 'OK', height: 48, onPressed: () => Get.back()),
            ],
          ),
        ),
      ),
    );
  }

  void showPrivacyPolicy() {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Privacy Policy',
                style: AppTypography.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    'GYMNEX is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information...\n\n'
                    '1. Information Collection\n'
                    '2. Data Usage\n'
                    '3. Data Storage\n'
                    '4. User Rights\n'
                    '5. Third-Party Services\n\n'
                    'Please read the full privacy policy on our website.',
                    style: AppTypography.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(text: 'OK', height: 48, onPressed: () => Get.back()),
            ],
          ),
        ),
      ),
    );
  }
}
