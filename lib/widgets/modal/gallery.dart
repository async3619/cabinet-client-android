import 'package:cabinet/queries/watcherThreads.graphql.dart';
import 'package:cabinet/widgets/attachment_grid.dart';
import 'package:flutter/material.dart';

class GalleryModal extends ModalRoute {
  final List<Fragment$FullAttachment> attachments;
  final String title;

  GalleryModal({required this.attachments, required this.title}) : super();

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

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
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
                Text(title),
                Text(
                  '${attachments.length} images',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(child: AttachmentGrid(attachments: attachments)),
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
