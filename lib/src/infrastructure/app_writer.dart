import 'package:appwrite/appwrite.dart';

class AppwriteService {
  late Client client;
  late Account account;

  AppwriteService() {
    client = Client()
        .setEndpoint('https://cloud.appwrite.io/v1') // لینک سرور
        .setProject('66cad12e001f798dacf8'); // آی‌دی پروژه

    account = Account(client);
  }
}




final appwriteService = AppwriteService();
