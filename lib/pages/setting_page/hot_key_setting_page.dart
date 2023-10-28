import "package:flutter/material.dart";
import "package:hotkey_manager/hotkey_manager.dart";
import "package:lex/global.dart";
import "package:lex/widgets/virtual_key_view.dart";

class HotKeySettingPage extends StatefulWidget {
  const HotKeySettingPage({Key? key}) : super(key: key);

  @override
  State<HotKeySettingPage> createState() => _HotKeySettingPageState();
}

class _HotKeySettingPageState extends State<HotKeySettingPage> {
  // 热键存储值
  late List<String> _hotKeyList;

  @override
  void initState() {
    _initHotKey();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("热键设置"),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 18),
        children: [
          ListTile(
            leading: const Icon(Icons.drive_file_rename_outline),
            title: const Text("划词翻译"),
            subtitle: const Text("设置划词翻译的热键"),
            trailing: Wrap(
              spacing: 8,
              children: [
                for (String keyModifierStr in _hotKeyList[0].split("-"))
                  VirtualKeyView(
                    keyLabel: keyModifierStr.substring(0, 1).toUpperCase() +
                        keyModifierStr.substring(1),
                  ),
                VirtualKeyView(
                  keyLabel: _hotKeyList[1].replaceAll("key", ""),
                ),
              ],
            ),
            onTap: _setHotKeyFunc,
          ),
        ],
      ),
    );
  }

  /// 初始化快捷键
  void _initHotKey() {
    _hotKeyList = prefs.getStringList("hotKeyList") ?? ["alt", "keyZ"];
  }

  /// 设置快捷键
  Future<void> _setHotKeyFunc() async {
    List<String> hotKeyListTemp = _hotKeyList;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          icon: const Icon(Icons.keyboard_outlined),
          title: const Text("快捷键"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("按下键盘，设置划词翻译的快捷键。重启应用后生效。"),
              const SizedBox(height: 8),
              Center(
                child: HotKeyRecorder(
                  initalHotKey: HotKey.fromJson(
                    {
                      "keyCode": hotKeyListTemp[1],
                      "modifiers": hotKeyListTemp[0].split("-"),
                    },
                  ),
                  onHotKeyRecorded: (key) {
                    Map<String, dynamic> hotKeyMap = key.toJson();
                    hotKeyListTemp = [
                      hotKeyMap["modifiers"].join("-"),
                      hotKeyMap["keyCode"],
                    ];
                  },
                ),
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("取消"),
            ),
            FilledButton(
              onPressed: () async {
                prefs.setStringList("hotKeyList", hotKeyListTemp);
                setState(() {
                  _hotKeyList = hotKeyListTemp;
                });
                Navigator.pop(context);
              },
              child: const Text("确定"),
            ),
          ],
        );
      },
    );
    _initHotKey();
  }
}
