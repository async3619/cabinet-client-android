import 'package:cabinet/queries/watcherThreads.graphql.dart';
import 'package:cabinet/utils/attachment.dart';
import 'package:cabinet/widgets/video_progress.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaViewer extends StatefulWidget {
  const MediaViewer({
    super.key,
    required this.attachment,
    required this.isActive,
  });

  final Fragment$FullAttachment attachment;
  final bool isActive;

  @override
  State<MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends State<MediaViewer> {
  VideoPlayerController? _controller;
  ChewieController? _chewieController;
  bool isVideoInitialized = false;
  bool isVideoPlaying = true;
  bool showControls = false;

  @override
  void didUpdateWidget(MediaViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    handleInitialize();
  }

  @override
  void initState() {
    super.initState();
    handleInitialize();
  }

  @override
  void dispose() {
    handleFinalize();
    super.dispose();
  }

  handleInitialize() {
    if (!widget.attachment.isVideo) {
      return;
    }

    if (!widget.isActive) {
      if (_controller != null && _chewieController != null) {
        setState(() {
          handleFinalize();
          _controller = null;
          _chewieController = null;
        });
      }

      return;
    }

    debugPrint(getAttachmentUrl(widget.attachment));
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(getAttachmentUrl(widget.attachment)),
    );

    if (_controller == null) {
      return;
    }

    _controller!.addListener(() {
      if (_controller!.value.isPlaying != isVideoPlaying) {
        setState(() {
          isVideoPlaying = _controller!.value.isPlaying;
        });
      }
    });

    _controller!.initialize().then((_) {
      _chewieController = ChewieController(
        videoPlayerController: _controller!,
        autoPlay: true,
        looping: true,
        autoInitialize: true,
        allowFullScreen: false,
        showControls: false,
        showControlsOnInitialize: false,
      );

      setState(() {
        isVideoInitialized = true;
      });
    });
  }

  handleFinalize() {
    if (widget.attachment.isVideo &&
        _controller != null &&
        _chewieController != null) {
      _controller!.dispose();
      _chewieController!.dispose();
    }
  }

  handlePlayPause() {
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
  }

  Widget buildImage() {
    return Image.network(
      getAttachmentUrl(widget.attachment),
      fit: BoxFit.cover,
    );
  }

  Widget buildVideo() {
    if (!isVideoInitialized ||
        _chewieController == null ||
        _controller == null) {
      return Image.network(
        getAttachmentThumbnailUrl(widget.attachment),
        fit: BoxFit.cover,
      );
    }

    return Chewie(controller: _chewieController!);
  }

  @override
  Widget build(BuildContext context) {
    final attachment = widget.attachment;
    Widget child;
    if (!attachment.isVideo) {
      child = buildImage();
    } else {
      child = buildVideo();
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Row(
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: attachment.width / attachment.height,
                  child: child,
                ),
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              setState(() {
                showControls = !showControls;
              });
            },
          ),
        ),
        if (widget.isActive && attachment.isVideo && showControls)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.black.withValues(alpha: 0.75),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: IconButton(
                        splashRadius: 24,
                        iconSize: 32,
                        onPressed: handlePlayPause,
                        icon: Icon(
                          isVideoPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    VideoProgress(controller: _controller!),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
