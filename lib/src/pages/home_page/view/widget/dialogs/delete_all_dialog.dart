import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_hub/src/pages/home_page/controller/home_page_controller.dart';

class DeleteAllDialog extends GetView<HomePageController> {
  const DeleteAllDialog({super.key});

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('حذف همه QR ها'),
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
              await controller.historyQrHelper.deleteAllHistory();
              if (!context.mounted) return;
              // getAllHistory();
              //generateQRCode();
              controller.showSuccesSnackBar('همه QR کد ها پاک شد');
              Get.forceAppUpdate();
              Navigator.of(context).pop();
            },
            child: const Text('حذف'),
          ),
        ],
      );
}
