import 'package:flutter/material.dart';
import 'package:get/get.dart';



import '../repositories/home_page_repository.dart';

class HomePageController extends GetxController {
  final HomePageRepository _repository = HomePageRepository();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // مدیریت ایندکس صفحه
  var selectedIndex = 0.obs;

  // لیست صفحات
  final pages = [
    const Center(child: Text('Home Page')),
    const Center(child: Text('Search Page')),
    const Center(child: Text('Profile Page')),
  ];

  // تغییر صفحه
  void onTabTapped(int index) {
    selectedIndex.value = index;
  }

}
