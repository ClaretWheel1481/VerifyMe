import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:webdav_client/webdav_client.dart';
import 'package:verifyme/utils/notify.dart';
import 'package:verifyme/l10n/generated/localizations.dart';

class WebDavSettingsPage extends StatefulWidget {
  const WebDavSettingsPage({Key? key}) : super(key: key);

  @override
  State<WebDavSettingsPage> createState() => _WebDavSettingsPageState();
}

class _WebDavSettingsPageState extends State<WebDavSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _box = GetStorage();

  late TextEditingController _urlController;
  late TextEditingController _userController;
  late TextEditingController _passController;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: _box.read('webdav_url') ?? '');
    _userController =
        TextEditingController(text: _box.read('webdav_user') ?? '');
    _passController =
        TextEditingController(text: _box.read('webdav_pass') ?? '');
    _urlController.addListener(_onFormChanged);
    _userController.addListener(_onFormChanged);
    _passController.addListener(_onFormChanged);
    _onFormChanged();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  bool _isFormValid = false;
  void _onFormChanged() {
    final valid = _urlController.text.trim().isNotEmpty;
    if (valid != _isFormValid) {
      setState(() {
        _isFormValid = valid;
      });
    }
  }

  Client get client => newClient(
        _urlController.text.trim(),
        user: _userController.text.trim(),
        password: _passController.text,
      );

  Future<void> _saveSettings() async {
    _box.write('webdav_url', _urlController.text.trim());
    _box.write('webdav_user', _userController.text.trim());
    _box.write('webdav_pass', _passController.text);
  }

  Future<void> _runWithLoading(Future<void> Function() action) async {
    setState(() => _loading = true);
    try {
      await action();
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _testConnection() async {
    await _saveSettings();
    final loc = AppLocalizations.of(context);
    try {
      await client.ping();
      showNotification(loc.webdav_connect_success);
    } catch (e) {
      showNotification('${loc.webdav_connect_fail}: $e');
    }
  }

  Future<void> _backupToWebDav() async {
    await _saveSettings();
    final loc = AppLocalizations.of(context);
    try {
      final data = _box.read('totpList');
      if (data == null) {
        showNotification(loc.webdav_no_data);
        return;
      }
      await client.write(
        '/totp_list.json',
        utf8.encode(jsonEncode(data)),
      );
      showNotification(loc.webdav_backup_success);
    } catch (e) {
      showNotification('${loc.webdav_backup_fail}: $e');
    }
  }

  Future<void> _restoreFromWebDav() async {
    await _saveSettings();
    final loc = AppLocalizations.of(context);
    try {
      final bytes = await client.read('/totp_list.json');
      final jsonData = jsonDecode(utf8.decode(bytes));
      _box.write('totpList', jsonData);
      showNotification(
          '${loc.webdav_restore_success}, ${loc.webdav_reboot_tip}');
    } catch (e) {
      showNotification('${loc.webdav_restore_fail}: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.webdav_title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: loc.webdav_address,
                  hintText: loc.webdav_address_hint,
                  prefixIcon: const Icon(Icons.cloud),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? loc.webdav_input_address : null,
                enabled: !_loading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _userController,
                decoration: InputDecoration(
                  labelText: loc.webdav_username,
                  prefixIcon: const Icon(Icons.person),
                  border: const OutlineInputBorder(),
                ),
                enabled: !_loading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passController,
                decoration: InputDecoration(
                  labelText: loc.webdav_password,
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                ),
                obscureText: true,
                enabled: !_loading,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.link),
                      label: Text(loc.webdav_connect),
                      onPressed: _isFormValid && !_loading
                          ? () => _runWithLoading(_testConnection)
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.backup),
                      label: Text(loc.webdav_backup),
                      onPressed: _isFormValid && !_loading
                          ? () => _runWithLoading(_backupToWebDav)
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.restore),
                      label: Text(loc.webdav_restore),
                      onPressed: _isFormValid && !_loading
                          ? () => _runWithLoading(_restoreFromWebDav)
                          : null,
                    ),
                  ),
                ],
              ),
              if (_loading) ...[
                const SizedBox(height: 32),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
