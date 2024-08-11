import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:verifyme/pages/main/view.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:get/get.dart';

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

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (lightDynamic != null && darkDynamic != null) {
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          lightColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.blue);
          darkColorScheme = ColorScheme.fromSwatch(
              primarySwatch: Colors.blue, brightness: Brightness.dark);
        }

        return GetMaterialApp(
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
