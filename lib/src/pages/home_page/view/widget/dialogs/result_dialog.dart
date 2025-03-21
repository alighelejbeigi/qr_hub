import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

import '../../../controller/home_page_controller.dart';

class ResultDialog extends GetView<HomePageController> {
  const ResultDialog({
    required this.result,
    super.key,
  });

  final String result;

  @override
  Widget build(BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: const Color(0xffFDB624),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.qr_code_2,
              size: 50,
              color: Colors.white,
            ),
            const SizedBox(height: 10),
            const Text(
              'نتیجه اسکن',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            clickableResultText(result),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'باشه',
                style: TextStyle(
                  color: Color(0xffFDB624),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );

  Widget clickableResultText(String result) {
    bool isValidUrls = controller.isValidUrl(result);
    return GestureDetector(
      onTap: () {
        if (isValidUrls) {
          controller.launchURL(result);
        }
      },
      child: Text(
        result,
        style: TextStyle(
          color: isValidUrls ? Colors.blue : Colors.white,
          decoration:
              isValidUrls ? TextDecoration.underline : TextDecoration.none,
        ),
      ),
    );
  }
}
