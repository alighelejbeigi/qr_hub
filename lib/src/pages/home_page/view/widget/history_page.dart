import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_hub/src/pages/home_page/models/qr_generate_dto.dart';
import '../../../../../qr_hub.dart';
import '../../../shared/enum/qr_code_enum.dart';
import '../../controller/home_page_controller.dart';
import '../../models/qr_scan_dto.dart';

class HistoryPage extends GetView<HomePageController> {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DefaultTabController(
        length: 2, // Number of tabs
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
                  indicator: BoxDecoration(),
                  dividerHeight: 0,
                  // Disable the bottom indicator or selection highlight
                  tabs: [
                    Tab(text: 'کد های اسکن شده'), // Tab 1
                    Tab(text: 'کد های ساخته شده'), // Tab 2
                  ],
                ),
              ),
            ),
            // TabBarView with content
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Show Scanned QR Codes History
                  _buildHistoryList<QrScan>(
                    future: controller.fetchUserScans(),
                    itemBuilder: (context, history) {
                      return _buildHistoryTile(
                          history: history,
                          context: context,
                          onDelete: () async {
                            controller.showDeleteDialog(
                                context: context,
                                id: history.id,
                                isScanHistory: true,
                                fileId: history.fileId);
                          });
                    },
                  ),
                  // Tab 2: Show Generated QR Codes History
                  _buildHistoryList<QrGenerate>(
                    future: controller.fetchUserGenerate(),
                    itemBuilder: (context, history) {
                      return _buildHistoryGenerationTile(
                        history: history,
                        onDelete: () async {
                          controller.showDeleteDialog(
                            context: context,
                            id: history.id,
                            isScanHistory: false,
                            fileId: history.fileId,
                          );
                        },
                        context: context,
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
          return Center(child: Text("اررور: ${snapshot.error}"));
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
  Widget _buildHistoryTile({
    required final QrScan history,
    required VoidCallback onDelete,
    required BuildContext context,
  }) {
    final formattedDate =
        DateFormat('yyyy/MM/dd – HH:mm:ss').format(history.date);

    return GestureDetector(
      onTap: () => context.push(
          '${RouteNames.detailsPage}/${history.id}/${QRCodeAction.scanQRCode.id}'),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        color: const Color(0xff444444),
        // Slightly lighter background for list tile
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(4),
          title: Text(
            history.text,
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            formattedDate,
            style: const TextStyle(color: Colors.grey),
          ),
          leading: history.photoUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: Image.network(
                      history.photoUrl != null ? history.photoUrl! : '',
                      fit: BoxFit.cover,
                    ),
                  ),
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
      ),
    );
  }

  Widget _buildHistoryGenerationTile({
    required final QrGenerate history,
    required VoidCallback onDelete,
    required BuildContext context,
  }) {
    final formattedDate =
        DateFormat('yyyy/MM/dd – HH:mm:ss').format(history.date);

    return GestureDetector(
      onTap: () => context.push(
          '${RouteNames.detailsPage}/${history.id}/${QRCodeAction.createQRCode.id}'),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        color: const Color(0xff444444),
        // Slightly lighter background for list tile
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          title: Text(
            history.text,
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            formattedDate,
            style: const TextStyle(color: Colors.grey),
          ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(history.qrImageUrl,
                width: 50, height: 50, fit: BoxFit.cover),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
        ),
      ),
    );
  }

// Show a SnackBar with a message
}
