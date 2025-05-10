import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymnex_manage/core/controllers/splash_controller.dart';
import 'package:gymnex_manage/core/utils/app_colors.dart';
import 'package:gymnex_manage/core/utils/app_typography.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Center(
        child: Obx(
          () => AnimatedOpacity(
            opacity: controller.fadeValue.value,
            duration: const Duration(milliseconds: 1000),
            child: AnimatedScale(
              scale: controller.scaleValue.value,
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo
                  Container(
                    width: 100,
                    height: 100,
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

                  const SizedBox(height: 24),

                  // App Name
                  Text("GYMNEX", style: AppTypography.h1),

                  const SizedBox(height: 8),

                  // Tagline
                  Text(
                    "Your Gym. Your Rules. Our Tech.",
                    style: AppTypography.bodyMedium,
                  ),

                  const SizedBox(height: 48),

                  // Loading Indicator
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.accentColor,
                      ),
                      strokeWidth: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
