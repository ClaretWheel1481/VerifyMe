import 'package:get/get.dart';
import 'package:otp/otp.dart';
import 'dart:async';

class TOTPController extends GetxController {
  var totpList = <Map<String, String>>[].obs;
  Timer? timer;

  @override
  void onInit() {
    super.onInit();
    timer =
        Timer.periodic(const Duration(seconds: 30), (Timer t) => refreshTOTP());
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }

  void addTOTP(String accountName, String secret) {
    totpList.add({'accountName': accountName, 'secret': secret});
    refreshTOTP();
  }

  void refreshTOTP() {
    totpList.refresh();
  }

  String generateTOTP(String secret) {
    return OTP.generateTOTPCodeString(
        secret, DateTime.now().millisecondsSinceEpoch,
        interval: 30, length: 6, algorithm: Algorithm.SHA1, isGoogle: true);
  }
}
