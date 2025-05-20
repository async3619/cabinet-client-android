import 'package:cabinet/queries/watcherThreads.graphql.dart';
import 'package:cabinet/utils/attachment.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';

import '../queries/thread.graphql.dart';

TextStyle descriptionText(BuildContext context, int? alpha) {
  alpha ??= 128;

  return TextStyle(
    fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
    color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(alpha),
  );
}

class PostListItem extends StatelessWidget {
  final Fragment$FullPost post;
  final List<String> replyPostIds;
  final Map<int, String> postNoToIdMap;

  final void Function(List<String> postIds)? onRequestShowPost;
  final void Function(Fragment$FullAttachment, Fragment$FullPost)?
  onShowAttachment;

  const PostListItem({
    super.key,
    required this.post,
    this.onShowAttachment,
    this.onRequestShowPost,
    required this.replyPostIds,
    required this.postNoToIdMap,
  });

  @override
  Widget build(BuildContext context) {
    final descriptionTextStyle = descriptionText(context, 128);

    final postMetadata = [
      'No.${post.no}',
      DateFormat('yyyy-MM-dd HH:mm:ss').format(post.createdAt),
    ].join(' ');
    final hasAttachments =
        post.attachments != null && post.attachments!.isNotEmpty;

    final primaryAttachment = hasAttachments ? post.attachments!.first : null;

    String? primaryAttachmentMetadata;
    if (primaryAttachment != null) {
      final filename = primaryAttachment.name;
      final extension = primaryAttachment.$extension;

      primaryAttachmentMetadata = [
        '$filename$extension',
        if (primaryAttachment.size != null) filesize(primaryAttachment.size!),
        '${primaryAttachment.width}x${primaryAttachment.height}',
      ].join(' ');
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasAttachments)
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    getAttachmentThumbnailUrl(primaryAttachment!),
                    fit: BoxFit.cover,
                  ),
                ),
                if (primaryAttachment.isVideo)
                  Positioned.fill(
                    child: Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 24,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (onShowAttachment == null) {
                          return;
                        }

                        onShowAttachment!(primaryAttachment, post);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.title != null)
                  Text(
                    post.title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.titleSmall?.fontSize,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                if (post.title != null) const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      post.author,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: descriptionText(context, 255),
                    ),
                    Text(' ', style: descriptionTextStyle),
                    Expanded(
                      child: Text(
                        postMetadata,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: descriptionTextStyle,
                      ),
                    ),
                  ],
                ),
                if (primaryAttachmentMetadata != null)
                  Text(
                    primaryAttachmentMetadata,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: descriptionTextStyle,
                  ),
                const SizedBox(height: 8),
                Html(
                  data: post.content ?? '',
                  onAnchorTap: (url, _, __) {
                    if (url == null ||
                        onRequestShowPost == null ||
                        !url.startsWith('#p')) {
                      return;
                    }

                    final postNo = int.tryParse(url.substring(2));
                    if (postNo == null) return;

                    final postId = postNoToIdMap[postNo];
                    if (postId == null) return;

                    onRequestShowPost!([postId]);
                  },
                  style: {
                    'body': Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                      fontSize: FontSize(
                        Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14,
                      ),
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    'a': Style(color: Theme.of(context).colorScheme.secondary),
                    '.quote': Style(color: const Color(0xFFB5BD68)),
                  },
                ),
                if (replyPostIds.length > 0) const SizedBox(height: 8),
                if (replyPostIds.length > 0)
                  InkWell(
                    onTap: () {
                      if (onRequestShowPost == null) {
                        return;
                      }

                      onRequestShowPost!(replyPostIds);
                    },
                    child: Text(
                      '${replyPostIds.length} replies',
                      style: descriptionTextStyle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
