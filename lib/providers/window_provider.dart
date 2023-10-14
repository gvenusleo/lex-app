import "package:flutter/material.dart";
import "package:metranslate/global.dart";
import "package:window_manager/window_manager.dart";

/// 翻译窗口状态管理
class WindowProvider extends ChangeNotifier {
  // 窗口置顶
  bool alwaysOnTop = true;
  // 窗口大小
  Size size = prefs.getStringList("windowSize") == null
      ? const Size(360, 400)
      : Size(
          double.parse(prefs.getStringList("windowSize")![0]),
          double.parse(prefs.getStringList("windowSize")![1]),
        );
  // 窗口位置
  Offset? position;

  /// 切换窗口置顶
  Future<void> changeAlwaysOnTop([bool? alwaysOnTop]) async {
    this.alwaysOnTop = alwaysOnTop ?? !this.alwaysOnTop;
    notifyListeners();
    await windowManager.setAlwaysOnTop(this.alwaysOnTop);
  }

  /// 切换窗口大小
  Future<void> changeWindowSize(Size size) async {
    this.size = size;
    notifyListeners();
    await prefs.setStringList(
      "windowSize",
      [size.width.toString(), size.height.toString()],
    );
  }

  /// 切换窗口位置
  void changeWindowPosition(Offset position) {
    this.position = position;
    notifyListeners();
  }
}
