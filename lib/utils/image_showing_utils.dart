import 'dart:io';

import 'package:flutter/material.dart';

class ImageShowingUtils{
  Widget buildMediaPreview(String url) {
    final isLocalFile = url.startsWith('/') || url.startsWith('file://');

    if (isLocalFile) {
      /// Handle offline image (local file path)
      final file = url.startsWith('file://')
          ? File(Uri.parse(url).path)
          : File(url);

      return Image.file(
        file,

        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(

            color: Colors.grey.shade300,
            child: const Icon(
              Icons.broken_image,
              color: Colors.redAccent,
              size: 36,
            ),
          );
        },
      );
    } else {
      /// Handle online image (URL)
      return Image.network(
        url,

        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(

            color: Colors.grey.shade300,
            child: const Icon(
              Icons.broken_image,
              color: Colors.redAccent,
              size: 36,
            ),
          );
        },
      );
    }
  }
}