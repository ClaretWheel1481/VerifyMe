import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:verifyme/pages/settings/widgets.dart';
import 'package:verifyme/utils/generate/file.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  final GetStorage _box = GetStorage();
  String _themeMode = 'system';
  bool selectedMonet = true;

  @override
  void initState() {
    super.initState();
    _themeMode = _box.read('themeMode') ?? 'system';
  }

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

  void onMonet(bool? value) {
    if (value == null) return;
    setState(() {
      selectedMonet = value;
    });
    _box.write('monetStatus', value);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = !Platform.isIOS;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 15, bottom: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpansionTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Theme'),
              children: [
                ListTile(
                  leading: const Icon(Icons.brightness_auto),
                  title: const Text('Follow System'),
                  onTap: () {
                    _saveThemeMode('system');
                  },
                  selected: _themeMode == 'system',
                ),
                ListTile(
                  leading: const Icon(Icons.light_mode),
                  title: const Text('Light'),
                  onTap: () {
                    _saveThemeMode('light');
                  },
                  selected: _themeMode == 'light',
                ),
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('Dark'),
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
              title: const Text('Monet Color'),
              subtitle: const Text(
                'Effective after reboot',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12.0,
                ),
              ),
              onTap: () {
                onMonet(!selectedMonet);
              },
              trailing: Checkbox(
                value: selectedMonet,
                onChanged: isEnabled ? onMonet : null,
              ),
            ),
            Obx(() => ListTile(
                  enabled: totpController.totpList.isNotEmpty,
                  leading: const Icon(Icons.upload),
                  title: const Text('Export Data'),
                  onTap: () {
                    export();
                  },
                )),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
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
    );
  }
}
