import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:verifyme/utils/notify.dart';
import 'controller.dart';

final TOTPController totpController = Get.find();

// 申请权限
Future<void> exportTOTP() async {
  if (await Permission.manageExternalStorage.request().isGranted) {
    exportTOTPList();
  } else {
    showNotification('Permission Denied',
        'Storage permission is required to export TOTP list.');
  }
}

// 导出TotpList
Future<void> exportTOTPList() async {
  try {
    final directory = Directory('/storage/emulated/0/Download');
    final file = File('${directory.path}/totp_list.json');
    final jsonString = jsonEncode(totpController.totpList);
    await file.writeAsString(jsonString);
    showNotification('Success', 'Exported to ${file.path}');
  } catch (e) {
    showNotification('Error', 'Failed to export TOTP list.');
  }
}

// 导入TotpList
Future<void> importTOTPList() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(jsonString);
      totpController.totpList
          .assignAll(jsonList.map((e) => Map<String, String>.from(e)).toList());
      totpController.saveTOTPList();
      totpController.onInit();
      showNotification('Success', 'TOTP imported successfully');
    } else {
      showNotification('Cancelled', 'File selection cancelled');
    }
  } catch (e) {
    showNotification('Error', 'Failed to import TOTP list');
  }
}
