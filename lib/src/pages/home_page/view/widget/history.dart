import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../qr_hub.dart';
import '../../controller/home_page_controller.dart';
import '../../models/qr_code_generation_history.dart';

class HistoryPage extends GetView<HomePageController> {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // تعداد تب‌ها
      child: Scaffold(
        appBar: AppBar(
          title: const Text('History'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Generated QR Codes'), // تب اول
              Tab(text: 'Scanned QR Codes'), // تب دوم
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // تب اول: نمایش لیست تاریخچه تولید QR Code
            FutureBuilder<List<History>>(
              future: controller.getAllHistory(), // دریافت تاریخچه تولید
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

                    // قالب نمایش تاریخ
                    final formattedDate =
                    DateFormat('yyyy/MM/dd – HH:mm:ss').format(history.date);

                    return ListTile(
                      title: Text(history.text),
                      subtitle: Text(formattedDate), // تاریخ به‌فرمت خوانا
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

                          // به‌روزرسانی لیست پس از حذف
                          Get.forceAppUpdate();
                        },
                      ),
                    );
                  },
                );
              },
            ),
            // تب دوم: نمایش لیست تاریخچه اسکن QR Code
            FutureBuilder<List<QrCodeGenerationHistory>>(
              future: controller.getAllGenerationHistory(), // دریافت تاریخچه اسکن
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

                    // قالب نمایش تاریخ
                    final formattedDate =
                    DateFormat('yyyy/MM/dd – HH:mm:ss').format(history2.date);

                    return ListTile(
                      title: Text(history2.text),
                      subtitle: Text(formattedDate), // تاریخ به‌فرمت خوانا
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

                          // به‌روزرسانی لیست پس از حذف
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
    );
  }
}
