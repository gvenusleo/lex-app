import "package:lex/utils/dir_utils.dart";
import "package:process_run/process_run.dart";

/// 屏幕截图
Future<String?> capture(String color) async {
  try {
    String fullscreenPath = await getOcrFullScreenImgPath();
    String imgPath = await getOcrCaptureImgPath();
    String captureFilePath = await getCaptureFilePath();
    var shell = Shell();
    await shell.run(
      "$captureFilePath --color '#$color' --fullscreen '$fullscreenPath' --capture '$imgPath'",
    );
    return imgPath;
  } catch (_) {
    return null;
  }
}
