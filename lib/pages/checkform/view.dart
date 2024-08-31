import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/generate/controller.dart';

class TOTPFormPage extends StatelessWidget {
  final String totpUrl;
  final GenerateController totpController = Get.put(GenerateController());
  final TextEditingController lengthController =
      TextEditingController(text: '6');
  TOTPFormPage({super.key, required this.totpUrl});

  @override
  Widget build(BuildContext context) {
    final uri = Uri.parse(totpUrl);
    final secret = uri.queryParameters['secret'] ?? '';
    final issuer = uri.queryParameters['issuer'] ?? '';
    final accountName = uri.pathSegments.last;

    final totpMatch = RegExp(r'otpauth://(\w+)/').firstMatch(totpUrl);
    final mode = totpMatch != null ? totpMatch.group(1) : '';

    TextEditingController controller = TextEditingController(text: totpUrl);
    String selectedAlgorithm = 'SHA-1';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm TOTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controller,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'RESULT',
              ),
            ),
            const SizedBox(height: 25),
            Text('Mode: $mode'),
            Text('Issuer: $issuer'),
            Text('Account: $accountName'),
            Text('Secret: ${secret.toUpperCase()}'),
            const SizedBox(height: 25),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Options',
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
                    decoration: const InputDecoration(
                        labelText: 'Algorithm', border: OutlineInputBorder()),
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
                    decoration: const InputDecoration(
                        labelText: 'Length', border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                totpController.add(accountName, secret.toUpperCase(),
                    selectedAlgorithm, lengthController.text, "TOTP");
                Get.back();
              },
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.primary),
                foregroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.onSecondary),
              ),
              child: const Text('Confirm'),
            )
          ],
        ),
      ),
    );
  }
}
