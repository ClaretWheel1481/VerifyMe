import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:verifyme/utils/generate/controller.dart';

class EditForm extends StatefulWidget {
  const EditForm(
      {super.key,
      required this.accountName,
      required this.secret,
      required this.algorithm,
      required this.length,
      required this.mode,
      required this.isEdit});
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
  final GetStorage _box = GetStorage();
  final GenerateController gController = Get.put(GenerateController());
  String _languageCode = 'en';

  @override
  void initState() {
    super.initState();

    // 翻译页面
    _languageCode = _box.read('languageCode') ?? 'en';
    Future.delayed(Duration.zero, () async {
      await FlutterI18n.refresh(context, Locale(_languageCode));
    });
  }

  // 错误弹窗
  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(FlutterI18n.translate(context, "error")),
        content: Text(FlutterI18n.translate(context, "failed_to_add")),
        actions: <Widget>[
          TextButton(
            child: Text(FlutterI18n.translate(context, "ok")),
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
        title: widget.isEdit
            ? Align(
                alignment: Alignment.centerLeft,
                child: Text(FlutterI18n.translate(context, "edit")),
              )
            : Align(
                alignment: Alignment.centerLeft,
                child: Text(FlutterI18n.translate(context, "input")),
              ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              value: selectedMode,
              items: modes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                selectedMode = newValue!;
              },
              decoration: InputDecoration(
                  labelText: FlutterI18n.translate(context, "mode"),
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: accountNameController,
              decoration: InputDecoration(
                  labelText: FlutterI18n.translate(context, "account"),
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: secretController,
              decoration: InputDecoration(
                  labelText: FlutterI18n.translate(context, "secret"),
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 25),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                FlutterI18n.translate(context, "options"),
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
                    borderRadius: BorderRadius.all(Radius.circular(15)),
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
                    decoration: InputDecoration(
                        labelText: FlutterI18n.translate(context, "algorithm"),
                        border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: lengthController,
                    decoration: InputDecoration(
                        labelText: FlutterI18n.translate(context, "length"),
                        border: OutlineInputBorder()),
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
                    Theme.of(context).colorScheme.onPrimary),
              ),
              child: Text(FlutterI18n.translate(context, "save")),
            ),
          ],
        ),
      ),
    );
  }
}
