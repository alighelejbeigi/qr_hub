import 'package:get/get.dart';

import '../controller/setting_controller.dart';

class SettingBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => SettingController(),
    );
  }
}
