import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';

import '../../../../qr_hub.dart';
import '../../../infrastructure/app_writer.dart';

class SplashController extends GetxController {
  void goToLoginPage(BuildContext context) {
    Future.delayed(
      const Duration(seconds: 2),
      () async {
        final box = await Hive.openBox<UserId>('UserId');

        if (box.isEmpty) {
          if (!context.mounted) return;
          context.go(RouteNames.loginPage);
        } else {
          final oneItem = box.values.first;
          final session =
              await appwriteService.account.getSession(sessionId: 'current');

          final userId = session.userId;

          if (userId == oneItem.userId) {
            if (!context.mounted) return;
            context.go(RouteNames.homePage);
          }
        }
      },
    );
  }
}
