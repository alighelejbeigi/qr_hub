import 'dart:typed_data';

import 'package:hive_flutter/adapters.dart';


part 'qr_code_scan_history.g.dart';

@HiveType(typeId: 0)
class QrCodeScanHistory extends HiveObject {
  @HiveField(0)
  final String text;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String id;

  @HiveField(3)
  final Uint8List? photo;

  QrCodeScanHistory({
    required this.text,
    required this.date,
    required this.id,
    this.photo,
  });
}
