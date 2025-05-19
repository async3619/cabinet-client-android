import 'package:cabinet_client_android/queries/watcherThreads.graphql.dart';
import 'package:cabinet_client_android/widgets/thread-grid-item.dart';
import 'package:flutter/material.dart';

import '../queries/watchers.graphql.dart';

class ThreadGrid extends StatefulWidget {
  final Fragment$FullWatcher watcher;
  final Function(Fragment$MinimalThread)? onThreadTap;

  const ThreadGrid({super.key, required this.watcher, this.onThreadTap});

  @override
  State<ThreadGrid> createState() => _ThreadGridState();
}

class _ThreadGridState extends State<ThreadGrid> {
  @override
  Widget build(BuildContext context) {
    return Query$WatcherThreadsQuery$Widget(
      options: Options$Query$WatcherThreadsQuery(
        variables: Variables$Query$WatcherThreadsQuery(
          id: int.parse(widget.watcher.id),
        ),
      ),
      builder: (result, {fetchMore, refetch}) {
        if (result.parsedData == null) {
          return Expanded(child: Center(child: CircularProgressIndicator()));
        }

        final threads = result.parsedData!.watcher!.threads!;

        return Expanded(
          child: GridView(
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 3 / 5,
            ),
            children: List.generate(
              threads.length,
              (index) => ThreadGridItem(
                thread: threads[index],
                onTap: (thread) {
                  if (widget.onThreadTap == null) {
                    return;
                  }

                  widget.onThreadTap!(thread);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
