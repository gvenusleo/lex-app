import "package:flutter/material.dart";
import "package:launch_at_startup/launch_at_startup.dart";
import "package:metranslate/global.dart";
import "package:metranslate/providers/theme_provider.dart";
import "package:metranslate/widgets/list_tile_group_title.dart";
import "package:provider/provider.dart";
import "package:window_manager/window_manager.dart";

/// 应用设置页面
class AppSettingPage extends StatefulWidget {
  const AppSettingPage({Key? key}) : super(key: key);

  @override
  State<AppSettingPage> createState() => _AppSettingPageState();
}

class _AppSettingPageState extends State<AppSettingPage> {
  final List<String> _themeModes = [
    "跟随系统",
    "浅色模式",
    "深色模式",
  ];
  // 窗口透明度
  late double _windowOpacity;
  // 窗口是非跟随鼠标
  late bool _windowFllowCursor;
  late bool _useRoundedWindow;
  // 是否开机自启动
  bool _launchAtStartup = false;
  // 启动时隐藏窗口
  late bool _hideWindowAtStartup;

  @override
  void initState() {
    launchAtStartup.isEnabled().then((value) {
      setState(() {
        _launchAtStartup = value;
      });
    });
    _windowOpacity = prefs.getDouble("windowOpacity") ?? 1.0;
    _windowFllowCursor = prefs.getBool("windowFollowCursor") ?? false;
    _useRoundedWindow = prefs.getBool("useRoundedWindow") ?? true;
    _hideWindowAtStartup = prefs.getBool("hideWindowAtStartup") ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("应用设置"),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 18),
        children: [
          const ListTileGroupTitle(title: "主题设置"),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text("主题背景"),
            subtitle: const Text("设置应用主题背景"),
            trailing: Text(
              _themeModes[context.watch<ThemeProvider>().themeMode],
              style: const TextStyle(fontSize: 16),
            ),
            onTap: setThemeMode,
          ),
          SwitchListTile(
            value: context.watch<ThemeProvider>().useSystemThemeColor,
            onChanged: (value) async {
              context.read<ThemeProvider>().changeUseSystemAccentColor(value);
            },
            secondary: const Icon(Icons.color_lens_outlined),
            title: const Text("使用系统主题颜色"),
            subtitle: const Text("应用主题颜色跟随系统"),
          ),
          ListTile(
            leading: const Icon(Icons.opacity_outlined),
            title: const Text("窗口透明度"),
            subtitle: const Text("设置应用窗口透明度"),
            trailing: SizedBox(
              width: 140,
              child: Slider(
                value: _windowOpacity,
                min: 0.5,
                max: 1.0,
                divisions: 5,
                label: _windowOpacity.toStringAsFixed(1),
                onChanged: (value) async {
                  setState(() {
                    _windowOpacity = value;
                  });
                  prefs.setDouble("windowOpacity", value);
                  windowManager.setOpacity(value);
                },
              ),
            ),
          ),
          const ListTileGroupTitle(title: "窗口设置"),
          SwitchListTile(
            value: _windowFllowCursor,
            onChanged: (value) async {
              setState(() {
                _windowFllowCursor = value;
              });
              await prefs.setBool("windowFollowCursor", value);
            },
            secondary: const Icon(Icons.window_outlined),
            title: const Text("窗口跟随鼠标"),
            subtitle: const Text("划词翻译时窗口跟随鼠标"),
          ),
          SwitchListTile(
            value: _useRoundedWindow,
            onChanged: (value) async {
              setState(() {
                _useRoundedWindow = value;
              });
              prefs.setBool("useRoundedWindow", value);
            },
            secondary: const Icon(Icons.rounded_corner_rounded),
            title: const Text("使用圆角窗口"),
            subtitle: const Text("重启应用后生效"),
          ),
          SwitchListTile(
            value: _launchAtStartup,
            onChanged: (value) async {
              setState(() {
                _launchAtStartup = value;
              });
              if (value == true) {
                await launchAtStartup.enable();
              } else {
                await launchAtStartup.disable();
              }
            },
            secondary: const Icon(Icons.open_in_new_outlined),
            title: const Text("开机自启动"),
            subtitle: const Text("登录系统时自动启动"),
          ),
          SwitchListTile(
            value: _hideWindowAtStartup,
            onChanged: (value) async {
              setState(() {
                _hideWindowAtStartup = value;
              });
              await prefs.setBool("hideWindowAtStartup", value);
            },
            secondary: const Icon(Icons.visibility_off_outlined),
            title: const Text("启动时隐藏窗口"),
            subtitle: const Text("启动应用时自动隐藏到系统托盘"),
          ),
        ],
      ),
    );
  }

  /// 设置主题模式
  Future<void> setThemeMode() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.dark_mode_outlined),
          title: const Text("主题背景"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _themeModes.map((e) {
              return RadioListTile(
                value: _themeModes.indexOf(e),
                groupValue: context.watch<ThemeProvider>().themeMode,
                onChanged: (value) {
                  if (value != null) {
                    context.read<ThemeProvider>().changeThemeMode(value);
                    Navigator.pop(context);
                  }
                },
                title: Text(e),
              );
            }).toList(),
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("取消"),
            ),
          ],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 12,
          ),
          scrollable: true,
        );
      },
    );
  }
}
