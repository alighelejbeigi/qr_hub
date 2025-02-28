import 'dart:io';

import 'package:easy_qr_code/easy_qr_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_hub/src/pages/home_page/models/qr_generate_dto.dart';
import 'package:qr_hub/src/pages/home_page/models/qr_scan_dto.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../../../qr_hub.dart';
import '../../../infrastructure/app_writer.dart';

class DetailsController extends GetxController {
  DetailsController({
    required this.id,
    required this.type,
  });

  String id;
  String type;
  QrScan? qrScan;
  QrGenerate? qrGenerate;
  RxBool isLoading = false.obs;
  final qrGenerator = EasyQRCodeGenerator();
  final String databaseId = '66cadb580006a39e25e7';

  final String collectionScanId = '67be17330001d602b00f';
  final String collectionGenerateId = '67be1e410031415ab6c6';

  @override
  void onInit() {
    if (type == '1') {
      getQrGenerateDetails(id);
    } else {
      getQrScanDetails(id);
    }
    super.onInit();
  }

  Future<QrScan?> getQrScanDetails(String documentId) async {
    isLoading.value = true;
    try {
      final response = await appwriteService.databases.getDocument(
        databaseId: databaseId,
        collectionId: collectionScanId,
        documentId: documentId,
      );

      qrScan = QrScan.fromJson(response.data);
      isLoading.value = false;
    } catch (e) {
      print("Error fetching document: $e");
      isLoading.value = false;
      return null;

    }
  }

  Future<QrGenerate?> getQrGenerateDetails(String documentId) async {
    isLoading.value = true;
    try {
      final response = await appwriteService.databases.getDocument(
        databaseId: databaseId,
        collectionId: collectionGenerateId,
        documentId: documentId,
      );

      qrGenerate = QrGenerate.fromJson(response.data);
      isLoading.value = false;
    } catch (e) {
      print("Error fetching document: $e");
      isLoading.value = false;
      return null;
    }
  }

/*  Future<void> getOneItemScan() async {
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
  }*/

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
        final image = await appwriteService.storage.getFilePreview(
          bucketId: '67c1719c000278a3d248',
          fileId: qrGenerate!.fileId,
        );
        await file.writeAsBytes(image);
      } else {
        final image = await appwriteService.storage.getFilePreview(
          bucketId: '67c1719c000278a3d248',
          fileId: qrScan!.fileId!,
        );
        await file.writeAsBytes(image);
      }
      _showSuccesSnackBar('در دانلود ها ذخیره شد');
    } catch (e) {
      _showFaildSnackBar('خطا در ذخیره فایل');
    }
  }

  void copyToClipboard() {
    if (type == '1') {
      Clipboard.setData(ClipboardData(text: qrGenerate!.text));
    } else {
      Clipboard.setData(ClipboardData(text: qrScan!.text));
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
      final image = await appwriteService.storage.getFilePreview(
        bucketId: '67c1719c000278a3d248',
        fileId: qrGenerate!.fileId,
      );
      qrGenerator.shareQRCodeFromBytes(qrBytes: image);
    } else {
      final image = await appwriteService.storage.getFilePreview(
        bucketId: '67c1719c000278a3d248',
        fileId: qrScan!.fileId!,
      );
      qrGenerator.shareQRCodeFromBytes(qrBytes: image);
    }
  }
}
