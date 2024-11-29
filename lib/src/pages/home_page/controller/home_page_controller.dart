import 'package:flutter/material.dart';
import 'package:get/get.dart';



import '../repositories/home_page_repository.dart';

class HomePageController extends GetxController {
  final HomePageRepository _repository = HomePageRepository();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();


}
