import 'package:flutter/cupertino.dart';
import 'package:qr_hub/src/pages/shared/with_out_srp.dart';

class DatabaseService {
  void addTaskToDatabase(String task) {
    Database.openConnection();
    Database.addTask(task);
    Database.closeConnection();
  }
}
class TaskRepository {
  final DatabaseService _dbService;

  TaskRepository(this._dbService);

  List<String> tasks = [];

  void addTask(String task) {
    tasks.add(task);
    _dbService.addTaskToDatabase(task);
  }
}

class TaskDomain extends ChangeNotifier {
  final TaskRepository _taskRepository;

  TaskDomain(this._taskRepository);

  void addTask(String task) {
    _taskRepository.addTask(task);
    notifyListeners();
  }
}
