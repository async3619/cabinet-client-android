import 'package:flutter/cupertino.dart';

import '../entities/attachment_watched_status.dart';
import '../objectbox.g.dart';

class AttachmentModel extends ChangeNotifier {
  AttachmentModel({required this.watchedStatusBox});

  final Box<AttachmentWatchedStatus> watchedStatusBox;

  final Map<String, AttachmentWatchedStatus> _watchedStatusMap = {};

  Map<String, AttachmentWatchedStatus> get watchedStatus =>
      Map.unmodifiable(_watchedStatusMap);

  Future<void> initialize() async {
    final watchedStatusList = await watchedStatusBox.getAllAsync();
    _watchedStatusMap.clear();

    for (final status in watchedStatusList) {
      _watchedStatusMap[status.attachmentId!] = status;
    }

    notifyListeners();
  }

  markAttachmentAsWatched(String attachmentId) async {
    final existingStatus =
        _watchedStatusMap[attachmentId] ?? AttachmentWatchedStatus();
    existingStatus.attachmentId = attachmentId;

    await watchedStatusBox.putAsync(existingStatus);
    _watchedStatusMap[attachmentId] = existingStatus;

    notifyListeners();
  }
}
