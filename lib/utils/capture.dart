import 'dart:io';

import 'package:lex/utils/dir_utils.dart';
import 'package:screen_capturer/screen_capturer.dart';

/// 屏幕截图，返回图片路径
Future<String?> capture() async {
  Directory ocrDir = await getOcrDir();
  String name = DateTime.now().toIso8601String();
  String imgPath = "${ocrDir.path}${getDirSeparator()}$name.png";
  final captureData = await screenCapturer.capture(
    mode: CaptureMode.region, // screen, window
    imagePath: imgPath,
    copyToClipboard: false,
  );
  if (captureData != null) {
    return captureData.imagePath;
  }
  return null;
}
