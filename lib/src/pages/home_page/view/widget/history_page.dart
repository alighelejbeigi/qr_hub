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
            const SizedBox(height: 16),
            // TabBar with a custom background, rounded borders, dark text
            Container(
              decoration: BoxDecoration(
                color: const Color(0xff333333),
                // Background color for the TabBar
                borderRadius: BorderRadius.circular(12), // Rounded corners
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              // Spacing on the sides
              child: const Padding(
                padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                // Padding around the TabBar
                child: TabBar(
                  labelStyle:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  labelColor: Color(0xffFDB624),
                  // Color for selected tab text
                  unselectedLabelColor: Colors.white,
                  // Color for unselected tab text
                  indicator: null,
                  // Disable the bottom indicator or selection highlight
                  tabs: [
                    Tab(text: 'Scanned QR Codes'), // Tab 1
                    Tab(text: 'Generated QR Codes'), // Tab 2
                  ],
                ),
              ),
            ),
            // TabBarView with content
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Show Scanned QR Codes History
                  _buildHistoryList<QrCodeScanHistory>(
                    future: controller.getAllHistory(),
                    itemBuilder: (context, history) {
                      return _buildHistoryTile(
                        history,
                        history.text,
                        history.date,
                        history.photo,
                        () async {
                          await controller.deleteHistory(history.id);
                          if (!context.mounted) return;
                          _showSnackBar(context, "Item deleted!");
                          Get.forceAppUpdate();
                        },
                      );
                    },
                  ),
                  // Tab 2: Show Generated QR Codes History
                  _buildHistoryList<QrCodeGenerateHistory>(
                    future: controller.getAllGenerationHistory(),
                    itemBuilder: (context, history) {
                      return _buildHistoryTile(
                        history,
                        history.text,
                        history.date,
                        history.photo,
                        () async {
                          await controller.deleteHistoryGeneration(history.id);
                          if (!context.mounted) return;
                          _showSnackBar(context, "Item deleted!");
                          Get.forceAppUpdate();
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

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: const Color(0xff444444),
      // Slightly lighter background for list tile
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          formattedDate,
          style: const TextStyle(color: Colors.grey),
        ),
        leading: photo != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(photo,
                    width: 50, height: 50, fit: BoxFit.cover),
              )
            : const Icon(
                Icons.image,
                color: Colors.white,
              ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }

  // Show a SnackBar with a message
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
