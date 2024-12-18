import 'package:camera/camera.dart';
import 'package:easy_qr_code/easy_qr_code.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../../../qr_hub.dart';
import '../view/widget/history.dart';
import '../view/widget/main_page.dart';

class HomePageController extends GetxController {
  RxInt selectedIndex = 2.obs;
  RxBool isFlashOn = false.obs;
  final pages = [
     HistoryPage(),
    const Center(child: Text('Generate Page')),
    const MainPage(),
  ];

  Rx<CameraController?> cameraController = Rx<CameraController?>(null);
  late List<CameraDescription> cameras;
  RxString qrCodeResult = ''.obs;
  RxBool isCameraReady = false.obs;
  RxBool isFlashSupported = false.obs;
  RxInt selectedCameraIndex = 0.obs;
  bool isSwitchCamera = false;

  @override
  void onInit() {
    super.onInit();
    initializeCamera();
  }

  @override
  void onClose() {
    cameraController.value?.dispose();
    super.onClose();
  }

  void onTabTapped(int index) {
    selectedIndex.value = index;
  }

  Future<void> initializeCamera() async {
    try {
      final cameraPermission = await Permission.camera.request();

      if (!cameraPermission.isGranted) {
        qrCodeResult.value = 'دسترسی به دوربین لازم است تا این عملیات انجام شود.';
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
    if (cameraController.value == null || !cameraController.value!.value.isInitialized) {
      qrCodeResult.value = 'دوربین آماده نیست.';
      return;
    }

    try {
      final currentController = cameraController.value;

      if (currentController != null) {
        isFlashOn.value = !isFlashOn.value;
        await currentController.setFlashMode(
          isFlashOn.value ? FlashMode.torch : FlashMode.off,
        );
      } else {
        qrCodeResult.value = 'این دستگاه از فلاش پشتیبانی نمی‌کند.';
      }
    } catch (e) {
      qrCodeResult.value = 'این دستگاه از فلاش پشتیبانی نمی‌کند.';
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





  final uuid = const Uuid();

  Future<void> saveHistory(String result) async {
    final box = await Hive.openBox<History>('historyBox');

    // ایجاد آیتم جدید با ID یکتا
    final newHistory = History(
      text: result,
      date: DateTime.now(),
      id: uuid.v4(), // تولید ID یکتا
    );

    // ذخیره آیتم جدید با استفاده از ID به‌عنوان کلید
    await box.put(newHistory.id, newHistory);
  }

  Future<void> deleteHistory(String id) async {
    final box = await Hive.openBox<History>('historyBox');
    await box.delete(id);
  }

  Future<List<History>> getAllHistory() async {
    final box = await Hive.openBox<History>('historyBox');
    return box.values.toList();
  }



// هنگام دریافت نتیجه اسکن
  void handleScanResult(String result) {
    if (result.isNotEmpty) {

      saveHistory(result); // ذخیره نتیجه
      // نمایش نتیجه در UI یا اقدامات دیگر
      print('اسکن موفق: $result');
    } else {
      print('خطا: نتیجه اسکن خالی است.');
    }
  }


  void showResultDialog(BuildContext context, String result) {
    handleScanResult(result);
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
              const Icon(
                Icons.qr_code_2,
                size: 50,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              const Text(
                'نتیجه اسکن',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              clickableResultText(result),
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

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  bool isValidUrl(String url) {
    const urlPattern = r'^(https?:\/\/)?'
        r'(([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,6})'
        r'(\/[^\s]*)?$';
    final regex = RegExp(urlPattern);
    return regex.hasMatch(url);
  }

  Widget clickableResultText(String result) {
    bool isValidUrls = isValidUrl(result);
    return GestureDetector(
      onTap: () {
        if (isValidUrls) {
          _launchURL(result);
        }
      },
      child: Text(
        result,
        style: TextStyle(
          color: isValidUrls ? Colors.blue : Colors.white,
          decoration: isValidUrls ? TextDecoration.underline : TextDecoration.none,
        ),
      ),
    );
  }

  Future<void> captureAndDecodeQRCode(BuildContext context) async {
    if (cameraController.value == null || !cameraController.value!.value.isInitialized) {
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
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
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

  void switchCamera() async {
    if (isSwitchCamera) {
      return;
    }

    if (cameras.length > 1) {
      isSwitchCamera = true;
      isCameraReady.value = false;
      qrCodeResult.value = 'در حال تغییر دوربین...';
      try {
        selectedCameraIndex.value = (selectedCameraIndex.value + 1) % cameras.length;
        await _setupCameraController(cameras[selectedCameraIndex.value]);
      } catch (e) {
        handleError(e);
      } finally {
        isCameraReady.value = true;
        qrCodeResult.value = '';
        isSwitchCamera = false;
      }
    } else {
      qrCodeResult.value = 'فقط یک دوربین در دسترس است.';
    }
  }

  void handleError(dynamic e) {
    qrCodeResult.value = 'خطایی رخ داده است: $e';
  }
}
