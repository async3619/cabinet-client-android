import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThreadSortOption { BumpOrder, ReplyCount, ImageCount, Newest, Oldest }

class ConfigModel extends ChangeNotifier {
  String? _serverUrl;
  ThreadSortOption? _threadSortOption;

  String? get serverUrl => _serverUrl;
  ThreadSortOption? get threadSortOption => _threadSortOption;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _serverUrl = prefs.getString('serverUrl');

    final threadSortOptionString = prefs.getString('threadSortOption');
    if (threadSortOptionString != null) {
      try {
        _threadSortOption = ThreadSortOption.values.firstWhere(
          (option) => option.name == threadSortOptionString,
        );
      } catch (e) {
        // If the value is not a valid ThreadSortOption, default to BumpOrder
        _threadSortOption = ThreadSortOption.BumpOrder;
      }
    } else {
      _threadSortOption = ThreadSortOption.BumpOrder; // Default value
    }

    notifyListeners();
  }

  void setServerUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('serverUrl', url);

    _serverUrl = url;
    notifyListeners();
  }

  void setThreadSortOption(ThreadSortOption option) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('threadSortOption', option.name);

    _threadSortOption = option;
    notifyListeners();
  }
}
