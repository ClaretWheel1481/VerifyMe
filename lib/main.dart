import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_storage/get_storage.dart';
import 'package:verifyme/pages/main/view.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:get/get.dart';
import 'package:verifyme/utils/notify.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GetStorage box = GetStorage();

    final String themeMode = box.read('themeMode') ?? 'system';
    final bool monetStatus = box.read('monetStatus') ?? true;
    final String languageCode = box.read('languageCode') ?? 'en';
    final Color colorSeed = Color(box.read('colorSeed') ?? 0x6750A4);

    if (Platform.isIOS || !monetStatus) {
      final lightColorScheme = ColorScheme.fromSeed(
        seedColor: colorSeed,
      );
      final darkColorScheme = ColorScheme.fromSeed(
        seedColor: colorSeed,
        brightness: Brightness.dark,
      );

      return GetMaterialApp(
        locale: Locale(languageCode),
        fallbackLocale: const Locale('en'),
        localizationsDelegates: [
          FlutterI18nDelegate(
              translationLoader: FileTranslationLoader(
                  useCountryCode: true, basePath: 'assets/locales'),
              missingTranslationHandler: (key, locale) {
                showNotification("i18n loading error");
              }),
        ],
        scaffoldMessengerKey: scaffoldMessengerKey,
        theme: ThemeData(
          colorScheme: lightColorScheme,
          // TODO: 实验性功能，符合最新Material Design的过渡动画
          pageTransitionsTheme: PageTransitionsTheme(
            builders: Map<TargetPlatform, PageTransitionsBuilder>.fromIterable(
              TargetPlatform.values,
              value: (_) => const FadeForwardsPageTransitionsBuilder(),
            ),
          ),
        ),
        darkTheme: ThemeData(colorScheme: darkColorScheme),
        themeMode: themeMode == 'system'
            ? ThemeMode.system
            : themeMode == 'light'
                ? ThemeMode.light
                : ThemeMode.dark,
        home: const MainApp(title: "VerifyMe"),
      );
    } else {
      return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
          ColorScheme lightColorScheme;
          ColorScheme darkColorScheme;

          if (lightDynamic != null && darkDynamic != null) {
            lightColorScheme = lightDynamic.harmonized();
            darkColorScheme = darkDynamic.harmonized();
          } else {
            lightColorScheme =
                ColorScheme.fromSwatch(primarySwatch: Colors.lightBlue);
            darkColorScheme = ColorScheme.fromSwatch(
                primarySwatch: Colors.lightBlue, brightness: Brightness.dark);
          }

          return GetMaterialApp(
            locale: Locale(languageCode),
            fallbackLocale: const Locale('en'),
            localizationsDelegates: [
              FlutterI18nDelegate(
                  translationLoader: FileTranslationLoader(
                      useCountryCode: true, basePath: 'assets/locales'),
                  missingTranslationHandler: (key, locale) {
                    showNotification("i18n loading error");
                  }),
            ],
            scaffoldMessengerKey: scaffoldMessengerKey,
            theme: ThemeData(colorScheme: lightColorScheme),
            darkTheme: ThemeData(colorScheme: darkColorScheme),
            themeMode: themeMode == 'system'
                ? ThemeMode.system
                : themeMode == 'light'
                    ? ThemeMode.light
                    : ThemeMode.dark,
            home: const MainApp(title: "VerifyMe"),
          );
        },
      );
    }
  }
}
