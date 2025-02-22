import 'package:appwrite/appwrite.dart' show Account, Client, ID;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';

import '../../../../qr_hub.dart';
import '../../../infrastructure/app_writer.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();
  final RxBool isLogin = true.obs;
  final RxBool rememberMe = false.obs;
  final RxBool nextPage = false.obs;

  Future<void> test(BuildContext context) async {
    try {
      final box = await Hive.openBox<UserId>('UserId');

      if (box.isEmpty) return;

      final oneItem = box.values.first;
      final session =
      await appwriteService.account.getSession(sessionId: 'current');

      if (session == null || session.userId == null) return;

      final userId = session.userId;

      if (userId == oneItem.userId) {
        if (!context.mounted) return;
        context.go(RouteNames.homePage);
      }
    } catch (e) {

      debugPrint('Error in onInit: $e');
    }
  }

/*  @override
  Future<void> onInit() async {
    super.onInit();

    try {
      final box = await Hive.openBox<UserId>('UserId');

      if (box.isEmpty) return;

      final oneItem = box.values.first;
      final session =
          await appwriteService.account.getSession(sessionId: 'current');

      if (session == null || session.userId == null) return;

      final userId = session.userId;

      if (userId == oneItem.userId) {
        nextPage.value = true;
      }
    } catch (e) {
      nextPage.value = false;
      debugPrint('Error in onInit: $e');
    }
  }*/

  /* @override
  Future<void> onInit() async {
    super.onInit();

    try {
      final box = await Hive.openBox<UserId>('UserId');

      if (box.isEmpty) return;

      final oneItem = box.values.first;
      final session = await appwriteService.account.getSession(sessionId: 'current');

      if (session == null || session.userId == null) return;

      final userId = session.userId;

      if (userId == oneItem.userId) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = Get.context;
          if (ctx?.mounted ?? false) {
            ctx!.go(RouteNames.homePage);
          }
        });
      }
    } catch (e) {
      debugPrint('Error in onInit: $e');
    }
  }*/

/*  @override
  Future<void> onInit() async {
   // appwriteService.account.deleteSession(sessionId: 'current');
    super.onInit();

    try {
      final box = await Hive.openBox<UserId>('UserId');

      if (box.isEmpty) {
        return; // از کرش جلوگیری می‌کند
      }

      final oneItem = box.values.first;
      final session = await appwriteService.account.getSession(sessionId: 'current');

      final userId = session.userId;

      if (userId == oneItem.userId) {
        // GetX از context پشتیبانی می‌کند، اما نباید از context در onInit استفاده کرد
        Future.microtask(() => Get.toNamed(RouteNames.homePage));
      }
    } catch (e) {
      debugPrint('Error in onInit: $e');
    }
  }*/

  Future<void> signUp() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final fullName = fullNameController.text.trim();

    if (password.length <
            8 /*||
        !RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@\$!%*?&])[A-Za-z\d@\$!%*?&]{8,}\$')
            .hasMatch(password)*/
        ) {
      _showFaildSnackBar(
          'رمز عبور باید حداقل ۸ کاراکتر و شامل حرف، عدد و نماد باشد');
      return;
    }

    try {
      await appwriteService.account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: fullName,
      );
      _showSuccesSnackBar('ثبت‌نام موفقیت‌آمیز بود!');
    } catch (e) {
      _showFaildSnackBar('خطا در ثبت‌نام: $e');
      print(e);
    }
  }

  void _showSuccesSnackBar(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void _showFaildSnackBar(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Future<void> login(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final box = await Hive.openBox<UserId>('UserId');
    try {
      // چک کردن وضعیت لاگین
      /*  final session =
          await appwriteService.account.getSession(sessionId: 'current');*/
      /*if (session.current) {
        _showSuccesSnackBar('کاربر از قبل وارد شده است!');
        return;
      }*/

      final session = await appwriteService.account
          .createEmailPasswordSession(email: email, password: password);
      _showSuccesSnackBar('ورود موفقیت‌آمیز بود!');
      final newUserId = UserId(
        userId: session.userId,
      );
      await box.add(newUserId);
      if (!context.mounted) return;
      context.go(RouteNames.homePage);
    } catch (e) {
      {
        _showFaildSnackBar('خطا در ورود: $e');
        print(e);
      }
    }
  }

/*
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    try {
      await account.createEmailPasswordSession(email: email, password: password);
      _showSuccesSnackBar('ورود موفقیت‌آمیز بود!');
    } catch (e) {
      _showFaildSnackBar('خطا در ورود: $e');
      print(e);
    }
  }
*/
}
