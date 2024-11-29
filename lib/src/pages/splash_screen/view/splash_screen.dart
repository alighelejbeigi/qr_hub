import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.goToLoginPage(context);
    });

    return Scaffold(
      body: SizedBox(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        child: Stack(
          children: [
            // تصویر پس‌زمینه
            Positioned.fill(
              child: Image.asset(
                'assets/splash.png',
                package: 'qr_hub',
                scale: 0.6,
                fit: BoxFit.cover, // برای پوشش کل صفحه
              ),
            ),
            // متن پایین‌تر از مرکز
            Positioned(
              bottom: MediaQuery.sizeOf(context).height *
                  0.5, // کمی بالاتر از پایین
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Qr Hub',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: MediaQuery.sizeOf(context).height *
                  0.1, // کمی بالاتر از پایین
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'version 0.1',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
