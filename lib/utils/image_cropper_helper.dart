import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class ImageCropperHelper {
  static Future<File?> cropImage({
    required File imageFile,
    String title = 'Edit Image',
    CropAspectRatioPreset aspectRatioPreset = CropAspectRatioPreset.original,
  }) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: title,
          toolbarColor: const Color(0xFF8E2DE2),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: aspectRatioPreset,
          lockAspectRatio: false,
          activeControlsWidgetColor: const Color(0xFF6A82FB),
          hideBottomControls: false,
          cropGridColor: Colors.white54,
          cropFrameColor: Colors.white,
          backgroundColor: Colors.black,
        ),
        IOSUiSettings(
          title: title,
          doneButtonTitle: 'Save',
          cancelButtonTitle: 'Cancel',
        ),
      ],
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
    } else {
      return null; // user canceled cropping
    }
  }
}
