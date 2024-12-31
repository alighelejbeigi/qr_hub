import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:easy_qr_code/easy_qr_code.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../../../qr_hub.dart';
import '../models/sample_qr.dart';
import '../view/widget/generate_page.dart';
import '../view/widget/history_page.dart';
import '../view/widget/main_page.dart';

class HomePageController extends GetxController {
  final TextEditingController textController = TextEditingController();
  Rx<Widget> result = Rx<Widget>(const SizedBox());
  final qrGenerator = EasyQRCodeGenerator();
  Rx<Uint8List> imageBytes = Rx<Uint8List>(SampleQr().sample);
  Uint8List? imageBytesForSave;
  RxInt selectedIndex = 2.obs;
  RxBool isFlashOn = false.obs;

  final pages = [
    const HistoryPage(),
    const GeneratePage(),
    const MainPage(),
  ];

  final titles = [
    const Text('History Page'),
    const Text('Generate'),
    const Text('QR Hub'),
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
    //textController.text = 'QR HUB';
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

  Future<void> saveHistoryRead(String result) async {
    final box = await Hive.openBox<QrCodeScanHistory>('historyBox');

    // ایجاد آیتم جدید با ID یکتا
    final newHistory = QrCodeScanHistory(
      text: result,
      date: DateTime.now(),
      id: uuid.v4(), // تولید ID یکتا
      photo: imageBytesForSave,
    );

    // ذخیره آیتم جدید با استفاده از ID به‌عنوان کلید
    await box.put(newHistory.id, newHistory);
  }

  Future<void> deleteHistory(String id) async {
    final box = await Hive.openBox<QrCodeScanHistory>('historyBox');
    await box.delete(id);
  }

  Future<void> deleteHistoryGeneration(String id) async {
    final box2 = await Hive.openBox<QrCodeGenerateHistory>('qrCodeGenerationHistoryBox');
    await box2.delete(id);
  }

  Future<void> saveHistoryGeneration(String result) async {
    final box = await Hive.openBox<QrCodeGenerateHistory>('qrCodeGenerationHistoryBox');

    // ایجاد آیتم جدید با ID یکتا
    final newHistory = QrCodeGenerateHistory(
      text: result,
      date: DateTime.now(),
      id: uuid.v4(), // تولید ID یکتا
      photo: imageBytes.value,
    );

    // ذخیره آیتم جدید با استفاده از ID به‌عنوان کلید
    await box.put(newHistory.id, newHistory);
  }

  Future<List<QrCodeScanHistory>> getAllHistory() async {
    final box = await Hive.openBox<QrCodeScanHistory>('historyBox');
    return box.values.toList();
  }

  Future<List<QrCodeGenerateHistory>> getAllGenerationHistory() async {
    final box = await Hive.openBox<QrCodeGenerateHistory>('qrCodeGenerationHistoryBox');
    return box.values.toList();
  }

// هنگام دریافت نتیجه اسکن
  void handleScanResult(String result) {
    if (result.isNotEmpty) {
      saveHistoryRead(result); // ذخیره نتیجه
      // نمایش نتیجه در UI یا اقدامات دیگر
    } else {}
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
          decoration:
              isValidUrls ? TextDecoration.underline : TextDecoration.none,
        ),
      ),
    );
  }

  Future<void> captureAndDecodeQRCode(BuildContext context) async {
    if (cameraController.value == null ||
        !cameraController.value!.value.isInitialized) {
      showResultDialog(context, 'دوربین آماده نیست.');
      return;
    }

    try {
      final XFile picture = await cameraController.value!.takePicture();
      final bytes = await picture.readAsBytes();
      imageBytesForSave = bytes;
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
        imageBytesForSave = bytes;
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
        selectedCameraIndex.value =
            (selectedCameraIndex.value + 1) % cameras.length;
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

  Future<void> generateQRCode() async {
    final data = textController.text;
    if (data.isNotEmpty) {
      final qrWidget = await qrGenerator.generateQRCodeImage(data: data);
      final bytes = await convertImageToBytes(qrWidget);
      imageBytes.value = bytes!;
      saveHistoryGeneration(data);
    }
  }


  void showDeleteDialog(BuildContext context,String id,bool isScanHistory ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: const Text('Are you sure you want to delete?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
               if (isScanHistory) {
                 await deleteHistory(id);
               }else{
                await deleteHistoryGeneration(id);
               }
               if (!context.mounted) return;
               _showSnackBar(context, "Item deleted!");
               Get.forceAppUpdate();
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<Uint8List?> convertImageToBytes(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  // Method to save generated QR code image
  Future<void> saveQRCodeImage() async {
    qrGenerator.saveQRCodeFromBytes(qrBytes: imageBytes.value);
  }

  // Method to share generated QR code image
  Future<void> shareQRCodeImage() async {
    qrGenerator.shareQRCodeFromBytes(qrBytes: imageBytes.value);
  }

  void handleError(dynamic e) {
    qrCodeResult.value = 'خطایی رخ داده است: $e';
  }
}
