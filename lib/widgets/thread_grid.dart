import 'package:cabinet/queries/watcherThreads.graphql.dart';
import 'package:cabinet/widgets/thread_grid_item.dart';
import 'package:flutter/material.dart';

class ThreadGrid extends StatefulWidget {
  final Function(Fragment$MinimalThread)? onThreadTap;
  final List<Fragment$MinimalThread> threads;

  const ThreadGrid({super.key, this.onThreadTap, required this.threads});

  @override
  State<ThreadGrid> createState() => _ThreadGridState();
}

class _ThreadGridState extends State<ThreadGrid> {
  @override
  Widget build(BuildContext context) {
    final threads = widget.threads;

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
  }
}
