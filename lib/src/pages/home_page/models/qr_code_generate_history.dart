import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'qr_code_generate_history.g.dart';

@HiveType(typeId: 1)
class QrCodeGenerateHistory extends HiveObject {
  @HiveField(0)
  final String text; // متن QR Code

  @HiveField(1)
  final DateTime date; // تاریخ تولید

  @HiveField(2)
  final String id;

  @HiveField(3)
  final Uint8List? photo; // تصویر QR Code

  QrCodeGenerateHistory({
    required this.text,
    required this.date,
    required this.id,
    this.photo,
  });
}
