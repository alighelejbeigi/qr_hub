import 'package:camera/camera.dart';
import 'package:easy_qr_code/easy_qr_code.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../../utils/constants.dart';
import '../view/widget/dialogs/delete_all_dialog.dart';
import '../view/widget/dialogs/delete_dialog.dart';
import '../view/widget/dialogs/result_dialog.dart';
import 'generate_qr_helper.dart';
import 'history_qr_helper.dart';

class HomePageController extends GetxController {
  late final GenerateQRHelper generateQRHelper = GenerateQRHelper(this);
  late final HistoryQrHelper historyQrHelper = HistoryQrHelper(this);

  RxInt selectedIndex = 2.obs;
  Rx<CameraController?> cameraController = Rx<CameraController?>(null);
  late List<CameraDescription> cameras;
  RxBool isFlashOn = false.obs;
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
      final cameraPermission = await Permission.camera.request();
      if (!cameraPermission.isGranted) {
        showFailedSnackBar(
            'دسترسی به دوربین لازم است تا این عملیات انجام شود.');
        return;
      }

      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        await _setupCameraController(cameras[selectedCameraIndex.value]);
      } else {
        showFailedSnackBar('دوربینی در دسترس نیست.');
      }
    } catch (e) {
      handleError(e);
    }
  }

  Future<void> toggleFlash() async {
    if (cameraController.value == null ||
        !cameraController.value!.value.isInitialized) {
      showFailedSnackBar('دوربین آماده نیست.');

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
        showFailedSnackBar('این دستگاه از فلاش پشتیبانی نمی‌کند.');
      }
    } catch (e) {
      showFailedSnackBar('این دستگاه از فلاش پشتیبانی نمی‌کند.');
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

  void showResultDialog(BuildContext context, String result) {
    historyQrHelper.saveHistoryRead(result);
    showDialog(
      context: context,
      builder: (BuildContext context) => ResultDialog(
        result: result,
      ),
    );
  }

  Future<void> launchURL(String url) async {
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

  Future<void> captureAndDecodeQRCode(BuildContext context) async {
    isLoading.value = true;
    if (cameraController.value == null ||
        !cameraController.value!.value.isInitialized) {
      showFailedSnackBar('دوربین آماده نیست.');
      return;
    }
    try {
      final XFile picture = await cameraController.value!.takePicture();
      final bytes = await picture.readAsBytes();
      historyQrHelper.imageBytesForSave = bytes;
      final qrReader = EasyQRCodeReader();
      final decodedResult = await qrReader.decode(bytes);
      if (decodedResult != null) {
        if (!context.mounted) return;
        showResultDialog(context, decodedResult);
        isLoading.value = false;
      } else {
        showFailedSnackBar(' کد QR یافت نشد');
        isLoading.value = false;
      }
    } catch (e) {
      showFailedSnackBar('خطا در اسکن کد QR: $e');
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
        historyQrHelper.imageBytesForSave = bytes;
        final qrReader = EasyQRCodeReader();
        final decodedResult = await qrReader.decode(bytes);
        if (decodedResult != null) {
          if (!context.mounted) return;
          showResultDialog(context, decodedResult);
          isLoading.value = false;
        } else {
          showFailedSnackBar('کد QR یافت نشد');
          isLoading.value = false;
        }
      } else {
        showFailedSnackBar('تصویری انتخاب نشد.');
        isLoading.value = false;
      }
    } catch (e) {
      showFailedSnackBar('خطا در انتخاب تصویر: $e');
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

      showFailedSnackBar('در حال تغییر دوربین...');
      try {
        selectedCameraIndex.value =
            (selectedCameraIndex.value + 1) % cameras.length;
        await _setupCameraController(cameras[selectedCameraIndex.value]);
      } catch (e) {
        handleError(e);
      } finally {
        isCameraReady.value = true;
        showFailedSnackBar('');

        isSwitchCamera = false;
      }
    } else {
      showFailedSnackBar('فقط یک دوربین در دسترس است.');
    }
  }

  void showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => const DeleteAllDialog(),
    );
  }

  void showDeleteDialog(BuildContext context, String id, bool isScanHistory) {
    showDialog(
      context: context,
      builder: (BuildContext context) => DeleteDialog(
        id: id,
        isScanHistory: isScanHistory,
      ),
    );
  }

  void showFailedSnackBar(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: kDangerColor,
        textColor: kTextColor,
        fontSize: 16.0);
  }

  void showSuccessSnackBar(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: kSuccessColor,
        textColor: kTextColor,
        fontSize: 16.0);
  }

  void handleError(dynamic e) {
    showFailedSnackBar('خطایی رخ داده است: $e');
  }
}
