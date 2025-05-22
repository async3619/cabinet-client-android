import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigModel extends ChangeNotifier {
  String? _serverUrl;

  String? get serverUrl => _serverUrl;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _serverUrl = prefs.getString('serverUrl');
    notifyListeners();
  }

  void setServerUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('serverUrl', url);

    _serverUrl = url;
    notifyListeners();
  }
}
