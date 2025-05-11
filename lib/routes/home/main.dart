import 'package:cabinet_client_android/routes/home/threads.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'attachments.dart';

class HomeRoute extends StatefulWidget {
  const HomeRoute({super.key});

  @override
  State<HomeRoute> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  int _selectedTabIndex = 0;

  void handleSelectTab(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget selectedTab;
    switch (_selectedTabIndex) {
      case 0:
        selectedTab = ThreadsTab();
        break;
      case 1:
        selectedTab = AttachmentsTab();
        break;

      default:
        throw Exception('Invalid tab index: $_selectedTabIndex');
    }

    return Scaffold(
      body: selectedTab,
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
  }
}
