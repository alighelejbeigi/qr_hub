import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../qr_hub.dart';
import '../controller/home_page_controller.dart';

class HomePage extends GetView<HomePageController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(),
        bottomNavigationBar: _buildBottomNavigationBar(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _buildFloatingButton(),
      );

  // AppBar Method
  AppBar _buildAppBar(BuildContext context) => AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xffFDB624),
        title:  Obx(() => controller.titles[controller.selectedIndex.value]),
        actions: [
          /* IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => context.push(RouteNames.settingPage),
        ),*/
        ],
      );

  // Body Method
  Widget _buildBody() =>
      Obx(() => controller.pages[controller.selectedIndex.value]);

  // Bottom Navigation Bar Method
  Widget _buildBottomNavigationBar(BuildContext context) => BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: const Color(0xff333333),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomBarButton(
              context: context,
              label: 'Generate',
              icon: Icons.qr_code_2,
              isSelected: controller.selectedIndex.value == 1,
              onTap: () {
                controller.onTabTapped(1);
                Get.forceAppUpdate();
              },
            ),
            const SizedBox(width: 58),
            _buildBottomBarButton(
              context: context,
              label: 'History',
              icon: Icons.history,
              isSelected: controller.selectedIndex.value == 0,
              onTap: () {
                controller.onTabTapped(0);
                Get.forceAppUpdate();
              },
            ),
          ],
        ),
      );

  // Bottom Bar Button Method
  Widget _buildBottomBarButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          border: isSelected
              ? const Border(
                  bottom: BorderSide(color: Color(0xffFDB624), width: 3),
                )
              : null,
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
          ],
        ),
      ),
    );
  }

  // Floating Button Method
  Widget _buildFloatingButton() {
    return FloatingActionButton(
      onPressed: () {
        Get.forceAppUpdate();
        controller.onTabTapped(2);
      },
      backgroundColor: const Color(0xffFDB624),
      shape: const CircleBorder(),
      elevation: 4,
      child: Image.asset(
        'assets/logo.png',
        package: 'qr_hub',
        fit: BoxFit.cover,
        height: 30,
        width: 30,
      ),
    );
  }
}

