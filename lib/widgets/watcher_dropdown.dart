import 'package:flutter/material.dart';

import '../queries/watchers.graphql.dart';

class WatcherDropdown extends StatelessWidget {
  final List<Fragment$FullWatcher> watchers;
  final Fragment$FullWatcher? selectedWatcher;
  final ValueChanged<Fragment$FullWatcher?> onChanged;

  const WatcherDropdown({
    super.key,
    required this.watchers,
    required this.selectedWatcher,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
      onChanged: onChanged,
      value: selectedWatcher,
      hint: const Text('Select a watcher'),
    );
  }
}
