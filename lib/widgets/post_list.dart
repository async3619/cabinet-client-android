import 'package:cabinet_client_android/queries/watcherThreads.graphql.dart';
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
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
