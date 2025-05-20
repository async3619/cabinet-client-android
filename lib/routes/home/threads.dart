import 'package:cabinet/queries/watcherThreads.graphql.dart';
import 'package:cabinet/queries/watchers.graphql.dart';
import 'package:cabinet/widgets/thread_grid.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../widgets/watcher_dropdown.dart';
import '../thread.dart';

class ThreadsTab extends StatefulWidget {
  final List<Fragment$FullWatcher> watchers;

  const ThreadsTab({super.key, required this.watchers});

  @override
  State<ThreadsTab> createState() => _ThreadsTabState();
}

class _ThreadsTabState extends State<ThreadsTab> {
  Fragment$FullWatcher? selectedWatcher;

  @override
  void initState() {
    super.initState();

    selectedWatcher = widget.watchers.isNotEmpty ? widget.watchers[0] : null;
  }

  handleThreadTap(Fragment$MinimalThread thread) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ThreadRoute(thread: thread)),
    );
  }

  handleWatcherChange(Fragment$FullWatcher? watcher) {
    setState(() {
      selectedWatcher = watcher;
    });
  }

  Widget buildBody() {
    if (selectedWatcher == null) {
      return Center(
        child: Text(
          'Select a watcher to see their threads',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final options = Options$Query$WatcherThreadsQuery(
      variables: Variables$Query$WatcherThreadsQuery(
        id: int.parse(selectedWatcher!.id),
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
              'No watcher found with id: ${selectedWatcher!.id}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        if (result.parsedData!.watcher!.threads == null ||
            result.parsedData!.watcher!.threads!.isEmpty) {
          return Center(
            child: Text(
              'No threads found for ${selectedWatcher!.name}',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: WatcherDropdown(
          watchers: widget.watchers,
          selectedWatcher: selectedWatcher,
          onChanged: handleWatcherChange,
        ),
      ),
      body: buildBody(),
    );
  }
}
