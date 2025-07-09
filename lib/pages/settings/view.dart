import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:verifyme/l10n/generated/localizations.dart';
import 'package:verifyme/pages/settings/webdav_settings.dart';
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final bool isEnabled = !Platform.isIOS;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: kToolbarHeight),
          Text(loc.settings, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ThemeModeSelectorWidget(
            themeMode: _themeMode,
            dynamicColorEnabled: selectedMonet,
            onThemeModeChanged: _saveThemeMode,
            onDynamicColorChanged: onMonet,
            isEnabled: isEnabled,
            currentColor: currentColor,
            onCustomColor: (color) {
              setState(() => currentColor = color);
              _box.write('colorSeed', currentColor.toARGB32);
            },
          ),
          const SizedBox(height: 16),
          // Monet取色开关
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => onMonet(!selectedMonet),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.color_lens,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(loc.monet_color,
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Text(loc.effective_after_reboot,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.grey)),
                          ],
                        ),
                      ),
                      Switch(
                        value: selectedMonet,
                        onChanged: isEnabled ? onMonet : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 自定义颜色
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: selectedMonet
                    ? null
                    : () {
                        showColorPickerDialog(context, currentColor, (color) {
                          setState(() => currentColor = color);
                          _box.write('colorSeed', currentColor.toARGB32());
                        });
                      },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.color_lens_outlined,
                          color: selectedMonet
                              ? Colors.grey
                              : Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(loc.custom_color,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        color: selectedMonet
                                            ? Colors.grey
                                            : null)),
                            const SizedBox(height: 4),
                            Text(loc.effective_after_reboot,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          LanguageSelectorWidget(
            languageCode: _languageCode,
            onLanguageChanged: _changeLanguage,
          ),
          const SizedBox(height: 16),
          // WebDAV
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  Get.to(() => const WebDavSettingsPage());
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.cloud_upload,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(loc.webdav_title,
                              style: Theme.of(context).textTheme.titleMedium)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 导出
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: totpController.totpList.isNotEmpty ? export : null,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.upload,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(loc.export_data,
                              style: Theme.of(context).textTheme.titleMedium)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 关于
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return buildAboutDialog();
                    },
                  );
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(loc.about,
                              style: Theme.of(context).textTheme.titleMedium)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ThemeModeSelectorWidget 只保留主题模式选择相关内容，不再包含Monet和自定义颜色
class ThemeModeSelectorWidget extends StatefulWidget {
  final String themeMode;
  final bool dynamicColorEnabled;
  final ValueChanged<String> onThemeModeChanged;
  final ValueChanged<bool?> onDynamicColorChanged;
  final bool isEnabled;
  final Color currentColor;
  final ValueChanged<Color> onCustomColor;
  const ThemeModeSelectorWidget({
    super.key,
    required this.themeMode,
    required this.dynamicColorEnabled,
    required this.onThemeModeChanged,
    required this.onDynamicColorChanged,
    required this.isEnabled,
    required this.currentColor,
    required this.onCustomColor,
  });
  @override
  State<ThemeModeSelectorWidget> createState() =>
      _ThemeModeSelectorWidgetState();
}

class _ThemeModeSelectorWidgetState extends State<ThemeModeSelectorWidget> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.light_mode, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(loc.theme, style: textTheme.titleMedium),
                    const Spacer(),
                    Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.linearToEaseOut,
            child: _expanded
                ? Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Column(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            leading: const Icon(Icons.brightness_auto),
                            title: Text(
                              loc.follow_system,
                              style: widget.themeMode == 'system'
                                  ? textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    )
                                  : textTheme.bodyLarge,
                            ),
                            trailing: widget.themeMode == 'system'
                                ? Icon(Icons.check, color: colorScheme.primary)
                                : null,
                            onTap: () => widget.onThemeModeChanged('system'),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            leading: const Icon(Icons.light_mode),
                            title: Text(
                              loc.light,
                              style: widget.themeMode == 'light'
                                  ? textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    )
                                  : textTheme.bodyLarge,
                            ),
                            trailing: widget.themeMode == 'light'
                                ? Icon(Icons.check, color: colorScheme.primary)
                                : null,
                            onTap: () => widget.onThemeModeChanged('light'),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            leading: const Icon(Icons.dark_mode),
                            title: Text(
                              loc.dark,
                              style: widget.themeMode == 'dark'
                                  ? textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    )
                                  : textTheme.bodyLarge,
                            ),
                            trailing: widget.themeMode == 'dark'
                                ? Icon(Icons.check, color: colorScheme.primary)
                                : null,
                            onTap: () => widget.onThemeModeChanged('dark'),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// 语言选择
class LanguageSelectorWidget extends StatefulWidget {
  final String languageCode;
  final ValueChanged<String> onLanguageChanged;
  const LanguageSelectorWidget(
      {super.key, required this.languageCode, required this.onLanguageChanged});
  @override
  State<LanguageSelectorWidget> createState() => _LanguageSelectorWidgetState();
}

class _LanguageSelectorWidgetState extends State<LanguageSelectorWidget> {
  bool _expanded = false;
  final List<Map<String, String>> languages = [
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
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.language, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(loc.language, style: textTheme.titleMedium),
                    const Spacer(),
                    Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.linearToEaseOut,
            child: _expanded
                ? Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Column(
                      children: languages.map((lang) {
                        final isSelected = lang['code'] == widget.languageCode;
                        return Material(
                          color: Colors.transparent,
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            title: Text(
                              lang['name']!,
                              style: isSelected
                                  ? textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    )
                                  : textTheme.bodyLarge,
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check, color: colorScheme.primary)
                                : null,
                            onTap: () {
                              if (!isSelected) {
                                widget.onLanguageChanged(lang['code']!);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// WebDav设置入口
class WebDavTile extends StatelessWidget {
  const WebDavTile({super.key});
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListTile(
        leading: const Icon(Icons.cloud_upload),
        title: Text(loc.webdav_title),
        onTap: () {
          Get.to(() => const WebDavSettingsPage());
        },
      ),
    );
  }
}

// 导出数据
class ExportTile extends StatelessWidget {
  final bool enabled;
  final VoidCallback onExport;
  const ExportTile({super.key, required this.enabled, required this.onExport});
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListTile(
        enabled: enabled,
        leading: const Icon(Icons.upload),
        title: Text(loc.export_data),
        onTap: onExport,
      ),
    );
  }
}

// 关于
class AboutAppTile extends StatelessWidget {
  const AboutAppTile({super.key});
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListTile(
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
    );
  }
}
