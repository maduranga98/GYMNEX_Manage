import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymnex_manage/core/controllers/register_controller.dart';
import 'package:gymnex_manage/core/routes/app_pages.dart';
import 'package:gymnex_manage/core/utils/app_colors.dart';
import 'package:gymnex_manage/core/utils/app_typography.dart';
import 'package:gymnex_manage/widgets/custom_button.dart';
import 'package:gymnex_manage/widgets/custom_text_field.dart';

class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.primaryText,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Header
                  Text("Create Account", style: AppTypography.h2),

                  const SizedBox(height: 8),

                  Text("Join GYMNEX today", style: AppTypography.bodyMedium),

                  const SizedBox(height: 32),

                  // Registration Form
                  Form(
                    key: controller.formKey,
                    child: Column(
                      children: [
                        // Full Name Field
                        CustomTextField(
                          controller: controller.nameController,
                          hintText: 'Full Name',
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: AppColors.mutedText,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Email Field
                        CustomTextField(
                          controller: controller.emailController,
                          hintText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: AppColors.mutedText,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!GetUtils.isEmail(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Phone Field
                        CustomTextField(
                          controller: controller.phoneController,
                          hintText: 'Phone Number',
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icon(
                            Icons.phone_outlined,
                            color: AppColors.mutedText,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            // You can add more validation here
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Password Field
                        Obx(
                          () => CustomTextField(
                            controller: controller.passwordController,
                            hintText: 'Password',
                            obscureText: !controller.isPasswordVisible.value,
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: AppColors.mutedText,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isPasswordVisible.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.mutedText,
                              ),
                              onPressed: controller.togglePasswordVisibility,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Confirm Password Field
                        Obx(
                          () => CustomTextField(
                            controller: controller.confirmPasswordController,
                            hintText: 'Confirm Password',
                            obscureText:
                                !controller.isConfirmPasswordVisible.value,
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: AppColors.mutedText,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isConfirmPasswordVisible.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.mutedText,
                              ),
                              onPressed:
                                  controller.toggleConfirmPasswordVisibility,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != controller.passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Terms and Conditions
                        Row(
                          children: [
                            Obx(
                              () => Checkbox(
                                value: controller.agreeToTerms.value,
                                onChanged:
                                    (value) =>
                                        controller.agreeToTerms.value = value!,
                                fillColor: WidgetStateProperty.resolveWith((
                                  states,
                                ) {
                                  if (states.contains(WidgetState.selected)) {
                                    return AppColors.accentColor;
                                  }
                                  return Colors.transparent;
                                }),
                                checkColor: Colors.white,
                                side: BorderSide(
                                  color: AppColors.mutedText,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: AppTypography.bodySmall,
                                  children: [
                                    const TextSpan(text: 'I agree to the '),
                                    WidgetSpan(
                                      child: GestureDetector(
                                        onTap: () => controller.showTerms(),
                                        child: Text(
                                          'Terms of Service',
                                          style: AppTypography.bodySmall
                                              .copyWith(
                                                color: AppColors.accentColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const TextSpan(text: ' and '),
                                    WidgetSpan(
                                      child: GestureDetector(
                                        onTap:
                                            () =>
                                                controller.showPrivacyPolicy(),
                                        child: Text(
                                          'Privacy Policy',
                                          style: AppTypography.bodySmall
                                              .copyWith(
                                                color: AppColors.accentColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Register Button
                        Obx(
                          () => CustomButton(
                            text: "REGISTER",
                            isLoading: controller.isLoading.value,
                            onPressed:
                                controller.isLoading.value ||
                                        !controller.agreeToTerms.value
                                    ? null
                                    : () => controller.register(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // OR Divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: AppColors.divider, thickness: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text("OR", style: AppTypography.bodySmall),
                      ),
                      Expanded(
                        child: Divider(color: AppColors.divider, thickness: 1),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Social Registration Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                        icon: Icons.g_mobiledata,
                        onTap: () => controller.signUpWithGoogle(),
                      ),
                      const SizedBox(width: 24),
                      _buildSocialButton(
                        icon: Icons.facebook,
                        onTap: () => controller.signUpWithFacebook(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Login Link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: AppTypography.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: () => Get.offNamed(Routes.LOGIN),
                          child: Text(
                            "Login",
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.accentColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider, width: 1),
        ),
        child: Icon(icon, size: 30, color: AppColors.primaryText),
      ),
    );
  }
}
