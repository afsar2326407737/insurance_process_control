import 'dart:ui';
import 'package:flutter/material.dart';
import 'image_showing_utils.dart';

class ImageDialog extends StatefulWidget {
  const ImageDialog({
    super.key,
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  State<ImageDialog> createState() => _ImageDialogState();
}

class _ImageDialogState extends State<ImageDialog> {
  final TransformationController _controller = TransformationController();

  /// Transform image back to original size
  void _handleDoubleTap() {
    if (_controller.value != Matrix4.identity()) {
      _controller.value = Matrix4.identity();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: InteractiveViewer(
                clipBehavior: Clip.none,
                transformationController: _controller,
                minScale: 0.5,
                maxScale: 4.0,
                child: GestureDetector(
                  onTap: () {},
                  child: Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: EdgeInsets.zero,
                    child: GestureDetector(
                      onDoubleTap: _handleDoubleTap,
                      behavior: HitTestBehavior.translucent,
                      child: ImageShowingUtils().buildMediaPreview(widget.imageUrl),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Close Icon to exit fullscreen image
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () => Navigator.pop(context),
            ),)
        ],
      ),
    );
  }
}