import 'package:cabinet/widgets/app_drawer.dart';
import 'package:flutter/material.dart';

class NoServerUrlRoute extends StatelessWidget {
  const NoServerUrlRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(title: const Text('Cabinet')),
      body: const Center(
        child: Text('No server URL set. Please set it in the settings.'),
      ),
    );
  }
}
