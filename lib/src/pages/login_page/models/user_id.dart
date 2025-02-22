import 'dart:typed_data';

import 'package:hive_flutter/adapters.dart';

part 'user_id.g.dart';

@HiveType(typeId: 2)
class UserId extends HiveObject {
  @HiveField(0)
  final String userId;

  UserId({
    required this.userId,
  });
}
