import 'package:get/get.dart';
import 'package:otp/otp.dart';
import 'dart:async';
import 'package:get_storage/get_storage.dart';

class TOTPController extends GetxController {
  var totpList = <Map<String, String>>[].obs;
  Timer? timer;
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    loadTOTPList();
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
    saveTOTPList();
    refreshTOTP();
  }

  void deleteTOTP(int index) {
    totpList.removeAt(index);
    saveTOTPList();
  }

  void refreshTOTP() {
    totpList.refresh();
  }

  String generateTOTP(String secret) {
    return OTP.generateTOTPCodeString(
        secret, DateTime.now().millisecondsSinceEpoch,
        interval: 30, length: 6, algorithm: Algorithm.SHA1, isGoogle: true);
  }

  void saveTOTPList() {
    box.write('totpList', totpList.toList());
  }

  void loadTOTPList() {
    List<dynamic>? storedList = box.read('totpList');
    if (storedList != null) {
      totpList.assignAll(
          storedList.map((e) => Map<String, String>.from(e)).toList());
    }
  }
}
