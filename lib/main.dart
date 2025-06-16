import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:verifyme/l10n/generated/localizations.dart';
import 'package:verifyme/pages/main/view.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:get/get.dart';
import 'package:verifyme/utils/notify.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const MyApp());
}

Locale parseLocale(String languageCode) {
  if (languageCode.contains('_')) {
    final parts = languageCode.split('_');
    if (parts.length == 2) {
      return Locale(parts[0], parts[1]);
    }
  }
  return Locale(languageCode);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GetStorage box = GetStorage();

    final String themeMode = box.read('themeMode') ?? 'system';
    final bool monetStatus = box.read('monetStatus') ?? true;
    final String languageCodeStored = box.read('languageCode') ?? 'en';
    final Locale initialLocale = parseLocale(languageCodeStored);
    final int colorValue = box.read('colorSeed') ?? 0x6750A4;
    final Color colorSeed = Color(colorValue);

    Widget buildApp({
      required ColorScheme lightColorScheme,
      required ColorScheme darkColorScheme,
    }) {
      return GetMaterialApp(
        locale: initialLocale,
        fallbackLocale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        localeResolutionCallback: (locale, supportedLocales) {
          if (locale != null) {
            for (var supported in supportedLocales) {
              if (supported.languageCode == locale.languageCode &&
                  (supported.countryCode == null ||
                      supported.countryCode == locale.countryCode)) {
                return supported;
              }
            }
          }
          return const Locale('en');
        },
        scaffoldMessengerKey: scaffoldMessengerKey,
        theme: ThemeData(
          colorScheme: lightColorScheme,
        ),
        darkTheme: ThemeData(
          colorScheme: darkColorScheme,
        ),
        themeMode: themeMode == 'system'
            ? ThemeMode.system
            : themeMode == 'light'
                ? ThemeMode.light
                : ThemeMode.dark,
        home: const MainApp(title: "VerifyMe"),
      );
    }

    if (Platform.isIOS || !monetStatus) {
      final lightColorScheme = ColorScheme.fromSeed(seedColor: colorSeed);
      final darkColorScheme = ColorScheme.fromSeed(
        seedColor: colorSeed,
        brightness: Brightness.dark,
      );
      return buildApp(
        lightColorScheme: lightColorScheme,
        darkColorScheme: darkColorScheme,
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
            lightColorScheme = ColorScheme.fromSeed(seedColor: colorSeed);
            darkColorScheme = ColorScheme.fromSeed(
              seedColor: colorSeed,
              brightness: Brightness.dark,
            );
          }

          return buildApp(
            lightColorScheme: lightColorScheme,
            darkColorScheme: darkColorScheme,
          );
        },
      );
    }
  }
}
