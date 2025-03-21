import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_hub/src/pages/home_page/controller/home_page_controller.dart';

class DeleteDialog extends GetView<HomePageController> {
  const DeleteDialog({
    required this.id,
    required this.isScanHistory,
    super.key,
  });

  final String id;
  final bool isScanHistory;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('حذف یک مورد'),
        content: const Text('آیا مطمئن هستید که می خواهید حذف کنید؟'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('لغو'),
          ),
          TextButton(
            onPressed: () async {
              if (isScanHistory) {
                await controller.historyQrHelper.deleteHistory(id);
              } else {
                await controller.historyQrHelper.deleteHistoryGeneration(id);
              }
              if (!context.mounted) return;

              controller.showSuccessSnackBar("مورد انتخابی حذف شد");
              Get.forceAppUpdate();
              Navigator.of(context).pop();
            },
            child: const Text('حذف'),
          ),
        ],
      );
}
