import 'package:cabinet/entities/thread_read_status.dart';
import 'package:flutter/cupertino.dart';

import '../objectbox.g.dart';

class ThreadModel extends ChangeNotifier {
  ThreadModel({required this.readStatusBox});

  final Box<ThreadReadStatus> readStatusBox;

  final Map<String, ThreadReadStatus> _readStatusMap = {};

  Map<String, ThreadReadStatus> get readStatus =>
      Map.unmodifiable(_readStatusMap);

  Future<void> initialize() async {
    final readStatusList = await readStatusBox.getAll();
    _readStatusMap.clear();

    for (final status in readStatusList) {
      _readStatusMap[status.threadId!] = status;
    }

    notifyListeners();
  }

  markThreadAsRead(String threadId) async {
    final existingStatus = _readStatusMap[threadId] ?? ThreadReadStatus();
    existingStatus.threadId = threadId;
    existingStatus.readAt = DateTime.now().millisecondsSinceEpoch;

    await readStatusBox.putAsync(existingStatus);
    _readStatusMap[threadId] = existingStatus;

    notifyListeners();
  }
}
