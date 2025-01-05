import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../qr_hub.dart';

class DetailsController extends GetxController {
  DetailsController({
    required this.id,
    required this.type,
  });

  String id;
  String type;
  QrCodeScanHistory? itemScan;
  QrCodeGenerateHistory? itemGenerait;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    if(type == '1'){
      getOneItemGenerait();
    } else{
      getOneItemScan();
    }
    super.onInit();
  }

  Future<void> getOneItemScan() async {
    isLoading.value = true;
    final box = await Hive.openBox<QrCodeScanHistory>('historyBox');
    itemScan = box.get(id);
    isLoading.value = false;
  }

  Future<void> getOneItemGenerait() async {
    isLoading.value = true;
    final box =
        await Hive.openBox<QrCodeGenerateHistory>('qrCodeGenerationHistoryBox');
    itemGenerait = box.get(id);
    isLoading.value = false;
  }
}
