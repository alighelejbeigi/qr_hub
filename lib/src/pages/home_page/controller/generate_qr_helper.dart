import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:easy_qr_code/easy_qr_code.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../qr_hub.dart';
import 'home_page_controller.dart';

class GenerateQRHelper {
  GenerateQRHelper(this.controller);

  HomePageController controller;
  final TextEditingController textController = TextEditingController();
  final qrGenerator = EasyQRCodeGenerator();
  Rxn<Uint8List> imageBytes = Rxn();

  Future<Uint8List?> convertImageToBytes(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
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

  Future<void> saveHistoryGeneration(String result) async {
    final box =
        await Hive.openBox<QrCodeGenerateHistory>('qrCodeGenerationHistoryBox');

    final newHistory = QrCodeGenerateHistory(
      text: result,
      date: DateTime.now(),
      id: controller.uuid.v4(),
      photo: imageBytes.value,
    );

    await box.put(newHistory.id, newHistory);
  }

  Future<void> saveQRCodeToDownloads() async {
    try {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        controller.showFaildSnackBar('مجوز ذخیره سازی رد شد');
        return;
      }
      final customDir = Directory('/storage/emulated/0/Download');
      String filePath =
          '${customDir.path}/easyQrCode_${controller.uuid.v4()}.png';
      final file = File(filePath);
      await file.writeAsBytes(imageBytes.value!);
      controller.showSuccesSnackBar('در دانلود ها ذخیره شد');
    } catch (e) {
      controller.showFaildSnackBar('خطا در ذخیره فایل');
    }
  }

  Future<void> shareQRCodeImage() async {
    qrGenerator.shareQRCodeFromBytes(qrBytes: imageBytes.value!);
  }
}
