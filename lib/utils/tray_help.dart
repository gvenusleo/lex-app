import 'dart:io';

import 'package:lex/global.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

/// 初始化系统托盘
Future<void> initTray() async {
  Menu menu = Menu(
    items: [
      MenuItem(
        key: "show_translate",
        label: "输入翻译",
      ),
      // MenuItem(
      //   key: "ocr",
      //   label: "文字识别",
      // ),
      MenuItem.separator(),
      MenuItem.submenu(
        key: "autoCopy",
        label: "自动复制",
        submenu: Menu(
          items: [
            MenuItem(
              key: "closeAutoCopy",
              label: "关闭",
              onClick: (_) async {
                await prefs.setString("autoCopy", "close");
              },
            ),
            MenuItem.separator(),
            MenuItem(
              key: "autoCopySource",
              label: "原文",
              onClick: (_) async {
                await prefs.setString("autoCopy", "source");
              },
            ),
            MenuItem(
              key: "autoCopyResult",
              label: "译文",
              onClick: (_) async {
                await prefs.setString("autoCopy", "result");
              },
            ),
            MenuItem(
              key: "autoCopyBoth",
              label: "原文+译文",
              onClick: (_) async {
                await prefs.setString("autoCopy", "both");
              },
            ),
          ],
        ),
      ),
      MenuItem(
        key: "show_settings",
        label: "应用设置",
      ),
      MenuItem.separator(),
      MenuItem(
        key: "exit_app",
        label: "退出应用",
      ),
    ],
  );

  await trayManager.destroy();
  await trayManager.setIcon(
    Platform.isWindows ? "assets/logo.ico" : "assets/logo.png",
  );
  await trayManager.setContextMenu(menu);
}

/// 隐藏窗口到系统托盘
Future<void> hideToTray() async {
  await windowManager.hide();
  await windowManager.setSkipTaskbar(true);
}
