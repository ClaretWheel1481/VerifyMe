import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:verifyme/utils/notify.dart';
import 'controller.dart';

final GenerateController totpController = Get.find();

// 申请权限
Future<void> export() async {
  if (await _requestPermission()) {
    exportList();
  } else {
    showNotification('Storage permission is required to export');
  }
}

// 请求权限
Future<bool> _requestPermission() async {
  if (Platform.isAndroid) {
    return await Permission.manageExternalStorage.request().isGranted;
  } else if (Platform.isIOS) {
    return await Permission.storage.request().isGranted;
  }
  return false;
}

// 导出TotpList
Future<void> exportList() async {
  try {
    final directory = await _getDirectory();
    final file = File('${directory.path}/totp_list.json');
    final jsonString = jsonEncode(totpController.totpList);
    await file.writeAsString(jsonString);
    showNotification('Exported to ${file.path}');
  } catch (e) {
    showNotification('Failed to export data: $e');
  }
}

// 获取目录
Future<Directory> _getDirectory() async {
  if (Platform.isAndroid) {
    return Directory('/storage/emulated/0/Download');
  } else if (Platform.isIOS) {
    return await getApplicationDocumentsDirectory();
  }
  showNotification('Unsupported platform');
  throw UnsupportedError('Unsupported platform');
}

// 导入List
Future<void> importList() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(jsonString);
      totpController.totpList.assignAll(
        jsonList.map((e) => Map<String, dynamic>.from(e)).toList(),
      );
      totpController.saveList();
      totpController.onInit();
      showNotification('Imported successfully');
    } else {
      showNotification('File selection cancelled');
    }
  } catch (e) {
    showNotification('Failed to import');
  }
}
