import 'package:get/get.dart';

import '../controller/details_controller.dart';

class DetailsBindings extends Bindings {
  String id;
  String type;

  DetailsBindings({
    required this.id,
    required this.type,
  });

  @override
  void dependencies() {
    Get.lazyPut(
      () => DetailsController(
        id: id,
        type: type,
      ),
    );
  }
}
