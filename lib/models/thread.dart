import 'package:cabinet/entities/thread_read_status.dart';
import 'package:cabinet/entities/thread_scroll_position.dart';
import 'package:flutter/cupertino.dart';

import '../objectbox.g.dart';

class ThreadModel extends ChangeNotifier {
  ThreadModel({required this.readStatusBox, required this.scrollPositionBox});

  final Box<ThreadReadStatus> readStatusBox;
  final Box<ThreadScrollPosition> scrollPositionBox;

  final Map<String, ThreadReadStatus> _readStatusMap = {};
  final Map<String, ThreadScrollPosition> _scrollPositionMap = {};

  Map<String, ThreadReadStatus> get readStatus =>
      Map.unmodifiable(_readStatusMap);

  Map<String, ThreadScrollPosition> get scrollPosition =>
      Map.unmodifiable(_scrollPositionMap);

  Future<void> initialize() async {
    final readStatusList = await readStatusBox.getAllAsync();
    final scrollPositionList = await scrollPositionBox.getAllAsync();

    _readStatusMap.clear();
    _scrollPositionMap.clear();

    for (final status in readStatusList) {
      _readStatusMap[status.threadId!] = status;
    }

    for (final position in scrollPositionList) {
      _scrollPositionMap[position.threadId!] = position;
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

  registerScrollPosition(String threadId, double pixels) async {
    final existingPosition =
        _scrollPositionMap[threadId] ?? ThreadScrollPosition();
    existingPosition.threadId = threadId;
    existingPosition.scrollPosition = pixels;

    await scrollPositionBox.putAsync(existingPosition);
    _scrollPositionMap[threadId] = existingPosition;

    notifyListeners();
  }
}
