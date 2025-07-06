import 'package:blocker/app/services/vpn_service.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VPNService>(
      () => VPNService(),
    );
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
  }
}
