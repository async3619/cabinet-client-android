import 'package:cabinet_client_android/queries/watcherThreads.graphql.dart';
import 'package:cabinet_client_android/queries/watchers.graphql.dart';
import 'package:cabinet_client_android/widgets/thread-grid.dart';
import 'package:flutter/material.dart';

import '../thread.dart';

class ThreadsTab extends StatefulWidget {
  const ThreadsTab({super.key});

  @override
  State<ThreadsTab> createState() => _ThreadsTabState();
}

class _ThreadsTabState extends State<ThreadsTab> {
  Fragment$FullWatcher? selectedWatcher;

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

  buildWatcherDropdown(List<Fragment$FullWatcher> watchers) {
    return DropdownButton<Fragment$FullWatcher>(
      items:
          watchers
              .map(
                (watcher) => DropdownMenuItem<Fragment$FullWatcher>(
                  value: watcher,
                  child: Text(watcher.name),
                ),
              )
              .toList(),
      onChanged: (value) {
        setState(() {
          selectedWatcher = value;
        });
      },
      value: selectedWatcher,
      hint: const Text('Select a watcher'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Query$WatchersQuery$Widget(
      builder: (result, {fetchMore, refetch}) {
        if (result.parsedData == null) {
          return Column(
            children: [
              AppBar(title: const Text('Threads')),
              Expanded(child: Center(child: CircularProgressIndicator())),
            ],
          );
        }

        final watchers = result.parsedData!.watchers;

        Widget content;
        if (selectedWatcher == null) {
          content = Center(
            child: Text(
              'Select a watcher to see their threads',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        } else {
          content = ThreadGrid(
            watcher: selectedWatcher!,
            onThreadTap: handleThreadTap,
          );
        }

        return Column(
          children: [
            AppBar(title: buildWatcherDropdown(watchers)),
            Expanded(child: content),
          ],
        );
      },
    );
  }
}
