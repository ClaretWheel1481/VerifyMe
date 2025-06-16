import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/generate/controller.dart';
import 'package:verifyme/l10n/generated/localizations.dart';

class CheckFormPage extends StatefulWidget {
  final String resultUrl;
  const CheckFormPage({super.key, required this.resultUrl});

  @override
  State<CheckFormPage> createState() => _CheckFormPageState();
}

class _CheckFormPageState extends State<CheckFormPage> {
  final GenerateController gController = Get.put(GenerateController());
  final TextEditingController lengthController =
      TextEditingController(text: '6');

  String selectedAlgorithm = 'SHA-1';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    lengthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final uri = Uri.parse(widget.resultUrl);
    final secret = uri.queryParameters['secret'] ?? '';
    final issuer = uri.queryParameters['issuer'] ?? '';
    final accountName =
        uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';

    final totpMatch = RegExp(r'otpauth://(\w+)/').firstMatch(widget.resultUrl);
    final mode = totpMatch != null ? totpMatch.group(1) : '';

    final TextEditingController controller =
        TextEditingController(text: widget.resultUrl);

    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(loc.confirm),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controller,
              readOnly: true,
              decoration: InputDecoration(
                labelText: loc.result,
              ),
            ),
            const SizedBox(height: 25),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${loc.mode}: ${mode ?? ''}'),
                  Text('${loc.issuer}: $issuer'),
                  Text('${loc.account}: $accountName'),
                  Text('${loc.secret}: ${secret.toUpperCase()}'),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.options,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: selectedAlgorithm,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedAlgorithm = newValue;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: loc.algorithm,
                      border: const OutlineInputBorder(),
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
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
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: loc.length,
                      border: const OutlineInputBorder(),
                    ),
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
                  mode?.toUpperCase() ?? '',
                );
                Get.back();
              },
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.primary),
                foregroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.onSecondary),
              ),
              child: Text(loc.confirm),
            ),
          ],
        ),
      ),
    );
  }
}
