import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:gymnex_manage/core/routes/app_pages.dart';
import 'package:gymnex_manage/core/utils/app_colors.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Your App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        primaryColor: AppColors.primaryColor,
        colorScheme: ColorScheme.dark(
          primary: AppColors.accentColor,
          secondary: AppColors.secondaryColor,
          surface: AppColors.cardBackground,
          error: AppColors.error,
        ),
        dividerColor: AppColors.divider,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.accentColor,
          selectionColor: AppColors.accentColor.withValues(alpha: 0.3),
          selectionHandleColor: AppColors.accentColor,
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: AppColors.inputBackground,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.inputBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.focusedBorder),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
