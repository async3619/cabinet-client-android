import 'package:flutter/material.dart';

class ThreadsTab extends StatefulWidget {
  const ThreadsTab({super.key});

  @override
  State<ThreadsTab> createState() => _ThreadsTabState();
}

class _ThreadsTabState extends State<ThreadsTab> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [AppBar(title: const Text('Threads'))]);
  }
}
