import 'package:cabinet/entities/attachment_watched_status.dart';
import 'package:cabinet/queries/watcherThreads.graphql.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../utils/attachment.dart';
import 'modal/media_viewer.dart';

class AttachmentGrid extends StatefulWidget {
  final List<Fragment$FullAttachment> attachments;
  final Map<String, AttachmentWatchedStatus> watchedStatus;

  const AttachmentGrid({
    super.key,
    required this.attachments,
    this.watchedStatus = const {},
  });

  @override
  State<AttachmentGrid> createState() => _AttachmentGridState();
}

class _AttachmentGridState extends State<AttachmentGrid> {
  AutoScrollController? scrollController;

  @override
  void initState() {
    super.initState();

    scrollController = AutoScrollController();
  }

  void handleIndexChanged(int index) {
    if (scrollController == null) {
      return;
    }

    scrollController!.scrollToIndex(
      index,
      preferPosition: AutoScrollPosition.begin,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      itemCount: widget.attachments.length,
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1 / 1,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
      ),
      itemBuilder: (context, index) {
        final attachment = widget.attachments[index];
        final isWatched = widget.watchedStatus[attachment.id] != null;

        return AutoScrollTag(
          key: ValueKey(index),
          controller: scrollController!,
          index: index,
          child: Opacity(
            opacity: isWatched ? 0.5 : 1.0,
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      getAttachmentThumbnailUrl(attachment),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MediaViewerModal(
                              attachments: widget.attachments,
                              currentIndex: widget.attachments.indexOf(
                                attachment,
                              ),
                              onIndexChanged: handleIndexChanged,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${attachment.$extension.toUpperCase().substring(1)} ${attachment.width}x${attachment.height} ${filesize(attachment.size)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
