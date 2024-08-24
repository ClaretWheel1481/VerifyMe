import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:verifyme/pages/settings/widgets.dart';
import 'package:verifyme/utils/totp/file.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  final GetStorage _box = GetStorage();
  String _themeMode = 'system';

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

  @override
  Widget build(BuildContext context) {
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
              leading: const Icon(Icons.download),
              title: const Text('Export TOTP List'),
              onTap: () {
                exportTOTP();
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Import from Json'),
              onTap: () {
                importTOTPList();
              },
            ),
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
