import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/home_page_controller.dart';

class MainPage extends GetView<HomePageController> {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Obx(() {
            final currentController = controller.cameraController.value;
            if (controller.isCameraReady.value &&
                currentController != null &&
                currentController.value.isInitialized) {
              return Column(
                children: [
                  Expanded(child: CameraPreview(currentController)),
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
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                FloatingActionButton(
                  heroTag: 'pickGalleryImage',
                  backgroundColor: const Color(0xffFDB624),
                  onPressed: controller.pickImageFromGallery,
                  child: const Icon(Icons.image, color: Colors.white),
                ),
                const Spacer(flex: 1),
                FloatingActionButton(
                  heroTag: 'captureQRCode',
                  backgroundColor: const Color(0xffFDB624),
                  onPressed: controller.captureAndDecodeQRCode,
                  child: const Icon(Icons.camera_alt, color: Colors.white),
                ),
                const Spacer(flex: 1),
                FloatingActionButton(
                  heroTag: 'switchCamera',
                  backgroundColor: const Color(0xffFDB624),
                  onPressed: controller.switchCamera,
                  child: const Icon(Icons.switch_camera, color: Colors.white),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Obx(() => Text(
                  controller.qrCodeResult.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    backgroundColor: Colors.black54,
                    fontSize: 16,
                  ),
                )),
          ),
        ],
      );
}
