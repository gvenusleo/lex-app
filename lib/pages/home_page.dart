import "package:flutter/material.dart";
import "package:hotkey_manager/hotkey_manager.dart";
import "package:metranslate/global.dart";
import "package:metranslate/pages/setting_page/settings_page.dart";
import "package:metranslate/pages/translate_page.dart";
import "package:metranslate/providers/window_provider.dart";
import "package:provider/provider.dart";
import "package:screen_retriever/screen_retriever.dart";
import "package:screen_text_extractor/screen_text_extractor.dart";
import "package:tray_manager/tray_manager.dart";
import "package:window_manager/window_manager.dart";

/// 应用主窗口
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WindowListener, TrayListener {
  Widget? _selectedPage;

  @override
  void initState() {
    windowManager.addListener(this);
    trayManager.addListener(this);
    if (prefs.getBool("firstRun") ?? true) {
      _setSettingWindow();
      _selectedPage = const SettingsPage();
      Future.delayed(const Duration(seconds: 3), () {
        prefs.setBool("firstRun", false);
      });
    } else {
      _selectedPage = TranslatePage(
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
                  ),
                  Expanded(
                    child: DragToMoveArea(
                      child: Text(
                        version,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.transparent),
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
                  ),
                  IconButton(
                    onPressed: () {
                      windowManager.hide();
                    },
                    icon: const Icon(Icons.close_outlined),
                    padding: const EdgeInsets.all(0),
                    visualDensity: VisualDensity.compact,
                    // tooltip: "关闭",
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
        await _setTranslateWindow(
          () => setState(() {
            _selectedPage = TranslatePage(
              key: UniqueKey(),
            );
          }),
        );
        break;
      // 显示设置页面
      case "show_settings":
        await _saveTranslateWindow();
        setState(() {
          _selectedPage = const SettingsPage();
        });
        await _setSettingWindow();
        break;
      // 退出应用
      case "exit_app":
        windowManager.close();
        break;
    }
  }

  /// 注册系统快捷键
  Future<void> _initHotKey() async {
    List<String> hotKeyList =
        prefs.getStringList("hotKeyList") ?? ["alt", "keyZ"];
    HotKey hotKey = HotKey.fromJson(
      {
        "keyCode": hotKeyList[1],
        "modifiers": hotKeyList[0].split("-"),
      },
    );
    hotKey.scope = HotKeyScope.system;
    await hotKeyManager.register(
      hotKey,
      keyDownHandler: (hotKey) async {
        if (prefs.getBool("windowFollowCursor") ?? false) {
          if (!mounted) return;
          context.read<WindowProvider>().changeWindowPosition(
                await screenRetriever.getCursorScreenPoint(),
              );
        }
        _setTranslateWindow(
          () => setState(() {
            _selectedPage = TranslatePage(key: UniqueKey());
          }),
        );
        try {
          String? selectedText;
          ExtractedData? selectedData = await ScreenTextExtractor.instance
              .extract(mode: ExtractMode.screenSelection);
          if (selectedData != null) {
            selectedText = selectedData.text ?? "";
            if (prefs.getBool("deleteLineBreak") ?? false) {
              selectedText = selectedText.replaceAll("\n", " ").trim();
            }
          }
        } catch (e) {
          return;
        }
      },
    );
  }

  /// 设置翻译窗口
  Future<void> _setTranslateWindow(Function() setPage) async {
    if (_selectedPage is! TranslatePage) {
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

  /// 保存当前窗口状态
  Future<void> _saveTranslateWindow() async {
    if (_selectedPage is TranslatePage) {
      final Size size = await windowManager.getSize();
      final Offset position = await windowManager.getPosition();
      if (!mounted) return;
      context.read<WindowProvider>().changeWindowPosition(position);
      await context.read<WindowProvider>().changeWindowSize(size);
    }
  }
}
