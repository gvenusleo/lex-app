import "dart:io";

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
