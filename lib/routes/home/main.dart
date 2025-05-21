import 'package:after_layout/after_layout.dart';
import 'package:cabinet/queries/watchers.graphql.dart';
import 'package:cabinet/routes/home/statistics.dart';
import 'package:cabinet/routes/home/threads.dart';
import 'package:cabinet/widgets/app_bar/title.dart';
import 'package:cabinet/widgets/app_bar/watcher_selector.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

import 'attachments.dart';

class HomeRoute extends StatefulWidget {
  const HomeRoute({super.key});

  @override
  State<HomeRoute> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute>
    with AfterLayoutMixin<HomeRoute> {
  int _selectedTabIndex = 0;

  List<Fragment$FullWatcher>? _watchers;
  Fragment$FullWatcher? _selectedWatcher;

  @override
  void afterFirstLayout(BuildContext context) {
    GraphQLProvider.of(context).value.query$WatchersQuery().then((result) {
      if (result.parsedData == null) {
        return;
      }

      setState(() {
        _watchers = result.parsedData!.watchers;
        _selectedWatcher = _watchers!.isNotEmpty ? _watchers![0] : null;
      });
    });
  }

  void handleSelectTab(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  void handleSelectedWatcherChanged(Fragment$FullWatcher? watcher) {
    setState(() {
      _selectedWatcher = watcher;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_watchers == null) {
      return const Center(child: CircularProgressIndicator());
    }

    PreferredSizeWidget appBar;
    Widget body;
    switch (_selectedTabIndex) {
      case 0:
        body = StatisticsTab();
        appBar = TitleAppBar(title: "Cabinet");
        break;

      case 1:
        body = ThreadsTab();
        appBar = WatcherSelectorAppBar(
          watchers: _watchers!,
          onSelectedWatcherChanged: handleSelectedWatcherChanged,
        );
        break;

      case 2:
        body = AttachmentsTab();
        appBar = WatcherSelectorAppBar(
          watchers: _watchers!,
          onSelectedWatcherChanged: handleSelectedWatcherChanged,
        );
        break;

      default:
        throw Exception('Invalid tab index: $_selectedTabIndex');
    }

    return Provider<Fragment$FullWatcher?>.value(
      value: _selectedWatcher,
      child: Scaffold(
        appBar: appBar,
        body: body,
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Statistics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.all_inbox),
              label: 'Threads',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.photo_library),
              label: 'Attachments',
            ),
          ],

          currentIndex: _selectedTabIndex,
          onTap: handleSelectTab,
        ),
      ),
    );
  }
}
