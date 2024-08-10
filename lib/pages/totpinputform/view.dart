import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:verifyme/pages/utils/totp/controller.dart';

class TOTPInputForm extends StatefulWidget {
  @override
  _TOTPInputFormState createState() => _TOTPInputFormState();
}

class _TOTPInputFormState extends State<TOTPInputForm> {
  final _formKey = GlobalKey<FormState>();
  final _accountNameController = TextEditingController();
  final _secretController = TextEditingController();
  String _selectedAlgorithm = 'SHA-1';
  final TOTPController totpController = Get.put(TOTPController());

  @override
  void dispose() {
    _accountNameController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final accountName = _accountNameController.text;
      final secret = _secretController.text;
      final algorithm = _selectedAlgorithm;

      totpController.addTOTP(accountName, secret, algorithm);

      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TOTP Input Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _accountNameController,
                decoration: const InputDecoration(labelText: 'Account Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an account name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _secretController,
                decoration: const InputDecoration(labelText: 'Secret'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a secret';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedAlgorithm,
                decoration: const InputDecoration(
                  labelText: 'Algorithm',
                ),
                items: ['SHA-1', 'SHA-256', 'SHA-512']
                    .map((algorithm) => DropdownMenuItem(
                          value: algorithm,
                          child: Text(algorithm),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAlgorithm = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                      Theme.of(context).colorScheme.primary),
                  foregroundColor: WidgetStateProperty.all(
                      Theme.of(context).colorScheme.onSecondary),
                ),
                onPressed: _saveForm,
                child: const Text('Confirm'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
