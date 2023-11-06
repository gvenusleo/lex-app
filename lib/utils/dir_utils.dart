import "dart:io";

import "package:lex/global.dart";
import "package:path_provider/path_provider.dart";

/// 获取工作目录
Future<Directory> getWorkDir() async {
  return await getApplicationSupportDirectory();
}

/// 获取文件夹路径分隔符
String getDirSeparator() {
  if (Platform.isWindows) {
    return "\\";
  } else {
    return "/";
  }
}

/// 获取字体文件目录
Future<Directory> getFontDir() async {
  final Directory appWorkDir = await getWorkDir();
  final String fontDirPath = "${appWorkDir.path}${getDirSeparator()}fonts";
  final Directory fontDir = Directory(fontDirPath);
  if (!(await fontDir.exists())) {
    await fontDir.create(recursive: true);
  }
  return fontDir;
}

/// 获取 OCR 截图文件目录
Future<Directory> getOcrDir() async {
  final Directory appWorkDir = await getWorkDir();
  final String ocrPath = "${appWorkDir.path}${getDirSeparator()}capture";
  final Directory ocrDir = Directory(ocrPath);
  if (!ocrDir.existsSync()) {
    ocrDir.createSync(recursive: true);
  }
  return ocrDir;
}

/// 获取 OCR 截图全屏图像文件路径
Future<String> getOcrFullScreenImgPath() async {
  final Directory ocrDir = await getOcrDir();
  return "${ocrDir.path}${getDirSeparator()}fullscreen.png";
}

/// 获取 OCR 区域截图图像文件路径
Future<String> getOcrCaptureImgPath() async {
  final Directory ocrDir = await getOcrDir();
  return "${ocrDir.path}${getDirSeparator()}capture.png";
}

/// 获取 capture 可执行文件路径，不存在则复制
Future<String> getCaptureFilePath() async {
  final String ocrDirPath = (await getOcrDir()).path;
  final String fileName =
      Platform.isWindows ? "capture-$version.exe" : "capture-$version";
  final String capturePath = "$ocrDirPath${getDirSeparator()}$fileName";
  if (!File(capturePath).existsSync()) {
    final String captureExePath = Platform.isWindows
        ? "assets/capture/capture-$version.exe"
        : "assets/capture/capture-$version";
    final File captureExeFile = File(captureExePath);
    await captureExeFile.copy(capturePath);
  }
  return capturePath;
}
