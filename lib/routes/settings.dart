import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

import '../models/config.dart';

class SettingsRoute extends StatefulWidget {
  const SettingsRoute({super.key});

  @override
  State<SettingsRoute> createState() => _SettingsRouteState();
}

class _SettingsRouteState extends State<SettingsRoute> {
  final _formKey = GlobalKey<FormFieldState>();

  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter server URL';
    }
    try {
      final uri = Uri.parse(value);
      if (!uri.hasScheme || !uri.hasAuthority) {
        return 'Invalid URL format';
      }
      return null;
    } catch (e) {
      return 'Invalid URL format';
    }
  }

  handleTapServerUrl() {
    final defaultValue =
        Provider.of<ConfigModel>(context, listen: false).serverUrl;

    final controller = TextEditingController();
    controller.text = defaultValue ?? '';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Server URL Settings'),
            content: TextFormField(
              key: _formKey,
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Server URL',
                hintText: 'https://example.com',
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: _validateUrl,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    Provider.of<ConfigModel>(
                      context,
                      listen: false,
                    ).setServerUrl(controller.text);
                    Navigator.pop(context);

                    Fluttertoast.showToast(
                      msg: "Restart the app to apply changes",
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text('General'),
            tiles: [
              SettingsTile(
                title: const Text('Server URL'),
                description: const Text('Specify the target server URL'),
                leading: const Icon(Icons.cloud),
                onPressed: (_) {
                  handleTapServerUrl();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
