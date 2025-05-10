import 'package:get/get.dart';
import 'package:gymnex_manage/core/controllers/home_controller.dart';
import 'package:gymnex_manage/core/services/auth_service.dart';
import 'package:gymnex_manage/core/services/member_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthService>(AuthService());
    Get.put<MemberService>(MemberService());
    Get.put<HomeController>(HomeController());
  }
}
