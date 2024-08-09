import 'package:get/get.dart';

class QRCodeController extends GetxController {
  var qrCode = ''.obs;

  void setQRCode(String code) {
    qrCode.value = code;
  }
}
