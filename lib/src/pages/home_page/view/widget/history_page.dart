import 'dart:typed_data';

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
      length: 2, // Number of tabs
      child: SafeArea(
        child: Column(
          children: [
            // AppBar with TabBar
            const Column(
              children: [
                Padding(
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
                TabBar(
                  tabs: [
                    Tab(text: 'Scanned QR Codes'), // Tab 1
                    Tab(text: 'Generated QR Codes'), // Tab 2
                  ],
                ),
              ],
            ),
            // TabBarView with content
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Show Generated QR Codes History
                  _buildHistoryList<QrCodeScanHistory>(
                    future: controller.getAllHistory(),
                    itemBuilder: (context, history) {
                      return _buildHistoryTile(
                          history, history.text, history.date, history.photo,
                          () async {
                        await controller.deleteHistory(history.id);
                        if (!context.mounted) return;
                        _showSnackBar(context, "Item deleted!");
                        Get.forceAppUpdate();
                      });
                    },
                  ),
                  // Tab 2: Show Scanned QR Codes History
                  _buildHistoryList<QrCodeGenerateHistory>(
                    future: controller.getAllGenerationHistory(),
                    itemBuilder: (context, history) {
                      return _buildHistoryTile(
                          history, history.text, history.date, history.photo,
                          () async {
                        await controller.deleteHistoryGeneration(history.id);
                        if (!context.mounted) return;
                        _showSnackBar(context, "Item deleted!");
                        Get.forceAppUpdate();
                      });
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

  // Generic builder for history lists (for both generated and scanned QR codes)
  Widget _buildHistoryList<T>({
    required Future<List<T>> future,
    required Widget Function(BuildContext context, T history) itemBuilder,
  }) {
    return FutureBuilder<List<T>>(
      future: future,
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
            return itemBuilder(context, history);
          },
        );
      },
    );
  }

  // Helper method to build a ListTile for each history entry
  Widget _buildHistoryTile(
    dynamic history,
    String text,
    DateTime date,
    Uint8List? photo,
    VoidCallback onDelete,
  ) {
    final formattedDate = DateFormat('yyyy/MM/dd – HH:mm:ss').format(date);

    return ListTile(
      title: Text(text),
      subtitle: Text(formattedDate), // Display formatted date
      leading: photo != null
          ? Image.memory(photo, width: 50, height: 50, fit: BoxFit.cover)
          : const Icon(Icons.image),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: onDelete,
      ),
    );
  }

  // Show a SnackBar with a message
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
