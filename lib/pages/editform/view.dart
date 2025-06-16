import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:verifyme/utils/generate/controller.dart';
import 'package:verifyme/l10n/generated/localizations.dart';

class EditForm extends StatefulWidget {
  const EditForm({
    super.key,
    required this.accountName,
    required this.secret,
    required this.algorithm,
    required this.length,
    required this.mode,
    required this.isEdit,
  });

  final String accountName;
  final String secret;
  final String algorithm;
  final String length;
  final String mode;
  final bool isEdit;

  @override
  EditFormState createState() => EditFormState();
}

class EditFormState extends State<EditForm> {
  final GenerateController gController = Get.put(GenerateController());

  late TextEditingController accountNameController;
  late TextEditingController secretController;
  late TextEditingController lengthController;

  late String selectedAlgorithm;
  late String selectedMode;

  final List<String> algorithms = ['SHA-1', 'SHA-256', 'SHA-512'];
  final List<String> modes = ['TOTP', 'HOTP'];

  @override
  void initState() {
    super.initState();
    accountNameController = TextEditingController(text: widget.accountName);
    secretController = TextEditingController(text: widget.secret);
    lengthController = TextEditingController(text: widget.length);

    selectedAlgorithm = widget.algorithm;
    selectedMode = widget.mode;
  }

  @override
  void dispose() {
    accountNameController.dispose();
    secretController.dispose();
    lengthController.dispose();
    super.dispose();
  }

  void _showErrorDialog() {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.error),
        content: Text(loc.failed_to_add),
        actions: <Widget>[
          TextButton(
            child: Text(loc.ok),
            onPressed: () {
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.isEdit ? loc.edit : loc.input,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              value: selectedMode,
              items: modes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedMode = newValue;
                  });
                }
              },
              dropdownColor: Theme.of(context).colorScheme.onSecondary,
              decoration: InputDecoration(
                labelText: loc.mode,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: accountNameController,
              decoration: InputDecoration(
                labelText: loc.account,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: secretController,
              decoration: InputDecoration(
                labelText: loc.secret,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                loc.options,
                style: const TextStyle(
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
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    value: selectedAlgorithm,
                    items: algorithms.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedAlgorithm = newValue;
                        });
                      }
                    },
                    dropdownColor: Theme.of(context).colorScheme.onSecondary,
                    decoration: InputDecoration(
                      labelText: loc.algorithm,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: lengthController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: loc.length,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final nameText = accountNameController.text.trim();
                final secretText =
                    secretController.text.replaceAll(" ", "").toUpperCase();
                final lengthText = lengthController.text.trim();
                if (nameText.isEmpty || secretText.isEmpty) {
                  _showErrorDialog();
                  return;
                }
                final success = gController.add(
                  nameText,
                  secretText,
                  selectedAlgorithm,
                  lengthText,
                  selectedMode,
                );
                if (success) {
                  Get.back();
                } else {
                  _showErrorDialog();
                  return;
                }
              },
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.primary,
                ),
                foregroundColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              child: Text(loc.save),
            ),
          ],
        ),
      ),
    );
  }
}
