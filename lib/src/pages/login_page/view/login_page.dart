import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_hub/src/pages/login_page/controller/login_controller.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.isLogin.value ? 'ورود' : 'ثبت‌نام')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(
                    () => !controller.isLogin.value
                    ? TextFormField(
                  controller: controller.fullNameController,
                  decoration: const InputDecoration(labelText: 'نام کامل'),
                  validator: (value) =>
                  value!.isEmpty ? 'وارد کردن نام کامل الزامی است' : null,
                )
                    : const SizedBox(),
              ),
              TextFormField(
                controller: controller.emailController,
                decoration: const InputDecoration(labelText: 'ایمیل'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty
                    ? 'وارد کردن ایمیل الزامی است'
                    : (!GetUtils.isEmail(value)
                    ? 'ایمیل معتبر نیست'
                    : null),
              ),
              Obx(
                    () => TextFormField(
                  controller: controller.passwordController,
                  decoration: InputDecoration(
                    labelText: 'رمز عبور',
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        controller.isPasswordVisible.value =
                        !controller.isPasswordVisible.value;
                      },
                    ),
                  ),
                  obscureText: !controller.isPasswordVisible.value,
                  validator: (value) =>
                  value!.isEmpty ? 'وارد کردن رمز عبور الزامی است' : null,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (controller.formKey.currentState!.validate()) {
                    controller.isLogin.value
                        ? controller.login(context)
                        : controller.signUp(context);
                  }
                },
                child: Obx(() => Text(controller.isLogin.value ? 'ورود' : 'ثبت‌نام')),
              ),
              TextButton(
                onPressed: () => controller.isLogin.value = !controller.isLogin.value,
                child: Obx(
                      () => Text(controller.isLogin.value
                      ? 'حساب کاربری ندارید؟ ثبت‌نام'
                      : 'قبلاً ثبت‌نام کرده‌اید؟ ورود'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
