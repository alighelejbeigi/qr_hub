import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_hub/src/pages/home_page/controller/home_page_controller.dart';

class GeneratePage extends GetView<HomePageController> {
  const GeneratePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xffF5F5F5),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildTextField(),
                  const SizedBox(height: 24),

                  _buildGenerateQRCodeButton(),
                  const SizedBox(height: 24),

                  Obx(
                    () => controller.imageBytes.value.isNotEmpty
                        ? Image.memory(controller.imageBytes.value)
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 24),
                  // Save and Share Buttons
                  _buildSaveAndShareButtons(),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildSaveAndShareButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSaveShareButton(
          icon: Icons.save,
          tooltip: 'Save QR Code',
          onPressed: controller.saveQRCodeImage,
        ),
        const SizedBox(width: 20),
        _buildSaveShareButton(
          icon: Icons.share,
          tooltip: 'Share QR Code',
          onPressed: controller.shareQRCodeImage,
        ),
      ],
    );
  }

  Widget _buildSaveShareButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffFDB624),
        borderRadius: BorderRadius.circular(50),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: const Color(0xff333333)),
        // White icon
        tooltip: tooltip,
        iconSize: 25,
        padding: const EdgeInsets.all(8),
      ),
    );
  }

  Widget _buildTextField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TextField(
        controller: controller.textController,
        decoration: InputDecoration(
          labelText: 'Enter data for QR Code',
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  // Button to generate the QR Code
  Widget _buildGenerateQRCodeButton() {
    return ElevatedButton(
      onPressed: () => controller.generateQRCode(),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xffFDB624),
        // Primary color for the button
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
      ),
      child: const Text(
        'Generate QR Code',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
