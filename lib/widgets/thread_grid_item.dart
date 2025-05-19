import 'package:cabinet_client_android/queries/watcherThreads.graphql.dart';
import 'package:cabinet_client_android/utils/attachment.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';

class ThreadGridItem extends StatelessWidget {
  final Fragment$MinimalThread thread;
  final Function(Fragment$MinimalThread)? onTap;

  const ThreadGridItem({super.key, required this.thread, this.onTap});

  void handleCardTap() {
    if (onTap == null) {
      return;
    }

    onTap!(thread);
  }

  Widget? buildThumbnail(BuildContext context) {
    if (thread.attachments == null) {
      return null;
    }

    final attachment = thread.attachments![0];
    final thumbnailUrl = getAttachmentThumbnailUrl(attachment);

    return AspectRatio(
      aspectRatio: 16 / 11,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(thumbnailUrl, fit: BoxFit.cover),
          ),
          if (attachment.isVideo)
            Positioned.fill(
              child: Center(
                child: Icon(
                  Icons.play_circle_outline,
                  size: 36,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
            ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(onTap: () {}),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final thumbnail = buildThumbnail(context);
    final title = thread.title;
    final document = parse(thread.content?.replaceAll('<br>', '\n') ?? '');
    final content = parse(document.body?.text).documentElement?.text;

    final bodyTextStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
    );

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        color: Theme.of(context).cardColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (thumbnail != null) thumbnail,
            Expanded(
              child: Material(
                color: Theme.of(context).cardColor,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (title != null)
                              Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleSmall?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            if (title != null) const SizedBox(height: 4),
                            if (content != null)
                              Text(
                                content,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: bodyTextStyle,
                              ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        color: Theme.of(context).cardColor,
                        child: Row(
                          children: [
                            Expanded(child: Container()),
                            Text(
                              '${thread.$_count.posts}R ${thread.attachmentCount}I',
                              style: bodyTextStyle,
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(onTap: handleCardTap),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
