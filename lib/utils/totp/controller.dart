import 'package:base32/base32.dart';
import 'package:get/get.dart';
import 'package:otp/otp.dart';
import 'dart:async';
import 'package:get_storage/get_storage.dart';

class TOTPController extends GetxController {
  var totpList = <Map<String, String>>[].obs;
  Timer? timer;
  final box = GetStorage();
  var progress = 0.0.obs;
  var remainingSeconds = 30.obs;

  @override
  void onInit() {
    super.onInit();
    loadTOTPList();
    if (totpList.isNotEmpty) {
      startTimer();
    }
    updateProgress();
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }

  bool addTOTP(String accountName, String secret, String algorithm) {
    if (_isValidBase32(secret)) {
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
        if (totpList.length == 1) {
          startTimer();
        }
      }
      saveTOTPList();
      refreshTOTP();
      return true;
    }
    return false;
  }

  void deleteTOTP(int index) {
    totpList.removeAt(index);
    saveTOTPList();
    if (totpList.isEmpty) {
      stopTimer();
    }
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

  bool _isValidBase32(String input) {
    try {
      base32.decode(input);
      return true;
    } catch (e) {
      return false;
    }
  }

  void updateProgress() {
    final seconds = DateTime.now().second;
    progress.value = 1 - (seconds % 30) / 30;
    remainingSeconds.value = 30 - (seconds % 30);
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      updateProgress();
      refreshTOTP();
    });
  }

  void stopTimer() {
    timer?.cancel();
  }
}
