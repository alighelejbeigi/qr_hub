import 'dart:io';

import 'package:easy_qr_code/easy_qr_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../../../qr_hub.dart';

class DetailsController extends GetxController {
  DetailsController({
    required this.id,
    required this.type,
  });

  String id;
  String type;
  QrCodeScanHistory? itemScan;
  QrCodeGenerateHistory? itemGenerait;
  RxBool isLoading = false.obs;
  final qrGenerator = EasyQRCodeGenerator();

  @override
  void onInit() {
    if (type == '1') {
      getOneItemGenerait();
    } else {
      getOneItemScan();
    }
    super.onInit();
  }

  Future<void> getOneItemScan() async {
    isLoading.value = true;
    final box = await Hive.openBox<QrCodeScanHistory>('historyBox');
    itemScan = box.get(id);
    isLoading.value = false;
  }

  Future<void> getOneItemGenerait() async {
    isLoading.value = true;
    final box =
        await Hive.openBox<QrCodeGenerateHistory>('qrCodeGenerationHistoryBox');
    itemGenerait = box.get(id);
    isLoading.value = false;
  }

  Future<void> saveQRCodeToDownloads() async {
    try {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        _showFaildSnackBar('مجوز ذخیره سازی رد شد');
        return;
      }
      final customDir = Directory('/storage/emulated/0/Download');
      String filePath = '${customDir.path}/easyQrCode_${const Uuid().v4()}.png';
      final file = File(filePath);
      if (type == '1') {
        await file.writeAsBytes(itemGenerait!.photo!);
      } else {
        await file.writeAsBytes(itemScan!.photo!);
      }
      _showSuccesSnackBar('در دانلود ها ذخیره شد');
    } catch (e) {
      _showFaildSnackBar('خطا در ذخیره فایل');
    }
  }

  void copyToClipboard() {
    if (type == '1') {
      Clipboard.setData(ClipboardData(text: itemGenerait!.text));
    } else {
      Clipboard.setData(ClipboardData(text: itemScan!.text));
    }
    _showSuccesSnackBar('متن کپی شد.');
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

  bool isValidUrl(String url) {
    const urlPattern = r'^(https?:\/\/)?'
        r'(([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,6})'
        r'(\/[^\s]*)?$';
    final regex = RegExp(urlPattern);
    return regex.hasMatch(url);
  }

  Future<void> launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  // Method to share generated QR code image
  Future<void> shareQRCodeImage() async {
    if (type == '1') {
      qrGenerator.shareQRCodeFromBytes(qrBytes: itemGenerait!.photo!);
    } else {
      qrGenerator.shareQRCodeFromBytes(qrBytes: itemScan!.photo!);
    }
  }
}
