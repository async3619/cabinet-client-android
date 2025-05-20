import 'package:cabinet_client_android/queries/watchers.graphql.dart';
import 'package:cabinet_client_android/routes/home/threads.dart';
import 'package:flutter/material.dart';

import 'attachments.dart';

class HomeRoute extends StatefulWidget {
  const HomeRoute({super.key});

  @override
  State<HomeRoute> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void handleSelectTab(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Query$WatchersQuery$Widget(
      builder: (result, {fetchMore, refetch}) {
        Widget body;
        if (result.parsedData == null) {
          body = Scaffold(
            appBar: AppBar(title: const Text('Cabinet')),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else {
          switch (_selectedTabIndex) {
            case 0:
              body = ThreadsTab();
              break;
            case 1:
              body = AttachmentsTab(watchers: result.parsedData!.watchers);
              break;

            default:
              throw Exception('Invalid tab index: $_selectedTabIndex');
          }
        }

        return Scaffold(
          body: body,
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
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
        );
      },
    );
  }
}
