import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:verifyme/utils/totp/controller.dart';

class EditForm extends StatefulWidget {
  const EditForm({
    super.key,
    required this.index,
    required this.accountName,
    required this.secret,
    required this.algorithm,
  });
  final int index;
  final String accountName;
  final String secret;
  final String algorithm;

  @override
  EditFormState createState() => EditFormState();
}

class EditFormState extends State<EditForm> {
  final TOTPController totpController = Get.put(TOTPController());

  @override
  Widget build(BuildContext context) {
    final TextEditingController accountNameController =
        TextEditingController(text: widget.accountName);
    final TextEditingController secretController =
        TextEditingController(text: widget.secret);
    final List<String> algorithms = ['SHA-1', 'SHA-256', 'SHA-512'];
    String selectedAlgorithm = widget.algorithm;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: accountNameController,
              decoration: const InputDecoration(
                  labelText: 'Account', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: secretController,
              decoration: const InputDecoration(
                  labelText: 'Secret', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 25),
            DropdownButtonFormField<String>(
              value: selectedAlgorithm,
              items: algorithms.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                selectedAlgorithm = newValue!;
              },
              decoration: const InputDecoration(
                  labelText: 'Algorithm', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (totpController.addTOTP(
                  accountNameController.text,
                  secretController.text,
                  selectedAlgorithm,
                )) {
                  Get.back();
                } else {
                  _showErrorDialog();
                }
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.primary),
                foregroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.onSecondary),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: const Text(
            'Failed to add TOTP. Please check the secret and try again.'),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}
