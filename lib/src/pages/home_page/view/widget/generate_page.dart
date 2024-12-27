import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_hub/src/pages/home_page/controller/home_page_controller.dart';

class GeneratePage extends GetView<HomePageController> {
  const GeneratePage({super.key});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          _buildTextField(),
          _buildGenerateQRCodeButton(),
          //Obx(() => controller.result.value),
          ...[
          Obx(
            () => Image.memory(controller.imageBytes.value),
          ),
        ],
          _buildSaveAndShareButtons(),
        ],
      );

  Widget _buildSaveAndShareButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: controller.saveQRCodeImage,
          icon: const Icon(Icons.save),
          tooltip: 'Save QR Code',
        ),
        IconButton(
          onPressed: controller.shareQRCodeImage,
          icon: const Icon(Icons.share),
          tooltip: 'Share QR Code',
        ),
      ],
    );
    }


  Widget _buildTextField() {
    return TextField(
      controller: controller.textController,
      decoration: const InputDecoration(
        labelText: 'Enter data for QR Code',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildGenerateQRCodeButton() {
    return ElevatedButton(
      onPressed: () => controller.generateQRCode(),
      child: const Text('Generate QR Code'),
    );
  }
}
