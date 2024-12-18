import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../qr_hub.dart';
import '../../controller/home_page_controller.dart';

class HistoryPage extends GetView<HomePageController> {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<History>>(
      future: controller.getAllHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
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
            final formattedDate = DateFormat('yyyy/MM/dd – HH:mm:ss').format(history.date);

            return ListTile(
              title: Text(history.text),
              subtitle: Text(formattedDate), // تاریخ به‌فرمت خوانا
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  await controller.deleteHistory(history.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Item deleted!")),
                  );

                  // به‌روزرسانی لیست پس از حذف
                  Get.forceAppUpdate();
                },
              ),
            );
          },
        );
      },
    );
  }
}
