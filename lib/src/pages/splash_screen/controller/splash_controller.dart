import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../qr_hub.dart';

class SplashController extends GetxController {
  void goToLoginPage(BuildContext context) {
    Future.delayed(
      const Duration(seconds: 3),
      () {
        context.push(RouteNames.homePage);
      },
    );
  }
}
