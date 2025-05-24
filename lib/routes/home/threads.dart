import 'package:cabinet/models/config.dart';
import 'package:cabinet/queries/watcherThreads.graphql.dart';
import 'package:cabinet/queries/watchers.graphql.dart';
import 'package:cabinet/widgets/thread_grid.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

import '../../widgets/app_bar/watcher_selector.dart';
import '../thread.dart';

class ThreadsTab extends StatefulWidget {
  const ThreadsTab({
    super.key,
    required this.watchers,
    required this.onSelectedWatcherChanged,
  });

  final List<Fragment$FullWatcher> watchers;
  final Function(Fragment$FullWatcher?) onSelectedWatcherChanged;

  @override
  State<ThreadsTab> createState() => _ThreadsTabState();
}

class _ThreadsTabState extends State<ThreadsTab> {
  final Map<ThreadSortOption, String> _sortOptionLabels = {
    ThreadSortOption.bumpOrder: 'Bump Order',
    ThreadSortOption.replyCount: 'Reply Count',
    ThreadSortOption.imageCount: 'Image Count',
    ThreadSortOption.newest: 'Newest',
    ThreadSortOption.oldest: 'Oldest',
  };

  ThreadSortOption? _sortOption;

  @override
  void initState() {
    super.initState();

    // Initialize the sort option from the config
    _sortOption =
        Provider.of<ConfigModel>(context, listen: false).threadSortOption ??
        ThreadSortOption.bumpOrder;
  }

  handleThreadTap(Fragment$MinimalThread thread) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ThreadRoute(thread: thread)),
    );
  }

  handleSelectSortOption(String value) {
    ThreadSortOption? selectedOption;
    try {
      selectedOption = ThreadSortOption.values.firstWhere(
        (option) => option.name == value,
      );
    } catch (e) {
      // If the value is not a valid ThreadSortOption, do nothing
      return;
    }

    setState(() {
      _sortOption = selectedOption;
    });

    Provider.of<ConfigModel>(
      context,
      listen: false,
    ).setThreadSortOption(selectedOption);
  }

  Widget buildBody() {
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
        final sortedThreads = threads.toList();

        sortedThreads.sort((a, b) {
          switch (_sortOption) {
            case ThreadSortOption.bumpOrder:
              final aBumpedAt = a.bumpedAt ?? a.createdAt;
              final bBumpedAt = b.bumpedAt ?? b.createdAt;

              return bBumpedAt.compareTo(aBumpedAt);

            case ThreadSortOption.replyCount:
              return b.$_count.posts.compareTo(a.$_count.posts);

            case ThreadSortOption.imageCount:
              return b.attachmentCount.compareTo(a.attachmentCount);

            case ThreadSortOption.newest:
              return b.createdAt.compareTo(a.createdAt);

            case ThreadSortOption.oldest:
              return a.createdAt.compareTo(b.createdAt);

            default:
              return 0;
          }
        });

        return RefreshIndicator(
          child: ThreadGrid(
            threads: sortedThreads,
            onThreadTap: handleThreadTap,
          ),
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
    return Column(
      children: [
        WatcherSelectorAppBar(
          watchers: widget.watchers,
          onSelectedWatcherChanged: widget.onSelectedWatcherChanged,
          actions: [
            // Add popup menu button with sort icon
            PopupMenuButton(
              icon: const Icon(Icons.sort),
              itemBuilder:
                  (context) =>
                      _sortOptionLabels.entries.map((entry) {
                        return CheckedPopupMenuItem<String>(
                          checked: entry.key == _sortOption,
                          value: entry.key.name,
                          child: Text(entry.value),
                        );
                      }).toList(),
              onSelected: handleSelectSortOption,
            ),
          ],
        ),
        Expanded(child: buildBody()),
      ],
    );
  }
}
