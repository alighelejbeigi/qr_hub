import 'dart:typed_data';

import 'package:hive_flutter/adapters.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../../qr_hub.dart';
import 'home_page_controller.dart';

class HistoryQrHelper {
  HistoryQrHelper(this.controller);
  HomePageController controller;

  Uint8List? imageBytesForSave;
  String convertToJalali(DateTime date) {
    final jalali = Jalali.fromDateTime(date);
    return '${jalali.year}/${jalali.month}/${jalali.day} - ${date.hour}:${date.minute}';
  }

  Future<void> saveHistoryRead(String result) async {
    final box = await Hive.openBox<QrCodeScanHistory>('historyBox');

    final newHistory = QrCodeScanHistory(
      text: result,
      date: DateTime.now(),
      id: controller.uuid.v4(),
      photo: imageBytesForSave,
    );

    await box.put(newHistory.id, newHistory);
  }

  Future<void> deleteHistoryGeneration(String id) async {
    final box2 =
        await Hive.openBox<QrCodeGenerateHistory>('qrCodeGenerationHistoryBox');
    await box2.delete(id);
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

  Future<void> deleteAllHistory() async {
    final box = await Hive.openBox<QrCodeScanHistory>('historyBox');
    await box.clear();
    final box2 =
        await Hive.openBox<QrCodeGenerateHistory>('qrCodeGenerationHistoryBox');
    await box2.clear();
  }

  Future<void> deleteHistory(String id) async {
    final box = await Hive.openBox<QrCodeScanHistory>('historyBox');
    await box.delete(id);
  }
}
