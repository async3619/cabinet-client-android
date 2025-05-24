import 'package:cabinet/entities/thread_read_status.dart';
import 'package:cabinet/queries/watcherThreads.graphql.dart';
import 'package:cabinet/widgets/thread_grid_item.dart';
import 'package:flutter/material.dart';

class ThreadGrid extends StatefulWidget {
  final Function(Fragment$MinimalThread)? onThreadTap;
  final List<Fragment$MinimalThread> threads;
  final List<ThreadReadStatus>? readStatus;

  const ThreadGrid({
    super.key,
    this.onThreadTap,
    required this.threads,
    this.readStatus,
  });

  @override
  State<ThreadGrid> createState() => _ThreadGridState();
}

class _ThreadGridState extends State<ThreadGrid> {
  @override
  Widget build(BuildContext context) {
    final threads = widget.threads;
    final readStatus = widget.readStatus ?? [];

    return GridView(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 3 / 5,
      ),
      children: List.generate(
        threads.length,
        (index) => Opacity(
          opacity:
              readStatus.any((status) => status.threadId == threads[index].id)
                  ? 0.5
                  : 1.0,
          child: ThreadGridItem(
            thread: threads[index],
            onTap: widget.onThreadTap,
          ),
        ),
      ),
    );
  }
}
