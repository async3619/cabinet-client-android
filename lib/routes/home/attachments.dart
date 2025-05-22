import 'package:cabinet/queries/watcherAttachments.graphql.dart';
import 'package:cabinet/queries/watchers.graphql.dart';
import 'package:cabinet/widgets/attachment_grid.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

class AttachmentsTab extends StatefulWidget {
  const AttachmentsTab({super.key});

  @override
  State<AttachmentsTab> createState() => _AttachmentsTabState();
}

class _AttachmentsTabState extends State<AttachmentsTab> {
  Fragment$FullWatcher? selectedWatcher;

  @override
  Widget build(BuildContext context) {
    final selectedWatcher = Provider.of<Fragment$FullWatcher?>(context);
    if (selectedWatcher == null) {
      return Center(
        child: Text(
          'Select a watcher to see their threads',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final options = Options$Query$WatcherAttachmentsQuery(
      variables: Variables$Query$WatcherAttachmentsQuery(
        id: int.parse(selectedWatcher.id),
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
              'No watcher found with id: ${selectedWatcher.id}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        final attachments = result.parsedData!.watcher!.attachments;
        if (attachments == null || attachments.isEmpty) {
          return Center(
            child: Text(
              'No attachments found for ${selectedWatcher.name}',
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
