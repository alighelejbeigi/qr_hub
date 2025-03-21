import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/details_controller.dart';

class DetailsPage extends GetView<DetailsController> {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: PopScope(
          onPopInvokedWithResult: _handleOnPop,
          child: Scaffold(
            backgroundColor: const Color(0xff606060),
            appBar: _buildAppBar(),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Obx(
                () => controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : _buildContent(),
              ),
            ),
          ),
        ),
      );

  Future<bool> _handleOnPop(bool didPop, dynamic result) async {
    Get.delete<DetailsController>();
    return true;
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xffFDB624),
      title: const Text('جزئیات کد QR'),
    );
  }

  bool _qrCodeScan() => controller.type == '2';

  Widget _buildContent() {
    return SingleChildScrollView(
      controller: ScrollController(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildDataSection(),
          const SizedBox(height: 24.0),
          _buildQRCodeImageSection(),
          const SizedBox(height: 24.0),
          _buildButtonsSection(),
        ],
      ),
    );
  }

  Widget _buildDataSection() {
    final qrCodeData = _qrCodeScan()
        ? controller.itemScan?.text ?? 'اطلاعاتی وجود ندارد'
        : controller.itemGenerate?.text ?? 'اطلاعاتی وجود ندارد';

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: _containerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'اطلاعات کد QR:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          clickableResultText(qrCodeData),
        ],
      ),
    );
  }

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
            color: isValidUrls ? Colors.blue : Colors.black,
            decoration:
                isValidUrls ? TextDecoration.underline : TextDecoration.none,
            fontSize: 16),
      ),
    );
  }

  Widget _buildQRCodeImageSection() {
    final imageData = _qrCodeScan()
        ? controller.itemScan!.photo!
        : controller.itemGenerate!.photo!;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: _containerDecoration(),
      child: Image.memory(
        imageData,
        height: 200,
        width: 200,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.error, size: 50),
      ),
    );
  }

  Widget _buildButtonsSection() {
    return SingleChildScrollView(
      controller: ScrollController(),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const SizedBox(width: 10),
          _buildButton(
            label: 'ذخیره',
            icon: Icons.save_alt,
            onPressed: controller.saveQRCodeToDownloads,
          ),
          const SizedBox(width: 10),
          _buildButton(
            label: 'اشتراک گذاری',
            icon: Icons.share,
            onPressed: controller.shareQRCodeImage,
          ),
          const SizedBox(width: 10),
          _buildButton(
            label: 'کپی',
            icon: Icons.copy,
            onPressed: controller.copyToClipboard,
          ),
        ],
      ),
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
}
