import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'qr_code_generation_history.g.dart';

@HiveType(typeId: 1)
class QrCodeGenerationHistory extends HiveObject {
  @HiveField(0)
  final String text; // متن QR Code

  @HiveField(1)
  final DateTime date; // تاریخ تولید

  @HiveField(2)
  final String id;

  @HiveField(3)
  final Uint8List? qrImage; // تصویر QR Code

  QrCodeGenerationHistory({
    required this.text,
    required this.date,
    required this.id,
    this.qrImage,
  });
}
