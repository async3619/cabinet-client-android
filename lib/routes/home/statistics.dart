import 'package:cabinet/queries/statistic.graphql.dart';
import 'package:cabinet/widgets/app_bar/title.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatisticsTab extends StatelessWidget {
  const StatisticsTab({super.key});

  Widget buildBody() {
    final formatter = NumberFormat('###,###,###,###');

    return Scaffold(
      body: Query$StatisticQuery$Widget(
        builder: (result, {fetchMore, refetch}) {
          if (result.parsedData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final threadCount = result.parsedData!.threadCount;
          final postCount = result.parsedData!.postCount;
          final attachmentCount = result.parsedData!.attachmentCount;
          final totalSize = result.parsedData!.totalSize;

          return RefreshIndicator(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              children: [
                Card(
                  child: ListTile(
                    title: const Text('Threads'),
                    subtitle: Text(formatter.format(threadCount)),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: const Text('Posts'),
                    subtitle: Text(formatter.format(postCount)),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: const Text('Attachments'),
                    subtitle: Text(formatter.format(attachmentCount)),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: const Text('Total Size'),
                    subtitle: Text(filesize(totalSize)),
                  ),
                ),
              ],
            ),
            onRefresh: () {
              if (refetch != null) {
                return refetch();
              }

              return Future.value();
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleAppBar(title: "Statistics"),
        Expanded(child: buildBody()),
      ],
    );
  }
}
