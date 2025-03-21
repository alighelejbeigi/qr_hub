import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../../qr_hub.dart';
import '../../../shared/enum/qr_code_enum.dart';
import '../../controller/home_page_controller.dart';

class HistoryPage extends GetView<HomePageController> {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xff333333),
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: const Padding(
                padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: TabBar(
                  labelStyle:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  labelColor: Color(0xffFDB624),
                  unselectedLabelColor: Colors.white,
                  indicator: BoxDecoration(),
                  dividerHeight: 0,
                  tabs: [
                    Tab(text: 'کد های اسکن شده'), // Tab 1
                    Tab(text: 'کد های ساخته شده'), // Tab 2
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildHistoryList<QrCodeScanHistory>(
                    future: controller.historyQrHelper.getAllHistory(),
                    itemBuilder: (context, history) {
                      return _buildHistoryTile(
                          history: history,
                          context: context,
                          onDelete: () async {
                            controller.showDeleteDialog(
                              context,
                              history.id,
                              true,
                            );
                          });
                    },
                  ),
                  _buildHistoryList<QrCodeGenerateHistory>(
                    future:
                        controller.historyQrHelper.getAllGenerationHistory(),
                    itemBuilder: (context, history) {
                      return _buildHistoryGenerationTile(
                          history: history,
                          onDelete: () async {
                            controller.showDeleteDialog(
                              context,
                              history.id,
                              false,
                            );
                          },
                          context: context);
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

  Widget _buildHistoryTile({
    required final QrCodeScanHistory history,
    required VoidCallback onDelete,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () => context.push(
          '${RouteNames.detailsPage}/${history.id}/${QRCodeAction.scanQRCode.id}'),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        color: const Color(0xff444444),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          title: Text(
            history.text,
            style: const TextStyle(color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            controller.historyQrHelper.convertToJalali(history.date),
            style: const TextStyle(color: Colors.grey),
          ),
          leading: history.photo != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(history.photo!,
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
      ),
    );
  }

  Widget _buildHistoryGenerationTile({
    required final QrCodeGenerateHistory history,
    required VoidCallback onDelete,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () => context.push(
          '${RouteNames.detailsPage}/${history.id}/${QRCodeAction.createQRCode.id}'),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        color: const Color(0xff444444),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          title: Text(
            history.text,
            style: const TextStyle(color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            controller.historyQrHelper.convertToJalali(history.date),
            style: const TextStyle(color: Colors.grey),
          ),
          leading: history.photo != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(history.photo!,
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
      ),
    );
  }
}
