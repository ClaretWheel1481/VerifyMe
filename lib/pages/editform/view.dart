import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:verifyme/utils/generate/controller.dart';

class EditForm extends StatefulWidget {
  const EditForm(
      {super.key,
      required this.accountName,
      required this.secret,
      required this.algorithm,
      required this.length,
      required this.mode});
  final String accountName;
  final String secret;
  final String algorithm;
  final String length;
  final String mode;

  @override
  EditFormState createState() => EditFormState();
}

class EditFormState extends State<EditForm> {
  final GenerateController gController = Get.put(GenerateController());

  @override
  Widget build(BuildContext context) {
    final TextEditingController accountNameController =
        TextEditingController(text: widget.accountName);
    final TextEditingController secretController =
        TextEditingController(text: widget.secret);
    final List<String> algorithms = ['SHA-1', 'SHA-256', 'SHA-512'];
    final List<String> modes = ["TOTP", "HOTP"];
    String selectedAlgorithm = widget.algorithm;
    String selectedMode = widget.mode;
    final TextEditingController lengthController =
        TextEditingController(text: widget.length);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Input/Edit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedMode,
              items: modes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              dropdownColor: Theme.of(context).colorScheme.onSecondary,
              onChanged: (newValue) {
                selectedMode = newValue!;
              },
              decoration: const InputDecoration(
                  labelText: 'Mode', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 25),
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
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Options',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedAlgorithm,
                    items: algorithms.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    dropdownColor: Theme.of(context).colorScheme.onSecondary,
                    onChanged: (newValue) {
                      selectedAlgorithm = newValue!;
                    },
                    decoration: const InputDecoration(
                        labelText: 'Algorithm', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: lengthController,
                    decoration: const InputDecoration(
                        labelText: 'Length', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (accountNameController.text.isEmpty ||
                    secretController.text.isEmpty) {
                  _showErrorDialog();
                  return;
                }
                if (gController.add(
                    accountNameController.text,
                    secretController.text.replaceAll(" ", "").toUpperCase(),
                    selectedAlgorithm,
                    lengthController.text,
                    selectedMode)) {
                  Get.back();
                } else {
                  _showErrorDialog();
                  return;
                }
              },
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.primary),
                foregroundColor: WidgetStatePropertyAll(
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
            'Failed to add. Please check the parameters and try again.'),
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
