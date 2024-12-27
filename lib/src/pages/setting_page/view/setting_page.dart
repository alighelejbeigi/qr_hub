import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/setting_controller.dart';

class SettingPage extends GetView<SettingController> {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xffFDB624),
          title: const Text('Setting'),
        ),
        body: const Center(
          child: Text('setting'),
        ),
      );
}
