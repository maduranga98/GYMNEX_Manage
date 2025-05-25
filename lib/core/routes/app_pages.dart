// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';
import 'package:gymnex_manage/core/bindings/home_binding.dart';
import 'package:gymnex_manage/core/bindings/login_binding.dart';
import 'package:gymnex_manage/core/bindings/register_binding.dart';
import 'package:gymnex_manage/core/bindings/splash_binding.dart';
import 'package:gymnex_manage/features/business/gym_setup_screen.dart';
import 'package:gymnex_manage/features/home/home_page_temp.dart';
import 'package:gymnex_manage/features/home/home_screen.dart';
import 'package:gymnex_manage/features/auth/login_screen.dart';
import 'package:gymnex_manage/features/auth/register_screen.dart';
import 'package:gymnex_manage/features/screens/splash_screen.dart'
    show SplashScreen;
part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => RegisterScreen(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(name: Routes.GYM_SETUP, page: () => GymSetupScreen()),
  ];
}
