import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class CameraChannel {
  static const _platform = MethodChannel('samples.flutter.dev/camera');

  /// Takes a picture using platform-specific code and returns the File.
  static Future<File?> takePictureNative() async {
    try {
      final String? path = await _platform.invokeMethod<String>('takePicture');
      if (path != null && path.isNotEmpty) {
        return File(path);
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        log('CameraChannel: PlatformException -> ${e.code}: ${e.message}' , name: 'CameraChannel');
      }
    } catch (e) {
      if (kDebugMode) {
        log('CameraChannel: Unknown error -> $e' , name: 'CameraChannel');
      }
    }
    return null;
  }
}
