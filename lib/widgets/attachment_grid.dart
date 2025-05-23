import 'package:cabinet/entities/attachment_watched_status.dart';
import 'package:cabinet/queries/watcherThreads.graphql.dart';
import 'package:cabinet/utils/attachment.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';

import 'modal/media_viewer.dart';

class AttachmentGrid extends StatelessWidget {
  final List<Fragment$FullAttachment> attachments;
  final Map<String, AttachmentWatchedStatus> watchedStatus;

  const AttachmentGrid({
    super.key,
    required this.attachments,
    this.watchedStatus = const {},
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: EdgeInsets.zero,
      crossAxisCount: 3,
      childAspectRatio: 1 / 1,
      children:
          attachments.map((attachment) {
            final isWatched = watchedStatus[attachment.id] != null;

            return Opacity(
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
                                attachments: attachments,
                                currentIndex: attachments.indexOf(attachment),
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
            );
          }).toList(),
    );
  }
}
