import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_hub/src/pages/home_page/controller/home_page_controller.dart';

class GeneratePage extends GetView<HomePageController> {
  const GeneratePage({super.key});

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          color: const Color(0xff868686),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildTextField(),
                    const SizedBox(height: 24),
                    _buildGenerateQRCodeButton(),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Obx(
                          () => controller.imageBytes.value != null
                              ? Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: _containerDecoration(),
                                    child: Image.memory(
                                      controller.imageBytes.value!,
                                      height: 200,
                                      width: 200,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.error, size: 50),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        )
                      ],
                    ),
                    const SizedBox(height: 24),
                    Obx(
                      () => controller.imageBytes.value != null
                          ? _buildSaveAndShareButtons()
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  BoxDecoration _containerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha((0.1 * 255).toInt()),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildSaveAndShareButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButton(
          label: 'ذخیره',
          icon: Icons.save_alt,
          onPressed: controller.saveQRCodeToDownloads,
        ),
        const SizedBox(width: 10),
        _buildButton(
          label: 'اشتراک ‌گذاری',
          icon: Icons.share,
          onPressed: controller.shareQRCodeImage,
        ),
      ],
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xffFDB624),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
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
        onChanged: (value) {
          Get.forceAppUpdate();
        },
        decoration: InputDecoration(
          label: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'متن خود را برای ساخت کد QR وارد کنید',
                style: TextStyle(
                  backgroundColor: Colors.white,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
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

  Widget _buildGenerateQRCodeButton() {
    return ElevatedButton(
      onPressed: controller.textController.text.isNotEmpty
          ? () => controller.generateQRCode()
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xffFDB624),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
      ),
      child: const Text(
        'ساخت کد QR',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
