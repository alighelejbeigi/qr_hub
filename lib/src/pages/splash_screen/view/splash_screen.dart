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

    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: SizedBox(
        height: screenHeight,
        width: screenWidth,
        child: Stack(
          children: [
            _buildBackgroundImage(),
            _buildTitle(screenHeight),
            _buildVersionInfo(screenHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() => Positioned.fill(
        child: Image.asset(
          'assets/splash.png',
          package: 'qr_hub',
          scale: 0.6,
          fit: BoxFit.cover,
        ),
      );

  Widget _buildTitle(double screenHeight) => Positioned(
        bottom: screenHeight * 0.5,
        left: 0,
        right: 0,
        child: const Center(
          child: Text(
            'Qr Hub',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

  Widget _buildVersionInfo(double screenHeight) => Positioned(
        bottom: screenHeight * 0.1,
        left: 0,
        right: 0,
        child: const Center(
          child: Text(
            'version 1.0',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
}
