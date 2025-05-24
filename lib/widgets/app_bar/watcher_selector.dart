import 'package:cabinet/queries/watchers.graphql.dart';
import 'package:cabinet/widgets/watcher_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WatcherSelectorAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  const WatcherSelectorAppBar({
    super.key,
    required this.watchers,
    required this.onSelectedWatcherChanged,
    this.actions = const [],
  });

  final List<Fragment$FullWatcher> watchers;
  final Function(Fragment$FullWatcher?) onSelectedWatcherChanged;
  final List<Widget> actions;

  @override
  State<WatcherSelectorAppBar> createState() => _WatcherSelectorAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _WatcherSelectorAppBarState extends State<WatcherSelectorAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: WatcherDropdown(
        watchers: widget.watchers,
        selectedWatcher: Provider.of<Fragment$FullWatcher>(context),
        onChanged: widget.onSelectedWatcherChanged,
      ),
      actions: widget.actions,
    );
  }
}
