import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_hub/src/pages/home_page/view/widget/history_page.dart';

import '../controller/home_page_controller.dart';
import 'widget/generate_page.dart';
import 'widget/main_page.dart';

class HomePage extends GetView<HomePageController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xff868686),
        appBar: _buildAppBar(context),
        body: Obx(()=>_mainBody()),
        bottomNavigationBar: _buildBottomNavigationBar(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _buildFloatingButton(),
      );

  Widget _mainBody() {

    if (controller.selectedIndex.value == 2) {
      return MainPage();
    } else if (controller.selectedIndex.value == 0) {
      return HistoryPage();
    } else {
      return GeneratePage();
    }
  }

  // AppBar Method
  AppBar _buildAppBar(BuildContext context) => AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xffFDB624),
        title: Obx(() => controller.titles[controller.selectedIndex.value]),
        actions: [
          /*  IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => context.push(RouteNames.settingPage),
        ),*/
          if (controller.selectedIndex.value == 0)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                controller.showDeleteAllDialog(context);
              },
            ),
        ],
      );

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
              label: 'ساخت کد',
              icon: Icons.qr_code_2,
              isSelected: controller.selectedIndex.value == 1,
              onTap: () {
                controller.onTabTapped(1);
                Get.forceAppUpdate();
              },
            ),
            const SizedBox(width: 50),
            _buildBottomBarButton(
              context: context,
              label: 'تاریخچه',
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
                  bottom: BorderSide(color: Color(0xffFDB624), width: 2),
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
