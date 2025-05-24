import 'package:cabinet/entities/thread_read_status.dart';
import 'package:flutter/cupertino.dart';

import '../objectbox.g.dart';

class ThreadModel extends ChangeNotifier {
  ThreadModel({required this.readStatusBox});

  final Box<ThreadReadStatus> readStatusBox;

  final List<ThreadReadStatus> _readStatus = [];

  List<ThreadReadStatus> get readStatus => _readStatus;

  Future<void> initialize() async {
    _readStatus.addAll(await readStatusBox.getAllAsync());
  }

  markThreadAsRead(String threadId) async {
    final existingStatus = _readStatus.firstWhere(
      (status) => status.threadId == threadId,
      orElse: () => ThreadReadStatus()..threadId = threadId,
    );

    existingStatus.threadId = threadId;
    await readStatusBox.putAsync(existingStatus);

    final hasExisting = _readStatus.any(
      (status) => status.threadId == threadId,
    );

    if (!hasExisting) {
      _readStatus.add(existingStatus);
    }

    notifyListeners();
  }
}
