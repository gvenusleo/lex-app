import "package:clipboard_watcher/clipboard_watcher.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:hotkey_manager/hotkey_manager.dart";
import "package:isar/isar.dart";
import "package:lex/global.dart";
import "package:lex/modules/clipboard_item.dart";
import "package:lex/pages/clipboard_page.dart";
import "package:lex/pages/setting_page/settings_page.dart";
import "package:lex/pages/translation_page.dart";
import "package:lex/providers/window_provider.dart";
import "package:lex/utils/tray_help.dart";
import "package:provider/provider.dart";
import "package:screen_retriever/screen_retriever.dart";
import "package:screen_text_extractor/screen_text_extractor.dart";
import "package:tray_manager/tray_manager.dart";
import "package:window_manager/window_manager.dart";

/// 应用主窗口
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with WindowListener, TrayListener, ClipboardListener {
  // 当前页面
  Widget? _selectedPage;

  @override
  void initState() {
    windowManager.addListener(this);
    trayManager.addListener(this);
    clipboardWatcher.addListener(this);
    clipboardWatcher.start();
    if (prefs.getBool("firstRun") ?? true) {
      _setSettingWindow();
      _selectedPage = const SettingsPage();
      Future.delayed(const Duration(seconds: 3), () {
        prefs.setBool("firstRun", false);
      });
    } else {
      _selectedPage = TranslationPage(
        key: UniqueKey(),
      );
    }
    _initHotKey();
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    trayManager.removeListener(this);
    clipboardWatcher.removeListener(this);
    clipboardWatcher.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DragToResizeArea(
      child: Scaffold(
        body: Column(
          children: [
            // 标题栏与窗口按钮
            Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      await context.read<WindowProvider>().changeAlwaysOnTop();
                    },
                    icon: Icon(
                      context.watch<WindowProvider>().alwaysOnTop
                          ? Icons.push_pin
                          : Icons.push_pin_outlined,
                      color: context.watch<WindowProvider>().alwaysOnTop
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    padding: const EdgeInsets.all(0),
                    visualDensity: VisualDensity.compact,
                    // tooltip: context.watch<WindowProvider>().alwaysOnTop
                    //     ? "取消置顶"
                    //     : "置顶",
                    focusNode: FocusNode(
                      skipTraversal: true,
                      canRequestFocus: false,
                    ),
                  ),
                  const Expanded(
                    child: DragToMoveArea(
                      child: Text(
                        "v$version",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.transparent),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      windowManager.minimize();
                    },
                    icon: const Icon(Icons.expand_more_outlined),
                    padding: const EdgeInsets.all(0),
                    visualDensity: VisualDensity.compact,
                    // tooltip: "最小化",
                    focusNode: FocusNode(
                      skipTraversal: true,
                      canRequestFocus: false,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      windowManager.close();
                    },
                    icon: const Icon(Icons.close_outlined),
                    padding: const EdgeInsets.all(0),
                    visualDensity: VisualDensity.compact,
                    // tooltip: "关闭",
                    focusNode: FocusNode(
                      skipTraversal: true,
                      canRequestFocus: false,
                    ),
                  ),
                ],
              ),
            ),
            // 页面主体
            Expanded(
              child: _selectedPage!,
            ),
          ],
        ),
      ),
    );
  }

  /// 窗口关闭事件
  @override
  void onWindowClose() async {
    await _saveTranslateWindow();
    await hideToTray();
  }

  @override
  void onWindowFocus() {
    setState(() {});
  }

  /// 系统托盘点击事件
  @override
  void onTrayIconMouseDown() {
    trayManager.popUpContextMenu();
  }

  /// 系统托盘点击事件
  @override
  void onTrayIconRightMouseDown() async {
    await trayManager.popUpContextMenu();
  }

  /// 系统托盘点击事件
  @override
  Future<void> onTrayMenuItemClick(MenuItem menuItem) async {
    switch (menuItem.key) {
      // 显示翻译页面
      case "show_translate":
        await windowManager.setSkipTaskbar(false);
        await _setTranslateWindow(
          () => setState(() {
            _selectedPage = TranslationPage(
              key: UniqueKey(),
            );
          }),
        );
        break;
      // 截图文字识别
      // case "ocr":
      //   await ocrFunc();
      //   break;
      // 剪切板管理
      case "clipboard":
        await windowManager.setSkipTaskbar(false);
        await _saveTranslateWindow();
        setState(() {
          _selectedPage = ClipboardPage(key: UniqueKey());
        });
        break;
      // 显示设置页面
      case "show_settings":
        await windowManager.setSkipTaskbar(false);
        await _saveTranslateWindow();
        setState(() {
          _selectedPage = const SettingsPage();
        });
        await _setSettingWindow();
        break;
      // 退出应用
      case "exit_app":
        await windowManager.setPreventClose(false);
        windowManager.close();
        break;
    }
  }

  /// 剪切板监听
  @override
  Future<void> onClipboardChanged() async {
    ClipboardData? newClipboardData =
        await Clipboard.getData(Clipboard.kTextPlain);
    String? text = newClipboardData?.text;
    if (text == null || text == "") return;
    // 判断是否与上一条纪录相同
    ClipboardItem? lastItem =
        isar.clipboardItems.where().sortByTimeDesc().findFirstSync();
    if (lastItem == null || lastItem.text != text) {
      ClipboardItem newItem = ClipboardItem()
        ..text = text
        ..time = DateTime.now();
      isar.writeTxnSync(() => isar.clipboardItems.putSync(newItem));
      if (_selectedPage is ClipboardPage) {
        setState(() {
          _selectedPage = ClipboardPage(key: UniqueKey());
        });
      }
    }
  }

  /// 注册系统快捷键
  Future<void> _initHotKey() async {
    // 划词翻译
    List<String> translationHotKeyList =
        prefs.getStringList("translationHotKeyList") ?? ["alt", "keyZ"];
    HotKey hotKey = HotKey.fromJson(
      {
        "keyCode": translationHotKeyList[1],
        "modifiers": translationHotKeyList[0].split("-"),
        "scope": "system",
      },
    );
    await hotKeyManager.register(
      hotKey,
      keyDownHandler: (hotKey) async {
        try {
          String? selectedText;
          ExtractedData? selectedData = await ScreenTextExtractor.instance
              .extract(mode: ExtractMode.screenSelection);
          if (selectedData != null) {
            selectedText = selectedData.text ?? "";
            if (prefs.getBool("deleteTranslationLineBreak") ?? false) {
              selectedText = selectedText.replaceAll("\n", " ").trim();
            }
          }
          if (prefs.getBool("windowFollowCursor") ?? false) {
            if (!mounted) return;
            context.read<WindowProvider>().changeWindowPosition(
                  await screenRetriever.getCursorScreenPoint(),
                );
          }
          _setTranslateWindow(
            () => setState(() {
              _selectedPage = TranslationPage(
                key: UniqueKey(),
                selectedText: selectedText,
              );
            }),
          );
        } catch (e) {
          if (prefs.getBool("windowFollowCursor") ?? false) {
            if (!mounted) return;
            context.read<WindowProvider>().changeWindowPosition(
                  await screenRetriever.getCursorScreenPoint(),
                );
          }
          _setTranslateWindow(
            () => setState(() {
              _selectedPage = TranslationPage(key: UniqueKey());
            }),
          );
        }
      },
    );
    // 文字识别
    //   List<String> ocrHotKeyList =
    //       prefs.getStringList("ocrHotKeyList") ?? ["alt", "keyX"];
    //   hotKey = HotKey.fromJson(
    //     {
    //       "keyCode": ocrHotKeyList[1],
    //       "modifiers": ocrHotKeyList[0].split("-"),
    //     },
    //   );
    //   hotKey.scope = HotKeyScope.system;
    //   await hotKeyManager.register(
    //     hotKey,
    //     keyDownHandler: (hotKey) async {
    //       await ocrFunc();
    //     },
    //   );
    // }

    // /// 截图文字识别
    // Future<void> ocrFunc() async {
    //   if ((prefs.getStringList("enabledOcrServices") ?? []).isEmpty) {
    //     LocalNotification notification = LocalNotification(
    //       title: "Lex",
    //       body: "文字识别服务未启用！",
    //       actions: [
    //         LocalNotificationAction(
    //           text: "现在启用",
    //         ),
    //       ],
    //     );
    //     notification.onClickAction = (actionIndex) async {
    //       await _saveTranslateWindow();
    //       setState(() {
    //         _selectedPage = SettingsPage(
    //           key: UniqueKey(),
    //           focusedItem: "服务设置",
    //         );
    //       });
    //       await _setSettingWindow();
    //     };
    //     notification.show();
    //     return;
    //   }
    //   try {
    //     Color color = Theme.of(context).colorScheme.primary;
    //     String colorStr = color.value.toRadixString(16).substring(2);
    //     await windowManager.hide();
    //     String? captureImgPath = await capture(colorStr);
    //     if (captureImgPath != null) {
    //       await _setOcrWindow(
    //         () => setState(() {
    //           _selectedPage = OcrPage(
    //             key: UniqueKey(),
    //             imagePath: captureImgPath,
    //           );
    //         }),
    //       );
    //     }
    //   } catch (e) {
    //     return;
    //   }
  }

  /// 设置翻译窗口
  Future<void> _setTranslateWindow(Function() setPage) async {
    if (_selectedPage is! TranslationPage) {
      await windowManager.hide();
      setPage();
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      await windowManager.setSize(context.read<WindowProvider>().size);
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      if (context.read<WindowProvider>().position != null) {
        await windowManager
            .setPosition(context.read<WindowProvider>().position!);
      }
      await Future.delayed(const Duration(milliseconds: 100));
      await windowManager.show();
    } else {
      setPage();
      if (prefs.getBool("windowFollowCursor") ?? false) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (!mounted) return;
        if (context.read<WindowProvider>().position != null) {
          await windowManager
              .setPosition(context.read<WindowProvider>().position!);
        }
        await Future.delayed(const Duration(milliseconds: 100));
      }
      await windowManager.show();
    }
    if (!mounted) return;
    await context.read<WindowProvider>().changeAlwaysOnTop(true);
    await windowManager.setResizable(true);
  }

  /// 设置设置窗口
  Future<void> _setSettingWindow() async {
    await windowManager.hide();
    await Future.delayed(const Duration(milliseconds: 100));
    await windowManager.setSize(const Size(800, 600));
    await Future.delayed(const Duration(milliseconds: 100));
    await windowManager.center(animate: true);
    await Future.delayed(const Duration(milliseconds: 100));
    await windowManager.show();
    if (!mounted) return;
    await context.read<WindowProvider>().changeAlwaysOnTop(true);
    //await windowManager.setResizable(false);
  }

  /// 设置文字识别窗口
  // Future<void> _setOcrWindow(Function() setPage) async {
  //   setPage();
  //   await Future.delayed(const Duration(milliseconds: 100));
  //   await lexwindowManager.setSize(const Size(800, 400));
  //   await Future.delayed(const Duration(milliseconds: 100));
  //   await lexwindowManager.center(animate: true);
  //   await Future.delayed(const Duration(milliseconds: 100));
  //   await lexwindowManager.show();
  //   if (!mounted) return;
  //   await context.read<WindowProvider>().changeAlwaysOnTop(true);
  // }

  /// 保存当前窗口状态
  Future<void> _saveTranslateWindow() async {
    if (_selectedPage is TranslationPage) {
      final Size size = await windowManager.getSize();
      final Offset position = await windowManager.getPosition();
      if (!mounted) return;
      context.read<WindowProvider>().changeWindowPosition(position);
      await context.read<WindowProvider>().changeWindowSize(size);
    }
  }
}
