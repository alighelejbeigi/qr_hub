import 'package:camera/camera.dart';
import 'package:easy_qr_code/easy_qr_code.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../view/widget/main_page.dart';

class HomePageController extends GetxController {
  RxInt selectedIndex = 2.obs;
  RxBool isFlashOn = false.obs;
  final pages = [
    const Center(child: Text('history Page')),
    const Center(child: Text('Generate Page')),
    const MainPage(),
  ];

  void onTabTapped(int index) {
    selectedIndex.value = index;
  }

  Rx<CameraController?> cameraController = Rx<CameraController?>(null);
  late List<CameraDescription> cameras;
  RxString qrCodeResult = ''.obs;
  RxBool isCameraReady = false.obs;
  RxInt selectedCameraIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      final cameraPermission = await Permission.camera.request();

      if (!cameraPermission.isGranted) {
        qrCodeResult.value =
            'دسترسی به دوربین لازم است تا این عملیات انجام شود.';
        return;
      }

      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        await _setupCameraController(cameras[selectedCameraIndex.value]);
      } else {
        qrCodeResult.value = 'دوربینی در دسترس نیست.';
      }
    } catch (e) {
      handleError(e);
    }
  }

  Future<void> toggleFlash() async {
    if (cameraController.value == null ||
        !cameraController.value!.value.isInitialized) {
      qrCodeResult.value = 'دوربین آماده نیست.';
      return;
    }

    try {
      final currentController = cameraController.value;
      // Check if the camera supports flash
      if (currentController != null) {
        isFlashOn.value = !isFlashOn.value;
        await currentController.setFlashMode(
          isFlashOn.value ? FlashMode.torch : FlashMode.off,
        );
      } else {
        qrCodeResult.value = 'این دستگاه از فلاش پشتیبانی نمی‌کند.';
      }
    } catch (e) {
      handleError(e);
    }
  }

  Future<void> _setupCameraController(CameraDescription camera) async {
    try {
      final previousController = cameraController.value;
      if (previousController != null) {
        await previousController.dispose();
      }

      final newController = CameraController(
        camera,
        ResolutionPreset.medium,
      );

      cameraController.value = newController;
      await newController.initialize();
      isCameraReady.value = true;
    } catch (e) {
      handleError(e);
    }
  }

  Future<void> captureAndDecodeQRCode() async {
    if (cameraController.value == null ||
        !cameraController.value!.value.isInitialized) {
      qrCodeResult.value = 'دوربین آماده نیست.';
      return;
    }

    try {
      final XFile picture = await cameraController.value!.takePicture();
      final bytes = await picture.readAsBytes();
      final qrReader = EasyQRCodeReader();
      final decodedResult = await qrReader.decode(bytes);
      qrCodeResult.value = decodedResult ?? 'QR code یافت نشد.';
    } catch (e) {
      handleError(e);
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        final bytes = await pickedImage.readAsBytes();
        final qrReader = EasyQRCodeReader();
        final decodedResult = await qrReader.decode(bytes);
        qrCodeResult.value = decodedResult ?? 'QR code یافت نشد.';
      }
    } catch (e) {
      handleError(e);
    }
  }

  void switchCamera() async {
    if (cameras.length > 1) {
      isCameraReady.value = false;
      qrCodeResult.value = 'در حال تغییر دوربین...';
      try {
        selectedCameraIndex.value =
            (selectedCameraIndex.value + 1) % cameras.length;
        await _setupCameraController(cameras[selectedCameraIndex.value]);
      } catch (e) {
        handleError(e);
      } finally {
        isCameraReady.value = true;
        qrCodeResult.value = '';
      }
    } else {
      qrCodeResult.value = 'فقط یک دوربین در دسترس است.';
    }
  }

  void handleError(dynamic e) {
    qrCodeResult.value = 'خطایی رخ داده است: $e';
  }

  @override
  void onClose() {
    cameraController.value?.dispose();
    super.onClose();
  }
}
