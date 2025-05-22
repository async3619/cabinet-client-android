import 'package:cabinet/queries/watcherThreads.graphql.dart';
import 'package:cabinet/queries/watchers.graphql.dart';
import 'package:cabinet/widgets/thread_grid.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

import '../thread.dart';

class ThreadsTab extends StatefulWidget {
  const ThreadsTab({super.key});

  @override
  State<ThreadsTab> createState() => _ThreadsTabState();
}

class _ThreadsTabState extends State<ThreadsTab> {
  @override
  void initState() {
    super.initState();
  }

  handleThreadTap(Fragment$MinimalThread thread) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ThreadRoute(thread: thread)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentWatcher = Provider.of<Fragment$FullWatcher?>(context);
    if (currentWatcher == null) {
      return Center(
        child: Text(
          'Select a watcher to see their threads',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final options = Options$Query$WatcherThreadsQuery(
      variables: Variables$Query$WatcherThreadsQuery(
        id: int.parse(currentWatcher.id),
      ),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    return Query$WatcherThreadsQuery$Widget(
      options: options,
      builder: (result, {fetchMore, refetch}) {
        if (result.parsedData == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (result.parsedData!.watcher == null) {
          return Center(
            child: Text(
              'No watcher found with id: ${currentWatcher.id}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        if (result.parsedData!.watcher!.threads == null ||
            result.parsedData!.watcher!.threads!.isEmpty) {
          return Center(
            child: Text(
              'No threads found for ${currentWatcher.name}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        final threads = result.parsedData!.watcher!.threads!;

        return RefreshIndicator(
          child: ThreadGrid(threads: threads, onThreadTap: handleThreadTap),
          onRefresh: () async {
            if (refetch != null) {
              await refetch();
            }
          },
        );
      },
    );
  }
}
