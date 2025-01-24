import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/home_page_controller.dart';
import 'clipper_for_camera_preview.dart';

class MainPage extends GetView<HomePageController> {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) => Center(
        child: Obx(() {
          final currentController = controller.cameraController.value;
          if (controller.isCameraReady.value &&
              currentController != null &&
              currentController.value.isInitialized &&
              !controller.isLoading.value) {
            return Column(
              children: [
                Expanded(
                  child: ClipPath(
                    clipper: BottomCircularNotchClipper(),
                    child: CameraPreview(
                      currentController,
                      child: _buildActionButtons(context),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xffFDB624)),
              ),
            );
          }
        }),
      );

  // Action Buttons Method (Gallery, Capture, Switch Camera, Flashlight)
  Widget _buildActionButtons(BuildContext context) {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 1),
          _buildPickGalleryButton(context),
          const Spacer(flex: 1),
          _buildCaptureQRCodeButton(context),
          const Spacer(flex: 2),
          _buildSwitchCameraButton(),
          const Spacer(flex: 1),
          _buildFlashlightButton(),
          const Spacer(flex: 1),
        ],
      ),
    );
  }

  // Gallery Button Method
  Widget _buildPickGalleryButton(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'یک تصویر را از گالری انتخاب کنید',
      backgroundColor: const Color(0xffFDB624),
      onPressed: () => controller.pickImageFromGallery(context),
      child: const Icon(Icons.image, color: Colors.white),
    );
  }

  // Capture QR Code Button Method
  Widget _buildCaptureQRCodeButton(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'از کد QR عکس بگیرید',
      backgroundColor: const Color(0xffFDB624),
      onPressed: () => controller.captureAndDecodeQRCode(context),
      child: const Icon(Icons.camera_alt, color: Colors.white),
    );
  }

  // Switch Camera Button Method
  Widget _buildSwitchCameraButton() {
    return FloatingActionButton(
      heroTag: 'دوربین را عوض کنید',
      backgroundColor: const Color(0xffFDB624),
      onPressed: controller.switchCamera,
      child: const Icon(Icons.switch_camera, color: Colors.white),
    );
  }

  // Flashlight Button Method
  Widget _buildFlashlightButton() {
    return Obx(() => FloatingActionButton(
          heroTag: 'چراغ قوه را روشن کنید',
          backgroundColor: controller.isFlashSupported.value
              ? const Color(0xffFDB624)
              : const Color(0xffb6b6b3),
          onPressed:
              controller.isFlashSupported.value ? controller.toggleFlash : null,
          child: Icon(
            controller.isFlashOn.value ? Icons.flash_off : Icons.flash_on,
            color: Colors.white,
          ),
        ));
  }
}
