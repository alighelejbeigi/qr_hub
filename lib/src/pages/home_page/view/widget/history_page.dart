import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../qr_hub.dart';
import '../../controller/home_page_controller.dart';

class HistoryPage extends GetView<HomePageController> {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // تعداد تب‌ها
      child: SafeArea(
        child: Column(
          children: [
            // AppBar with TabBar (without Scaffold)
            Container(
             // color: Theme.of(context).primaryColor,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'History',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const TabBar(
                    tabs: [
                      Tab(text: 'Generated QR Codes'), // Tab 1
                      Tab(text: 'Scanned QR Codes'), // Tab 2
                    ],
                  ),
                ],
              ),
            ),
            // TabBarView with content
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Show Generated QR Codes History
                  FutureBuilder<List<History>>(
                    future: controller.getAllHistory(), // Get history of generated QR codes
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }

                      final historyList = snapshot.data ?? [];

                      return ListView.builder(
                        itemCount: historyList.length,
                        itemBuilder: (context, index) {
                          final history = historyList[index];

                          // Format date for display
                          final formattedDate = DateFormat('yyyy/MM/dd – HH:mm:ss')
                              .format(history.date);

                          return ListTile(
                            title: Text(history.text),
                            subtitle: Text(formattedDate), // Display formatted date
                            leading: history.photo != null
                                ? Image.memory(
                              history.photo!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                                : const Icon(Icons.image),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await controller.deleteHistory(history.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Item deleted!")),
                                );

                                // Update list after deletion
                                Get.forceAppUpdate();
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // Tab 2: Show Scanned QR Codes History
                  FutureBuilder<List<QrCodeGenerationHistory>>(
                    future: controller.getAllGenerationHistory(),
                    // Get history of scanned QR codes
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }

                      final historyList = snapshot.data ?? [];

                      return ListView.builder(
                        itemCount: historyList.length,
                        itemBuilder: (context, index) {
                          final history2 = historyList[index];

                          // Format date for display
                          final formattedDate = DateFormat('yyyy/MM/dd – HH:mm:ss')
                              .format(history2.date);

                          return ListTile(
                            title: Text(history2.text),
                            subtitle: Text(formattedDate), // Display formatted date
                            leading: history2.qrImage != null
                                ? Image.memory(
                              history2.qrImage!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                                : const Icon(Icons.image),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await controller.deleteHistoryGeneration(history2.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Item deleted!")),
                                );

                                // Update list after deletion
                                Get.forceAppUpdate();
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
