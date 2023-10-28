import "dart:io";

import "package:flutter/material.dart";
import "package:hotkey_manager/hotkey_manager.dart";
import "package:isar/isar.dart";
import "package:launch_at_startup/launch_at_startup.dart";
import "package:lex/modules/history_item.dart";
import "package:lex/utils/dir_utils.dart";
import "package:lex/utils/font_utils.dart";
import "package:package_info_plus/package_info_plus.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:tray_manager/tray_manager.dart";
import "package:window_manager/window_manager.dart";

/// 应用版本号
String version = "v0.1.3";

/// 持久化存储
late SharedPreferences prefs;
late Isar isar;

/// 系统托盘菜单
Menu menu = Menu(
  items: [
    MenuItem(
      key: "show_translate",
      label: "输入翻译",
    ),
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

/// 全局初始化
Future<void> init() async {
  WidgetsFlutterBinding.ensureInitialized();

  prefs = await SharedPreferences.getInstance();
  readThemeFont();

  final Directory workDir = await getWorkDir();
  isar = await Isar.open(
    [HistoryItemSchema],
    directory: workDir.path,
  );

  // 设置快捷键
  await hotKeyManager.unregisterAll();

  // 窗口管理
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = WindowOptions(
    alwaysOnTop: true,
    size: (prefs.getBool("firstRun") ?? true)
        ? const Size(800, 600)
        : const Size(360, 400),
    minimumSize: const Size(280, 300),
    center: true,
    backgroundColor: Colors.transparent,
    title: "质感翻译",
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setOpacity(prefs.getDouble("windowOpacity") ?? 1.0);
    if (prefs.getBool("hideWindowAtStartup") ?? false) {
      await windowManager.hide();
    } else {
      await windowManager.show();
      await windowManager.focus();
    }
  });

  // 开机自启动
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  LaunchAtStartup.instance.setup(
    appName: packageInfo.appName,
    appPath: Platform.resolvedExecutable,
  );

  // 注册系统托盘
  await trayManager.destroy();
  await trayManager.setIcon(
    Platform.isWindows ? "assets/logo.ico" : "assets/logo.png",
  );
  await trayManager.setContextMenu(menu);
}
