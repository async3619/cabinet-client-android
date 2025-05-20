import 'package:cabinet/queries/thread.graphql.dart';
import 'package:cabinet/queries/watcherThreads.graphql.dart';
import 'package:cabinet/widgets/modal/media_viewer.dart';
import 'package:cabinet/widgets/post_list_item.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import 'modal/gallery.dart';

class PostList extends StatefulWidget {
  final Fragment$MinimalThread thread;
  final GraphQLClient client;

  const PostList({super.key, required this.thread, required this.client});

  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  AutoScrollController? scrollController;

  List<Fragment$FullPost>? posts;

  Future<List<Fragment$FullPost>>? postsFuture;

  @override
  void initState() {
    super.initState();

    postsFuture = fetchPostList().then((posts) {
      setState(() {
        this.posts = posts;
      });

      return posts;
    });

    scrollController = AutoScrollController();
  }

  Future<List<Fragment$FullPost>> fetchPostList() async {
    final options = Options$Query$ThreadQuery(
      variables: Variables$Query$ThreadQuery(id: widget.thread.id),
    );

    final result = await widget.client.query$ThreadQuery(options);
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final data = result.parsedData;
    if (data == null || data.thread == null || data.thread!.posts == null) {
      throw Exception("No data available");
    }

    return data.thread!.posts!;
  }

  void handleMediaIndexChanged(int newIndex) {
    var attachmentPostIndexMap = <int, int>{};
    int attachmentIndex = 0;
    for (var i = 0; i < posts!.length; i++) {
      final attachments = posts![i].attachments;
      if (attachments == null) {
        continue;
      }

      for (var j = 0; j < attachments.length; j++) {
        attachmentPostIndexMap[attachmentIndex] = i;
        attachmentIndex++;
      }
    }

    final postIndex = attachmentPostIndexMap[newIndex];
    if (postIndex == null) {
      throw Exception("Post index not found");
    }

    scrollController!.scrollToIndex(
      postIndex,
      preferPosition: AutoScrollPosition.begin,
    );
  }

  void handleShowAttachment(
    Fragment$FullAttachment attachment,
    Fragment$FullPost post,
  ) {
    final allPosts = posts!;
    int startIndex = 0;
    for (var i = 0; i < allPosts.length; i++) {
      if (allPosts[i].id == post.id) {
        break;
      }

      startIndex += allPosts[i].attachments?.length ?? 0;
    }

    final targetPost = allPosts.firstWhere((p) => p.id == post.id);
    if (targetPost.attachments == null || targetPost.attachments == null) {
      throw Exception("No attachments available");
    }

    final attachmentIndex = targetPost.attachments!.indexWhere(
      (a) => a.id == attachment.id,
    );
    if (attachmentIndex == -1) {
      throw Exception("Attachment not found");
    }

    final attachmentIndexInAllPosts = startIndex + attachmentIndex;
    final allAttachments =
        allPosts
            .expand((p) => p.attachments ?? <Fragment$FullAttachment>[])
            .toList();

    Navigator.of(context).push(
      MediaViewerModal(
        attachments: allAttachments,
        currentIndex: attachmentIndexInAllPosts,
        onIndexChanged: handleMediaIndexChanged,
      ),
    );
  }

  void handleShowGallery() {
    if (posts == null) {
      return;
    }

    final allAttachments =
        posts!
            .expand((p) => p.attachments ?? <Fragment$FullAttachment>[])
            .toList();

    Navigator.of(context).push(
      GalleryModal(
        attachments: allAttachments,
        title:
            widget.thread.title ??
            "Thread #${widget.thread.id.split("::").last}",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String title =
        widget.thread.title ?? "Thread #${widget.thread.id.split("::").last}";

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: handleShowGallery,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                postsFuture = fetchPostList();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (posts == null || posts!.isEmpty) {
            return const Center(child: Text("No posts available"));
          }

          return ListView.builder(
            controller: scrollController,
            itemCount: posts!.length,
            itemBuilder: (context, index) {
              final post = posts![index];
              return AutoScrollTag(
                key: ValueKey(index),
                controller: scrollController!,
                index: index,
                child: PostListItem(
                  post: post,
                  onShowAttachment: handleShowAttachment,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
