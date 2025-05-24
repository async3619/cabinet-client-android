import 'package:cabinet/queries/thread.graphql.dart';
import 'package:cabinet/utils/attachment.dart';
import 'package:cabinet/widgets/post_list_item.dart';
import 'package:flutter/material.dart';

import '../../queries/watcherThreads.graphql.dart';
import '../modal/media_viewer.dart';

class PostDialog extends StatefulWidget {
  const PostDialog({
    super.key,
    required this.posts,
    required this.allPosts,
    required this.postNoToIdMap,
    required this.replyMap,
  });

  final List<Fragment$FullPost> posts;
  final List<Fragment$FullPost> allPosts;
  final Map<int, String> postNoToIdMap;
  final Map<String, List<String>> replyMap;

  @override
  State<PostDialog> createState() => _PostDialogState();
}

class _PostDialogState extends State<PostDialog> {
  List<List<Fragment$FullPost>> _postHistory = [];

  @override
  void initState() {
    super.initState();
    _postHistory = [widget.posts];
  }

  void handleRequestShowPost(List<String> postIds) {
    final posts =
        widget.allPosts.where((post) => postIds.contains(post.id)).toList();

    if (posts.isEmpty) {
      return;
    }

    setState(() {
      _postHistory.add(posts);
    });
  }

  void handleShowAttachment(
    Fragment$FullAttachment attachment,
    Fragment$FullPost post,
  ) {
    final posts = _postHistory.lastOrNull;
    if (posts == null) {
      return;
    }

    final attachmentIndex = getAttachmentIndex(posts, attachment, post);
    final allAttachments =
        posts
            .expand((post) => post.attachments ?? <Fragment$FullAttachment>[])
            .toList();

    Navigator.of(context).push(
      MediaViewerModal(
        attachments: allAttachments,
        currentIndex: attachmentIndex,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = _postHistory.lastOrNull;
    if (post == null) return const SizedBox();

    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      title: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                if (_postHistory.length > 1) {
                  setState(() {
                    _postHistory.removeLast();
                  });
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chevron_left),
                    const SizedBox(width: 8),
                    Text('Back', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.close),
                    const SizedBox(width: 8),
                    Text(
                      'Close',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Divider(height: 1),
              for (final post in post)
                Column(
                  children: [
                    PostListItem(
                      post: post,
                      postNoToIdMap: widget.postNoToIdMap,
                      replyPostIds: widget.replyMap[post.id] ?? [],
                      onShowAttachment: handleShowAttachment,
                      onRequestShowPost: handleRequestShowPost,
                    ),
                    const Divider(height: 1),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
