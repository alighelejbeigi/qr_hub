import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'history.g.dart';

@HiveType(typeId: 0)
class History extends HiveObject {
  @HiveField(0)
  final String text;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String id;

  @HiveField(3)
  final Uint8List? photo; // اضافه کردن فیلد تصویر

  History({
    required this.text,
    required this.date,
    required this.id,
    this.photo,
  });
}
