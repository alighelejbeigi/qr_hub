import 'package:camera/camera.dart';
import 'package:easy_qr_code/easy_qr_code.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

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
  RxBool isFlashSupported = false.obs;
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

      if (currentController != null) {
        // تلاش برای تغییر وضعیت فلاش
        try {
          isFlashOn.value = !isFlashOn.value;
          await currentController.setFlashMode(
            isFlashOn.value ? FlashMode.torch : FlashMode.off,
          );
        } catch (e) {
          // خطا نشان می‌دهد که دستگاه از فلاش پشتیبانی نمی‌کند
          qrCodeResult.value = 'این دستگاه از فلاش پشتیبانی نمی‌کند.';
          return;
        }
      } else {
        qrCodeResult.value = 'این دستگاه از فلاش پشتیبانی نمی‌کند.';
        return;
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

      try {
        if (cameraController.value != null) {
          await cameraController.value!.setFlashMode(FlashMode.torch);
          isFlashSupported.value = true;

          await cameraController.value!.setFlashMode(FlashMode.off);
        }
      } catch (e) {
        isFlashSupported.value = false;
      }

      isCameraReady.value = true;
    } catch (e) {
      handleError(e);
    }
  }



  void showResultDialog(BuildContext context, String result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: const Color(0xffFDB624),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_2,
                size: 50,
                color: Colors.white,
              ),
              const SizedBox(height: 15),
              Text(
                'نتیجه اسکن QR Code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  if (await canLaunch(result)) {
                    await launch(result);
                  } else {
                    showResultDialog(context, 'آدرس معتبر نیست.');
                  }
                },
                child: Text(
                  result,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'باشه',
                  style: TextStyle(
                    color: Color(0xffFDB624),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// Function to show the dialog
/*
  void showResultDialog(BuildContext context, String result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: const Color(0xffFDB624),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_2,
                size: 50,
                color: Colors.white,
              ),
              const SizedBox(height: 15),
              Text(
                'نتیجه اسکن QR Code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                result,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'باشه',
                  style: TextStyle(
                    color: Color(0xffFDB624),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
*/

  Future<void> captureAndDecodeQRCode(BuildContext context) async {
    if (cameraController.value == null ||
        !cameraController.value!.value.isInitialized) {
      showResultDialog(context, 'دوربین آماده نیست.');
      return;
    }

    try {
      final XFile picture = await cameraController.value!.takePicture();
      final bytes = await picture.readAsBytes();
      final qrReader = EasyQRCodeReader();
      final decodedResult = await qrReader.decode(bytes);
      showResultDialog(context, decodedResult ?? 'QR code یافت نشد.');
    } catch (e) {
      showResultDialog(context, 'خطا در اسکن QR Code: $e');
    }
  }

  Future<void> pickImageFromGallery(BuildContext context) async {
    try {
      final pickedImage =
      await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        final bytes = await pickedImage.readAsBytes();
        final qrReader = EasyQRCodeReader();
        final decodedResult = await qrReader.decode(bytes);
        showResultDialog(context, decodedResult ?? 'QR code یافت نشد.');
      } else {
        showResultDialog(context, 'تصویری انتخاب نشد.');
      }
    } catch (e) {
      showResultDialog(context, 'خطا در انتخاب تصویر: $e');
    }
  }


/*  Future<void> captureAndDecodeQRCode() async {
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
  }*/

  bool isSwitchCamera = false;

  void switchCamera() async {
    if(isSwitchCamera){
      return;
    }

    if (cameras.length > 1) {
      isSwitchCamera= true;
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
        isSwitchCamera= false;
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
