import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/details_controller.dart';

class DetailsPage extends GetView<DetailsController> {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) => PopScope(
        onPopInvokedWithResult: (didPop, result) {
          () async {
            Get.delete<DetailsController>();
            return true;
          };
        },
        child: Scaffold(
          backgroundColor: const Color(0xff606060),
          appBar: AppBar(
            backgroundColor: const Color(0xffFDB624),
            title: const Text('QR Code Details'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(
              () => controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Data Section
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha((0.1 * 255).toInt()), // تبدیل 0.1 به مقدار معادل در withAlpha
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),

                            ],
                            borderRadius: BorderRadius.circular(12.0),
                            //border: Border.all(color: Colors.white),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Data:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  // color: Colors.white
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              if (qrCodeScan())
                                Text(
                                  controller.itemScan?.text ??
                                      'No data available.',
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                )
                              else
                                Text(
                                  controller.itemGenerait?.text ??
                                      'No data available.',
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24.0),

                        // QR Code Image Section

                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha((0.1 * 255).toInt()), // تبدیل 0.1 به مقدار معادل در withAlpha
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),

                            ],
                          ),
                          child: Image.memory(
                            qrCodeScan()
                                ? controller.itemScan!.photo!
                                : controller.itemGenerait!.photo!,
                            height: 200,
                            width: 200,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error, size: 50),
                          ),
                        ),

                        const SizedBox(height: 24.0),

                        // Buttons Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                controller.saveQRCodeImage();
                              },
                              icon: const Icon(Icons.save_alt),
                              label: const Text('Save'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xffFDB624),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0, vertical: 12.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                controller.shareQRCodeImage();
                              },
                              icon: const Icon(Icons.share),
                              label: const Text('Share'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xffFDB624),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0, vertical: 12.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                controller.copyToClipboard();
                              },
                              icon: const Icon(Icons.copy),
                              label: const Text('Copy'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xffFDB624),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0, vertical: 12.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );

  bool qrCodeScan() {
    if (controller.type == '2') {
      return true;
    } else {
      return false;
    }
  }
}
