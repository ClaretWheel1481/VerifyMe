import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/totp/controller.dart';

class TOTPFormPage extends StatelessWidget {
  final String totpUrl;
  final TOTPController totpController = Get.put(TOTPController());

  TOTPFormPage({super.key, required this.totpUrl});

  @override
  Widget build(BuildContext context) {
    final uri = Uri.parse(totpUrl);
    final secret = uri.queryParameters['secret'] ?? '';
    final issuer = uri.queryParameters['issuer'] ?? '';
    final accountName = uri.pathSegments.last;

    TextEditingController controller = TextEditingController(text: totpUrl);

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
                labelText: 'TOTP URL',
              ),
            ),
            const SizedBox(height: 20),
            Text('Issuer: $issuer'),
            Text('Account: $accountName'),
            Text('Secret: $secret'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                totpController.addTOTP(
                    accountName, secret.toUpperCase(), "SHA-1");
                Get.back();
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.primary),
                foregroundColor: WidgetStateProperty.all(
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
