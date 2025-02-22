import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:qr_hub/src/pages/login_page/controller/login_controller.dart';

import '../../../../qr_hub.dart';
import '../../../infrastructure/app_writer.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    controller.test(context);
    return Scaffold(
      appBar: AppBar(
          title:
              Obx(() => Text(controller.isLogin.value ? 'ورود' : 'ثبت‌نام'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => !controller.isLogin.value
                ? TextField(
                    controller: controller.fullNameController,
                    decoration: InputDecoration(labelText: 'نام کامل'),
                  )
                : SizedBox()),
            TextField(
              controller: controller.emailController,
              decoration: InputDecoration(labelText: 'ایمیل'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: controller.passwordController,
              decoration: InputDecoration(labelText: 'رمز عبور'),
              obscureText: true,
            ),
            Obx(() => controller.isLogin.value
                ? Row(
                    children: [
                      Obx(() => Checkbox(
                            value: controller.rememberMe.value,
                            onChanged: (value) =>
                                controller.rememberMe.value = value!,
                          )),
                      const Text('مرا به خاطر بسپار'),
                    ],
                  )
                : SizedBox()),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => controller.isLogin.value
                  ? controller.login(context)
                  : controller.signUp(),
              child: Obx(
                  () => Text(controller.isLogin.value ? 'ورود' : 'ثبت‌نام')),
            ),
            TextButton(
              onPressed: () =>
                  controller.isLogin.value = !controller.isLogin.value,
              child: Obx(() => Text(controller.isLogin.value
                  ? 'حساب کاربری ندارید؟ ثبت‌نام'
                  : 'قبلاً ثبت‌نام کرده‌اید؟ ورود')),
            ),
          ],
        ),
      ),
    );
  }
}
