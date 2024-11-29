import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../../utils/app_bar.dart';
import '../../../utils/drawer.dart';
import '../controller/home_page_controller.dart';

class HomePage extends GetView<HomePageController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        key: controller.scaffoldKey,
        backgroundColor: const Color(0xffF9E8D9),
        appBar: CustomAppBar(
          title: 'خانه',
          onPressed: () => controller.scaffoldKey.currentState?.openDrawer(),
        ),
       // drawer: const CustomDrawer(routeNames: RouteNames.homePage),
        body: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 /* Image.asset(
                    'assets/sample.png',
                    package: 'holoo',
                  ),*/
                ],
              )
            ],
          ),
        ),
      );
}
