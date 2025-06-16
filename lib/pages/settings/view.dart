import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:verifyme/l10n/generated/localizations.dart';
import 'package:verifyme/pages/settings/widgets.dart';
import 'package:verifyme/utils/generate/controller.dart';
import 'package:verifyme/utils/notify.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  final GenerateController totpController = Get.find();
  final GetStorage _box = GetStorage();
  String _themeMode = 'system';
  bool selectedMonet = true;
  late String _languageCode;

  Color pickerColor = const Color(0xff443a49);
  Color currentColor = const Color(0xff443a49);

  @override
  void initState() {
    super.initState();
    _themeMode = _box.read('themeMode') ?? 'system';
    _languageCode = _box.read('languageCode') ?? 'en';
    final int? storedColor = _box.read('colorSeed');
    if (storedColor != null) {
      currentColor = Color(storedColor);
    }
    if (Platform.isIOS) {
      selectedMonet = false;
    } else {
      selectedMonet = _box.read('monetStatus') ?? true;
    }
  }

  // 修改语言
  void _changeLanguage(String languageCode) async {
    Locale newLocale;
    if (languageCode.contains('_')) {
      final parts = languageCode.split('_');
      newLocale = Locale(parts[0], parts[1]);
    } else {
      newLocale = Locale(languageCode);
    }
    Get.updateLocale(newLocale);
    setState(() {
      _languageCode = languageCode;
    });
    _box.write('languageCode', languageCode);
  }

  // 保存主题
  void _saveThemeMode(String themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
    _box.write('themeMode', themeMode);
    Get.changeThemeMode(
      themeMode == 'system'
          ? ThemeMode.system
          : themeMode == 'light'
              ? ThemeMode.light
              : ThemeMode.dark,
    );
  }

  // 莫奈取色开关
  void onMonet(bool? value) {
    if (value == null) return;
    setState(() {
      selectedMonet = value;
    });
    _box.write('monetStatus', value);
    final msg = AppLocalizations.of(context).effective_after_reboot;
    showNotification(msg);
  }

  // 导出数据
  Future<void> export() async {
    if (await _requestPermission()) {
      exportList();
    } else {
      showNotification(AppLocalizations.of(context).no_storage_permission);
    }
  }

  // 导出TotpList
  Future<void> exportList() async {
    try {
      final directory = await _getDirectory();
      final file = File('${directory.path}/totp_list.json');
      final jsonString = jsonEncode(totpController.totpList);
      await file.writeAsString(jsonString);
      showNotification(
          '${AppLocalizations.of(context).export_to} ${file.path}');
    } catch (e) {
      showNotification(
          '${AppLocalizations.of(context).failed_to_export_data}: $e');
    }
  }

  // 获取目录
  Future<Directory> _getDirectory() async {
    if (Platform.isAndroid) {
      return Directory('/storage/emulated/0/Download');
    } else if (Platform.isIOS) {
      return await getApplicationDocumentsDirectory();
    }
    showNotification(AppLocalizations.of(context).unsupported_platform);
    throw UnsupportedError('Unsupported platform');
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

  // 更换颜色
  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  // 动态构建语言选项
  List<Widget> _buildLanguageList() {
    final languages = [
      {'code': 'de', 'name': 'Deutsch'},
      {'code': 'en', 'name': 'English'},
      {'code': 'es', 'name': 'Español'},
      {'code': 'fr', 'name': 'Français'},
      {'code': 'it', 'name': 'Italiano'},
      {'code': 'ru', 'name': 'Русский'},
      {'code': 'ja', 'name': '日本語'},
      {'code': 'zh', 'name': '中文 (简体)'},
      {'code': 'zh_TW', 'name': '中文 (繁体)'},
    ];

    return languages.map((language) {
      return ListTile(
        title: Text(language['name']!),
        onTap: () => _changeLanguage(language['code']!),
        selected: _languageCode == language['code'],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final bool isEnabled = !Platform.isIOS;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(loc.settings),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExpansionTile(
                leading: const Icon(Icons.language),
                title: Text(loc.language),
                children: [
                  ..._buildLanguageList(),
                ],
              ),
              ExpansionTile(
                leading: const Icon(Icons.light_mode),
                title: Text(loc.theme),
                children: [
                  ListTile(
                    leading: const Icon(Icons.brightness_auto),
                    title: Text(loc.follow_system),
                    onTap: () {
                      _saveThemeMode('system');
                    },
                    selected: _themeMode == 'system',
                  ),
                  ListTile(
                    leading: const Icon(Icons.light_mode),
                    title: Text(loc.light),
                    onTap: () {
                      _saveThemeMode('light');
                    },
                    selected: _themeMode == 'light',
                  ),
                  ListTile(
                    leading: const Icon(Icons.dark_mode),
                    title: Text(loc.dark),
                    onTap: () {
                      _saveThemeMode('dark');
                    },
                    selected: _themeMode == 'dark',
                  ),
                ],
              ),
              ListTile(
                enabled: isEnabled,
                leading: const Icon(Icons.color_lens),
                title: Text(loc.monet_color),
                subtitle: Text(
                  loc.effective_after_reboot,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12.0,
                  ),
                ),
                onTap: () {
                  onMonet(!selectedMonet);
                },
                trailing: Switch(
                  value: selectedMonet,
                  onChanged: isEnabled ? onMonet : null,
                ),
              ),
              ListTile(
                enabled: !selectedMonet,
                leading: const Icon(Icons.color_lens),
                title: Text(loc.custom_color),
                subtitle: Text(
                  loc.effective_after_reboot,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12.0,
                  ),
                ),
                onTap: () {
                  showColorPickerDialog(context, currentColor, (Color color) {
                    setState(() => currentColor = color);
                    _box.write('colorSeed', currentColor.toARGB32());
                  });
                },
              ),
              Obx(() => ListTile(
                    enabled: totpController.totpList.isNotEmpty,
                    leading: const Icon(Icons.upload),
                    title: Text(loc.export_data),
                    onTap: () {
                      export();
                    },
                  )),
              ListTile(
                leading: const Icon(Icons.info),
                title: Text(loc.about),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return buildAboutDialog();
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
