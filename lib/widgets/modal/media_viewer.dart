import 'package:cabinet_client_android/queries/watcherThreads.graphql.dart';
import 'package:flutter/material.dart';

import '../media_viewer.dart';

class MediaViewerModal extends ModalRoute {
  final List<Fragment$FullAttachment> attachments;

  final Function(int)? onIndexChanged;

  late final PageController pageController;

  int currentIndex = 0;

  MediaViewerModal({
    this.onIndexChanged,
    required this.attachments,
    this.currentIndex = 0,
  }) : super() {
    pageController = PageController(initialPage: currentIndex);
  }

  @override
  Color get barrierColor => Colors.black.withValues(alpha: 0.75);

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 100);

  handlePageChanged(int index) {
    setState(() {
      currentIndex = index;
    });

    if (onIndexChanged != null) {
      onIndexChanged!(index);
    }

    changedExternalState();
  }

  Widget buildViewer(
    BuildContext context,
    Fragment$FullAttachment attachment,
    int index,
  ) {
    final isActive = index == currentIndex;

    return MediaViewer(attachment: attachment, isActive: isActive);
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final currentAttachment = attachments[currentIndex];

    return Material(
      type: MaterialType.transparency,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${currentAttachment.name}${currentAttachment.$extension}',
                ),
                Text(
                  '${currentIndex + 1} / ${attachments.length}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            actions: [],
          ),
          Expanded(
            child: PageView(
              controller: pageController,
              onPageChanged: handlePageChanged,
              children: [
                for (var index = 0; index < attachments.length; index++)
                  buildViewer(context, attachments[index], index),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(animation),
        child: ScaleTransition(
          scale: Tween<double>(begin: 1, end: 1).animate(animation),
          child: child,
        ),
      ),
    );
  }
}
