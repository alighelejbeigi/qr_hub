import 'package:appwrite/appwrite.dart';

class AppwriteService {
  late Client client;
  late Account account;
  late Databases databases;
  late Storage storage;

  AppwriteService() {
    client = Client()
        .setEndpoint('https://cloud.appwrite.io/v1')
        .setProject('66cad12e001f798dacf8');

    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
  }
}

final appwriteService = AppwriteService();
