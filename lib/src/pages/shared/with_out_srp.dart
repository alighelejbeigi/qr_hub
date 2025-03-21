import 'package:flutter/cupertino.dart';

class TaskManager extends ChangeNotifier {
  List<String> tasks = [];

  void addTask(String task) {
    Database.openConnection();
    Database.addTask(task);
    Database.closeConnection();

    tasks.add(task);

    notifyListeners();
  }
}
















mixin Database {
  static void openConnection() {}

  static void addTask(String task) {}

  static void closeConnection() {}
}
