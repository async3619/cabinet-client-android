import 'package:cabinet_client_android/queries/watcherAttachments.graphql.dart';
import 'package:cabinet_client_android/queries/watchers.graphql.dart';
import 'package:cabinet_client_android/widgets/attachment_grid.dart';
import 'package:cabinet_client_android/widgets/watcher_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AttachmentsTab extends StatefulWidget {
  final List<Fragment$FullWatcher> watchers;

  const AttachmentsTab({super.key, required this.watchers});

  @override
  State<AttachmentsTab> createState() => _AttachmentsTabState();
}

class _AttachmentsTabState extends State<AttachmentsTab> {
  Fragment$FullWatcher? selectedWatcher;

  @override
  void initState() {
    super.initState();
    selectedWatcher = widget.watchers.isNotEmpty ? widget.watchers[0] : null;
  }

  void handleWatcherChange(Fragment$FullWatcher? watcher) {
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
    } else {
      final options = Options$Query$WatcherAttachmentsQuery(
        variables: Variables$Query$WatcherAttachmentsQuery(
          id: int.parse(selectedWatcher!.id),
        ),
        fetchPolicy: FetchPolicy.networkOnly,
      );

      return Query$WatcherAttachmentsQuery$Widget(
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

          final attachments = result.parsedData!.watcher!.attachments;
          if (attachments == null || attachments.isEmpty) {
            return Center(
              child: Text(
                'No attachments found for ${selectedWatcher!.name}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          return RefreshIndicator(
            child: AttachmentGrid(attachments: attachments),
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
