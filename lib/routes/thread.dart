import 'package:cabinet/queries/watcherThreads.graphql.dart';
import 'package:cabinet/widgets/post_list.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ThreadRoute extends StatefulWidget {
  final Fragment$MinimalThread thread;

  const ThreadRoute({super.key, required this.thread});

  @override
  ThreadRouteState createState() => ThreadRouteState();
}

class ThreadRouteState extends State<ThreadRoute> {
  @override
  Widget build(BuildContext context) {
    return GraphQLConsumer(
      builder: (client) => PostList(thread: widget.thread, client: client),
    );
  }
}
