import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:easy_qr_code/easy_qr_code.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../../../qr_hub.dart';
import '../view/widget/generate_page.dart';
import '../view/widget/history_page.dart';
import '../view/widget/main_page.dart';

class HomePageController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final qrGenerator = EasyQRCodeGenerator();
  Rxn<Uint8List> imageBytes = Rxn();
  Uint8List? imageBytesForSave;
  RxInt selectedIndex = 2.obs;
  RxBool isFlashOn = false.obs;
  Rx<CameraController?> cameraController = Rx<CameraController?>(null);
  late List<CameraDescription> cameras;

  //RxString qrCodeResult = ''.obs;
  RxBool isCameraReady = false.obs;
  RxBool isFlashSupported = false.obs;
  RxInt selectedCameraIndex = 0.obs;
  bool isSwitchCamera = false;
  final uuid = const Uuid();

  final pages = [
    const HistoryPage(),
    const GeneratePage(),
    const MainPage(),
  ];

  final titles = [
    const Text('تاریخچه QR'),
    const Text('ساخت کد QR'),
    const Text('QR هاب'),
  ];

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
        _showSnackBar('دسترسی به دوربین لازم است تا این عملیات انجام شود.');

        return;
      }

      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        await _setupCameraController(cameras[selectedCameraIndex.value]);
      } else {
        _showSnackBar('دوربینی در دسترس نیست.');
      }
    } catch (e) {
      handleError(e);
    }
  }

  Future<void> toggleFlash() async {
    if (cameraController.value == null ||
        !cameraController.value!.value.isInitialized) {
      _showSnackBar('دوربین آماده نیست.');

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
        _showSnackBar('این دستگاه از فلاش پشتیبانی نمی‌کند.');
      }
    } catch (e) {
      _showSnackBar('این دستگاه از فلاش پشتیبانی نمی‌کند.');
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
    final box2 =
        await Hive.openBox<QrCodeGenerateHistory>('qrCodeGenerationHistoryBox');
    await box2.delete(id);
  }

  Future<void> saveHistoryGeneration(String result) async {
    final box =
        await Hive.openBox<QrCodeGenerateHistory>('qrCodeGenerationHistoryBox');

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
    final box =
        await Hive.openBox<QrCodeGenerateHistory>('qrCodeGenerationHistoryBox');

    return box.values.toList();
  }

  void showResultDialog(BuildContext context, String result) {
    saveHistoryRead(result);
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
      throw Exception(' امکان باز کردن این$url وجود ندارد ');
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
      _showSnackBar('دوربین آماده نیست.');
      return;
    }

    try {
      final XFile picture = await cameraController.value!.takePicture();
      final bytes = await picture.readAsBytes();
      imageBytesForSave = bytes;
      final qrReader = EasyQRCodeReader();
      final decodedResult = await qrReader.decode(bytes);
      if (decodedResult != null) {
        if (!context.mounted) return;
        showResultDialog(context, decodedResult);
      } else {
        _showSnackBar(' کد QR یافت نشد');
      }
    } catch (e) {
      _showSnackBar('خطا در اسکن کد QR: $e');
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
        if (decodedResult != null) {
          if (!context.mounted) return;
          showResultDialog(context, decodedResult);
        } else {
          _showSnackBar('کد QR یافت نشد');
        }
      } else {
        _showSnackBar('تصویری انتخاب نشد.');
      }
    } catch (e) {
      _showSnackBar('خطا در انتخاب تصویر: $e');
    }
  }

  void switchCamera() async {
    if (isSwitchCamera) {
      return;
    }

    if (cameras.length > 1) {
      isSwitchCamera = true;
      isCameraReady.value = false;

      _showSnackBar('در حال تغییر دوربین...');
      try {
        selectedCameraIndex.value =
            (selectedCameraIndex.value + 1) % cameras.length;
        await _setupCameraController(cameras[selectedCameraIndex.value]);
      } catch (e) {
        handleError(e);
      } finally {
        isCameraReady.value = true;
        _showSnackBar('');

        isSwitchCamera = false;
      }
    } else {
      _showSnackBar('فقط یک دوربین در دسترس است.');
    }
  }

  Future<void> generateQRCode() async {
    final data = textController.text;
    if (data.isNotEmpty) {
      final qrWidget = await qrGenerator.generateQRCodeImage(data: data);
      final bytes = await convertImageToBytes(qrWidget);
      if (bytes != null) {
        imageBytes.value = bytes;
        saveHistoryGeneration(data);
      } else {
        return;
      }
    }
  }

  Future<void> deleteAllHistory() async {
    final box = await Hive.openBox<QrCodeScanHistory>('historyBox');
    await box.clear();
    final box2 =
        await Hive.openBox<QrCodeGenerateHistory>('qrCodeGenerationHistoryBox');
    await box2.clear();
  }

  void showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('حذف همه QR ها'),
          content: const Text('آیا مطمئن هستید که می خواهید حذف کنید؟'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('لغو'),
            ),
            TextButton(
              onPressed: () async {
                await deleteAllHistory();
                if (!context.mounted) return;
                getAllHistory();
                generateQRCode();
                _showSuccesSnackBar('همه QR کد ها پاک شد');
                Get.forceAppUpdate();
                Navigator.of(context).pop();
              },
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }

  void showDeleteDialog(BuildContext context, String id, bool isScanHistory) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('حذف یک مورد'),
          content: const Text('آیا مطمئن هستید که می خواهید حذف کنید؟'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('لغو'),
            ),
            TextButton(
              onPressed: () async {
                if (isScanHistory) {
                  await deleteHistory(id);
                } else {
                  await deleteHistoryGeneration(id);
                }
                if (!context.mounted) return;

                _showSuccesSnackBar("مورد انتخابی حذف شد");
                Get.forceAppUpdate();
                Navigator.of(context).pop();
              },
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void _showSuccesSnackBar(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Future<Uint8List?> convertImageToBytes(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  // Method to save generated QR code image
  Future<void> saveQRCodeImage() async {
    qrGenerator.saveQRCodeFromBytes(qrBytes: imageBytes.value!);
    _showSuccesSnackBar('در دانلود ها ذخیره شد');
  }

  // Method to share generated QR code image
  Future<void> shareQRCodeImage() async {
    qrGenerator.shareQRCodeFromBytes(qrBytes: imageBytes.value!);
  }

  void handleError(dynamic e) {
    _showSnackBar('خطایی رخ داده است: $e');
  }
}
