import "dart:io";

import "package:flutter/material.dart";
import "package:hotkey_manager/hotkey_manager.dart";
import "package:isar/isar.dart";
import "package:launch_at_startup/launch_at_startup.dart";
import "package:lex/modules/clipboard_item.dart";
import "package:lex/modules/ocr_item.dart";
import "package:lex/modules/translation_item.dart";
import "package:lex/utils/dir_utils.dart";
import "package:lex/utils/font_utils.dart";
import "package:lex/utils/tray_help.dart";
import "package:local_notifier/local_notifier.dart";
import "package:package_info_plus/package_info_plus.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:window_manager/window_manager.dart";

/// 应用版本号
const String version = "1.0.0-beta.1";

/// 持久化存储
late SharedPreferences prefs;
late Isar isar;

/// 全局初始化
Future<void> init() async {
  WidgetsFlutterBinding.ensureInitialized();

  prefs = await SharedPreferences.getInstance();
  readThemeFont();

  final Directory workDir = await getWorkDir();
  isar = await Isar.open(
    [TranslationItemSchema, OcrItemSchema, ClipboardItemSchema],
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
    title: "Lex",
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
    await windowManager.setPreventClose(true);
  });

  // 开机自启动
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  LaunchAtStartup.instance.setup(
    appName: packageInfo.appName,
    appPath: Platform.resolvedExecutable,
  );

  // 注册系统托盘
  await initTray();

  // 初始化系统通知
  await localNotifier.setup(
    appName: "Lex",
    // 参数 shortcutPolicy 仅适用于 Windows
    shortcutPolicy: ShortcutPolicy.requireCreate,
  );
}
