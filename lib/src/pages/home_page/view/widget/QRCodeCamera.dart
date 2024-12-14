/*
import 'package:camera/camera.dart';
import 'package:easy_qr_code/easy_qr_code.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class QRCodeCameraController extends GetxController {
  CameraController? cameraController;
  late List<CameraDescription> cameras;
  var qrCodeResult = ''.obs;
  var isCameraReady = false.obs;
  var selectedCameraIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    initializeCamera();
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
        cameraController = CameraController(
          cameras[selectedCameraIndex.value],
          ResolutionPreset.medium,
        );
        await cameraController!.initialize();
        isCameraReady.value = true;
      } else {
        qrCodeResult.value = 'دوربینی در دسترس نیست.';
      }
    } catch (e) {
      handleError(e);
    }
  }

  Future<void> captureAndDecodeQRCode() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      qrCodeResult.value = 'دوربین آماده نیست.';
      return;
    }

    try {
      final XFile picture = await cameraController!.takePicture();
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
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
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

  void switchCamera() {
    if (cameras.length > 1) {
      selectedCameraIndex.value = (selectedCameraIndex.value + 1) % cameras.length;
      initializeCamera();
    } else {
      qrCodeResult.value = 'فقط یک دوربین در دسترس است.';
    }
  }

  void handleError(dynamic e) {
    qrCodeResult.value = 'خطایی رخ داده است: $e';
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }
}

class QRCodeCamera extends StatelessWidget {
  final QRCodeCameraController controller = Get.put(QRCodeCameraController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffFDB624),
        title: Text('Custom QR Code Scanner'),
      ),
      body: Stack(
        children: [
          Obx(() => controller.isCameraReady.value && controller.cameraController != null
              ? CameraPreview(controller.cameraController!)
              : Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Color(0xffFDB624)),
            ),
          )),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(flex: 2),
                FloatingActionButton(
                  heroTag: 'pickGalleryImage',
                  backgroundColor: Color(0xffFDB624),
                  onPressed: controller.pickImageFromGallery,
                  child: Icon(Icons.image, color: Colors.white),
                ),
                Spacer(flex: 1),
                FloatingActionButton(
                  heroTag: 'captureQRCode',
                  backgroundColor: Color(0xffFDB624),
                  onPressed: controller.captureAndDecodeQRCode,
                  child: Icon(Icons.camera_alt, color: Colors.white),
                ),
                Spacer(flex: 1),
                FloatingActionButton(
                  heroTag: 'switchCamera',
                  backgroundColor: Color(0xffFDB624),
                  onPressed: controller.switchCamera,
                  child: Icon(Icons.switch_camera, color: Colors.white),
                ),
                Spacer(flex: 2),
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
              style: TextStyle(
                color: Colors.white,
                backgroundColor: Colors.black54,
                fontSize: 16,
              ),
            )),
          ),
        ],
      ),
    );
  }
}
*/
