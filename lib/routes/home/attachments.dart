import 'package:flutter/material.dart';

class AttachmentsTab extends StatefulWidget {
  const AttachmentsTab({super.key});

  @override
  State<AttachmentsTab> createState() => _AttachmentsTabState();
}

class _AttachmentsTabState extends State<AttachmentsTab> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [AppBar(title: const Text('Attachments'))]);
  }
}
