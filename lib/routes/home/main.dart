import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Cabinet')),
      body: const Center(child: Text('Home Page')),
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
