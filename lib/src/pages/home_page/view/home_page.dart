import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/home_page_controller.dart';

class HomePage extends GetView<HomePageController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Obx(() => controller.pages[controller.selectedIndex.value]),
        bottomNavigationBar: Obx(() => _buildBottomNavigationBar(context)),
      );

  Widget _buildBottomNavigationBar(BuildContext context) => Stack(
        clipBehavior: Clip.none,
        children: [
          BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,

            color: const Color(0xff333333),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBottomBarButton(
                  context: context,
                  label: 'History',
                  icon: Icons.history,
                  isSelected: controller.selectedIndex.value == 0,
                  onTap: () => controller.onTabTapped(0),
                ),
                _buildBottomBarButton(
                  context: context,
                  label: 'Generate',
                  icon: Icons.qr_code_2,
                  isSelected: controller.selectedIndex.value == 1,
                  onTap: () => controller.onTabTapped(1),
                ),
              ],
            ),
          ),
          _buildCenterButton(context),
        ],
      );

  Widget _buildBottomBarButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) =>
      ElevatedButton(
        onPressed: onTap,
        style: const ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Color(0xff333333)),
          shadowColor: WidgetStatePropertyAll(Colors.transparent),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xffFDB624) : Colors.white,
            ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xffFDB624) : Colors.white,
              ),
            ),
            if (isSelected)
              const DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xffFDB624),
                ),
                child: SizedBox(
                  width: 70,
                  height: 3,
                ),
              ),
          ],
        ),
      );

  Widget _buildCenterButton(BuildContext context) => Positioned(
        bottom: 45,
        left: MediaQuery.of(context).size.width / 2 - 40,
        child: ElevatedButton(
          onPressed: () => controller.onTabTapped(2), // عملکرد کلیک دکمه
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: const Color(0xffFDB624),
            padding: const EdgeInsets.all(15),
            elevation: 5,
          ),
          child: Image.asset(
            'assets/logo.png',
            package: 'qr_hub',
            fit: BoxFit.cover,
            height: 40,
            width: 40,
          ),
        ),
      );
}
