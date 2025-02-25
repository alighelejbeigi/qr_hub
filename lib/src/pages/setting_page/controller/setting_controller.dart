import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';

import '../../../../qr_hub.dart';
import '../../../infrastructure/app_writer.dart';

class SettingController extends GetxController {


  Future<void> singout(BuildContext context) async {
    try {
      final box = await Hive.openBox<UserId>('UserId');

      if (box.isEmpty) return;

      final oneItem = box.values.first;
      final session =
      await appwriteService.account.getSession(sessionId: 'current');
      final userId = session.userId;

      if (userId == oneItem.userId) {
        if (!context.mounted) return;
        context.go(RouteNames.loginPage);
        box.clear();
        appwriteService.account.deleteSession(sessionId: 'current');
      }
    } catch (e) {
      debugPrint('Error in onInit: $e');
    }
  }

}
