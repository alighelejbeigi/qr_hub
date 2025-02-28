import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:camera/camera.dart';
import 'package:easy_qr_code/easy_qr_code.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart' as handler;
import 'package:qr_hub/src/infrastructure/app_writer.dart';
import 'package:qr_hub/src/pages/home_page/models/qr_generate_dto.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../../../qr_hub.dart';
import '../models/qr_scan_dto.dart';

class HomePageController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final qrGenerator = EasyQRCodeGenerator();
  Rxn<Uint8List> imageBytes = Rxn();
  Uint8List? imageBytesForSave;
  RxInt selectedIndex = 2.obs;
  RxBool isFlashOn = false.obs;
  Rx<CameraController?> cameraController = Rx<CameraController?>(null);
  XFile? xFile;

  late List<CameraDescription> cameras;

  //RxString qrCodeResult = ''.obs;
  RxBool isCameraReady = false.obs;
  RxBool isFlashSupported = false.obs;
  RxBool isLoading = false.obs;
  RxInt selectedCameraIndex = 0.obs;
  bool isSwitchCamera = false;
  final uuid = const Uuid();

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
      final cameraPermission = await handler.Permission.camera.request();
      //var status = await Permission.storage.request();

      if (!cameraPermission.isGranted) {
        _showFaildSnackBar(
            'دسترسی به دوربین لازم است تا این عملیات انجام شود.');

        return;
      }

      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        await _setupCameraController(cameras[selectedCameraIndex.value]);
      } else {
        _showFaildSnackBar('دوربینی در دسترس نیست.');
      }
    } catch (e) {
      handleError(e);
    }
  }

  Future<void> toggleFlash() async {
    if (cameraController.value == null ||
        !cameraController.value!.value.isInitialized) {
      _showFaildSnackBar('دوربین آماده نیست.');

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
        _showFaildSnackBar('این دستگاه از فلاش پشتیبانی نمی‌کند.');
      }
    } catch (e) {
      _showFaildSnackBar('این دستگاه از فلاش پشتیبانی نمی‌کند.');
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
        enableAudio: false,
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

  final String databaseId = '66cadb580006a39e25e7';

  final String collectionScanId = '67be17330001d602b00f';
  final String collectionGenerateId = '67be1e410031415ab6c6';

  // QrCodeService({required this.databases});

  Future<void> saveQrScan(QrScan qrData) async {
    await appwriteService.databases.createDocument(
      databaseId: databaseId,
      collectionId: collectionScanId,
      documentId: appwrite.ID.unique(),
      data: qrData.toJson(),
    );
  }

  Future<void> saveQrGenerate(QrGenerate qrData) async {
    await appwriteService.databases.createDocument(
      databaseId: databaseId,
      collectionId: collectionGenerateId,
      documentId: appwrite.ID.unique(),
      data: qrData.toJson(),
    );
  }

  Future<String?> uploadQrImage(Uint8List bytes) async {
    try {
      // دریافت اطلاعات کاربر فعلی
      final user = await appwriteService.account.get();

      final response = await appwriteService.storage.createFile(
        bucketId: '67c1719c000278a3d248',
        fileId: appwrite.ID.unique(),
        file: appwrite.InputFile.fromBytes(
          bytes: bytes,
          filename: 'qr_code_${DateTime.now().millisecondsSinceEpoch}.png',
        ),
        permissions: [
          appwrite.Permission.read('user:${user.$id}'),
          appwrite.Permission.delete('user:${user.$id}'),
          appwrite.Permission.update('user:${user.$id}'),
        ],
      );

      return response.$id;
    } catch (e) {
      print("Error uploading file: $e");
      return null;
    }
  }

  String getQrImageUrl(String fileId) {
    return "https://cloud.appwrite.io/v1/storage/buckets/67c1719c000278a3d248/files/$fileId/view?project=66cad12e001f798dacf8";
  }

  Future<List<QrScan>> fetchUserScans() async {
    final session =
        await appwriteService.account.getSession(sessionId: 'current');
    final response = await appwriteService.databases.listDocuments(
      databaseId: databaseId,
      collectionId: collectionScanId,
      queries: [appwrite.Query.equal('userId', session.userId)],
    );

    return response.documents.map((doc) => QrScan.fromJson(doc.data)).toList();
  }

  Future<List<QrGenerate>> fetchUserGenerate() async {
    final session =
        await appwriteService.account.getSession(sessionId: 'current');
    final response = await appwriteService.databases.listDocuments(
      databaseId: databaseId,
      collectionId: collectionGenerateId,
      queries: [appwrite.Query.equal('userId', session.userId)],
    );

    return response.documents
        .map((doc) => QrGenerate.fromJson(doc.data))
        .toList();
  }

  Future<void> deleteQrScan(String documentId, String? fileId) async {
    await appwriteService.databases.deleteDocument(
      databaseId: databaseId,
      collectionId: collectionScanId,
      documentId: documentId,
    );
    if (fileId != null) {
      await appwriteService.storage.deleteFile(
        bucketId: '67c1719c000278a3d248',
        fileId: fileId,
      );
    }
  }

  Future<void> deleteQrGenerate(String documentId, String? fileId) async {
    await appwriteService.databases.deleteDocument(
      databaseId: databaseId,
      collectionId: collectionGenerateId,
      documentId: documentId,
    );
    if (fileId != null) {
      await appwriteService.storage.deleteFile(
        bucketId: '67c1719c000278a3d248',
        fileId: fileId,
      );
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

  Future<void> showResultDialog(BuildContext context, String result) async {
    //saveHistoryRead(result);
    final session =
        await appwriteService.account.getSession(sessionId: 'current');
    String? imageUrl;
    String? fileId;
    if (imageBytesForSave != null) {
      fileId = await uploadQrImage(imageBytesForSave!);
      if (fileId != null) {
        imageUrl = getQrImageUrl(fileId);
      }
    }

    saveQrScan(
      QrScan(
        id: '',
        text: result,
        date: DateTime.now(),
        userId: session.userId,
        photoUrl: imageUrl,
        fileId: fileId,
      ),
    );

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
    isLoading.value = true;
    if (cameraController.value == null ||
        !cameraController.value!.value.isInitialized) {
      _showFaildSnackBar('دوربین آماده نیست.');
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
        isLoading.value = false;
      } else {
        _showFaildSnackBar(' کد QR یافت نشد');
        isLoading.value = false;
      }
    } catch (e) {
      _showFaildSnackBar('خطا در اسکن کد QR: $e');
      isLoading.value = false;
    }
  }

  Future<void> pickImageFromGallery(BuildContext context) async {
    isLoading.value = true;
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
          isLoading.value = false;
        } else {
          _showFaildSnackBar('کد QR یافت نشد');
          isLoading.value = false;
        }
      } else {
        _showFaildSnackBar('تصویری انتخاب نشد.');
        isLoading.value = false;
      }
    } catch (e) {
      _showFaildSnackBar('خطا در انتخاب تصویر: $e');
      isLoading.value = false;
    }
  }

  void switchCamera() async {
    if (isSwitchCamera) {
      return;
    }

    if (cameras.length > 1) {
      isSwitchCamera = true;
      isCameraReady.value = false;

      _showFaildSnackBar('در حال تغییر دوربین...');
      try {
        selectedCameraIndex.value =
            (selectedCameraIndex.value + 1) % cameras.length;
        await _setupCameraController(cameras[selectedCameraIndex.value]);
      } catch (e) {
        handleError(e);
      } finally {
        isCameraReady.value = true;
        _showFaildSnackBar('');

        isSwitchCamera = false;
      }
    } else {
      _showFaildSnackBar('فقط یک دوربین در دسترس است.');
    }
  }

  Future<void> generateQRCode() async {
    final data = textController.text;
    if (data.isNotEmpty) {
      final session =
          await appwriteService.account.getSession(sessionId: 'current');

      final qrWidget = await qrGenerator.generateQRCodeImage(data: data);
      final bytes = await convertImageToBytes(qrWidget);
      if (bytes != null) {
        imageBytes.value = bytes;
        imageBytesForSave = bytes;
        String? imageUrl;
        String? fileId;
        if (imageBytesForSave != null) {
          fileId = await uploadQrImage(imageBytesForSave!);
          if (fileId != null) {
            imageUrl = getQrImageUrl(fileId);
          }
        }
        saveQrGenerate(
          QrGenerate(
            id: '',
            fileId: fileId!,
            qrImageUrl: imageUrl!,
            userId: session.userId,
            date: DateTime.now(),
            text: data,
          ),
        );
        imageBytesForSave = null;
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

  void showDeleteDialog({
    required BuildContext context,
    required String id,
    String? fileId,
    required bool isScanHistory,
  }) {
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
                  await deleteQrScan(id, fileId);
                } else {
                  await deleteQrGenerate(id, fileId);
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

  void _showFaildSnackBar(String message) {
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

  Future<void> saveQRCodeToDownloads() async {
    try {
      var status = await handler.Permission.storage.request();
      if (!status.isGranted) {
        _showFaildSnackBar('مجوز ذخیره سازی رد شد');
        return;
      }
      final customDir = Directory('/storage/emulated/0/Download');
      String filePath = '${customDir.path}/easyQrCode_${const Uuid().v4()}.png';
      final file = File(filePath);
      await file.writeAsBytes(imageBytes.value!);
      _showSuccesSnackBar('در دانلود ها ذخیره شد');
    } catch (e) {
      _showFaildSnackBar('خطا در ذخیره فایل');
    }
  }

  // Method to share generated QR code image
  Future<void> shareQRCodeImage() async {
    qrGenerator.shareQRCodeFromBytes(qrBytes: imageBytes.value!);
  }

  void handleError(dynamic e) {
    _showFaildSnackBar('خطایی رخ داده است: $e');
  }
}
