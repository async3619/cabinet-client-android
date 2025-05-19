import 'package:cabinet_client_android/queries/thread.graphql.dart';
import 'package:cabinet_client_android/queries/watcherThreads.graphql.dart';
import 'package:cabinet_client_android/widgets/post_list_item.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';

class PostList extends StatefulWidget {
  final Fragment$MinimalThread thread;
  final GraphQLClient client;

  const PostList({super.key, required this.thread, required this.client});

  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  List<Fragment$FullPost>? posts;
  List<Fragment$FullAttachment>? attachments;

  Future<List<Fragment$FullPost>>? postsFuture;

  @override
  void initState() {
    super.initState();

    postsFuture = this.fetchPostList().then((posts) {
      setState(() {
        this.posts = posts;
        attachments =
            posts
                .expand(
                  (post) => post.attachments ?? <Fragment$FullAttachment>[],
                )
                .toList();
      });

      return posts;
    });
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

  @override
  Widget build(BuildContext context) {
    String title =
        widget.thread.title ?? "Thread #${widget.thread.id.split("::").last}";

    return Scaffold(
      appBar: AppBar(title: Text(title)),
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
            itemCount: posts!.length,
            itemBuilder: (context, index) {
              final post = posts![index];
              return PostListItem(post: post);
            },
          );
        },
      ),
    );
  }
}
