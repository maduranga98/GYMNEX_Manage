import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymnex_manage/core/controllers/login_controller.dart';
import 'package:gymnex_manage/core/routes/app_pages.dart';
import 'package:gymnex_manage/core/utils/app_colors.dart';
import 'package:gymnex_manage/core/utils/app_typography.dart';
import 'package:gymnex_manage/widgets/custom_button.dart';
import 'package:gymnex_manage/widgets/custom_text_field.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),

                  // Logo and App Name
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: AppColors.primaryGradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Image.asset("assets/gymnex.png"),
                        ),
                        const SizedBox(height: 16),
                        Text("GYMNEX", style: AppTypography.h2),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Welcome Text
                  Text("Welcome Back", style: AppTypography.h2),

                  const SizedBox(height: 8),

                  Text("Sign in to continue", style: AppTypography.bodyMedium),

                  const SizedBox(height: 32),

                  // Email Field
                  Form(
                    key: controller.formKey,
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: controller.emailController,
                          hintText: 'Email',
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
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => controller.forgotPassword(),
                            child: Text(
                              "Forgot Password?",
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.accentColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Login Button
                        Obx(
                          () => CustomButton(
                            text: "LOGIN",
                            isLoading: controller.isLoading.value,
                            onPressed:
                                controller.isLoading.value
                                    ? null
                                    : () => controller.login(),
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

                  // Social Login Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                        icon: Icons.g_mobiledata,
                        onTap: () => controller.signInWithGoogle(),
                      ),
                      const SizedBox(width: 24),
                      _buildSocialButton(
                        icon: Icons.facebook,
                        onTap: () => controller.signInWithFacebook(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Register Link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppTypography.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: () => Get.toNamed(Routes.REGISTER),
                          child: Text(
                            "Register",
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
