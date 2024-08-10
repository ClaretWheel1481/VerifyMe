import 'package:get/get.dart';
import 'package:otp/otp.dart';
import 'dart:async';
import 'package:get_storage/get_storage.dart';

class TOTPController extends GetxController {
  var totpList = <Map<String, String>>[].obs;
  Timer? timer;
  final box = GetStorage();
  var progress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadTOTPList();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      updateProgress();
      refreshTOTP();
    });
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }

  void addTOTP(String accountName, String secret, String algorithm) {
    int index = totpList.indexWhere((element) => element['secret'] == secret);
    if (index != -1) {
      totpList[index] = {
        'accountName': accountName,
        'secret': secret,
        'algorithm': algorithm
      };
    } else {
      totpList.add({
        'accountName': accountName,
        'secret': secret,
        'algorithm': algorithm
      });
    }
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

  String generateTOTP(String secret, String algorithm) {
    Algorithm algo;
    switch (algorithm) {
      case 'SHA-256':
        algo = Algorithm.SHA256;
        break;
      case 'SHA-512':
        algo = Algorithm.SHA512;
        break;
      case 'SHA-1':
      default:
        algo = Algorithm.SHA1;
    }
    return OTP.generateTOTPCodeString(
        secret, DateTime.now().millisecondsSinceEpoch,
        interval: 30, length: 6, algorithm: algo, isGoogle: true);
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

  void updateProgress() {
    final seconds = DateTime.now().second;
    progress.value = 1 - (seconds % 30) / 30;
  }
}
