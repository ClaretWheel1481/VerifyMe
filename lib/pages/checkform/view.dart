import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../utils/generate/controller.dart';

class CheckFormPage extends StatelessWidget {
  final String resultUrl;
  final GenerateController gController = Get.put(GenerateController());
  final TextEditingController lengthController =
      TextEditingController(text: '6');
  CheckFormPage({super.key, required this.resultUrl});
  final GetStorage _box = GetStorage();

  @override
  Widget build(BuildContext context) {
    String _languageCode = _box.read('languageCode') ?? 'en';

    Future.delayed(Duration.zero, () async {
      await FlutterI18n.refresh(context, Locale(_languageCode));
    });

    final uri = Uri.parse(resultUrl);
    final secret = uri.queryParameters['secret'] ?? '';
    final issuer = uri.queryParameters['issuer'] ?? '';
    final accountName = uri.pathSegments.last;

    final totpMatch = RegExp(r'otpauth://(\w+)/').firstMatch(resultUrl);
    final mode = totpMatch != null ? totpMatch.group(1) : '';

    TextEditingController controller = TextEditingController(text: resultUrl);
    String selectedAlgorithm = 'SHA-1';
    return Scaffold(
      appBar: AppBar(
          title: Align(
        alignment: Alignment.centerLeft,
        child: Text(FlutterI18n.translate(context, "confirm")),
      )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controller,
              readOnly: true,
              decoration: InputDecoration(
                labelText: FlutterI18n.translate(context, "result"),
              ),
            ),
            const SizedBox(height: 25),
            Text('${FlutterI18n.translate(context, "mode")}: $mode'),
            Text('${FlutterI18n.translate(context, "issuer")}: $issuer'),
            Text('${FlutterI18n.translate(context, "account")}: $accountName'),
            Text(
                '${FlutterI18n.translate(context, "secret")}: ${secret.toUpperCase()}'),
            const SizedBox(height: 25),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    FlutterI18n.translate(context, "options"),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: selectedAlgorithm,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        selectedAlgorithm = newValue;
                      }
                    },
                    decoration: InputDecoration(
                        labelText: FlutterI18n.translate(context, "algorithm"),
                        border: OutlineInputBorder()),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    dropdownColor: Theme.of(context).colorScheme.onSecondary,
                    items: <String>['SHA-1', 'SHA-256', 'SHA-512']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 25),
                  TextField(
                    controller: lengthController,
                    decoration: InputDecoration(
                        labelText: FlutterI18n.translate(context, "length"),
                        border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                gController.add(
                    accountName,
                    secret.toUpperCase(),
                    selectedAlgorithm,
                    lengthController.text,
                    mode.toString().toUpperCase());
                Get.back();
              },
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.primary),
                foregroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.onSecondary),
              ),
              child: Text(FlutterI18n.translate(context, "confirm")),
            )
          ],
        ),
      ),
    );
  }
}
