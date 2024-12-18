import 'package:hive/hive.dart';

part 'history.g.dart';

@HiveType(typeId: 0)
class History extends HiveObject {
  @HiveField(0)
  final String text;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String id; // اضافه کردن ID

  History({
    required this.text,
    required this.date,
    required this.id,
  });
}
