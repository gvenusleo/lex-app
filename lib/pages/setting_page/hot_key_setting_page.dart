import "package:flutter/material.dart";
import "package:hotkey_manager/hotkey_manager.dart";
import "package:lex/global.dart";
import "package:lex/widgets/virtual_key_view.dart";

class HotKeySettingPage extends StatefulWidget {
  const HotKeySettingPage({super.key});

  @override
  State<HotKeySettingPage> createState() => _HotKeySettingPageState();
}

class _HotKeySettingPageState extends State<HotKeySettingPage> {
  // 划词翻译热键存储值
  List<String> _translationHotKeyList =
      prefs.getStringList("translationHotKeyList") ?? ["alt", "keyZ"];

  // OCR 热键存储值
  // List<String> _ocrHotKeyList =
  //     prefs.getStringList("ocrHotKeyList") ?? ["alt", "keyX"];

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
                for (String keyModifierStr
                    in _translationHotKeyList[0].split("-"))
                  VirtualKeyView(
                    keyLabel: keyModifierStr.substring(0, 1).toUpperCase() +
                        keyModifierStr.substring(1),
                  ),
                VirtualKeyView(
                  keyLabel: _translationHotKeyList[1].replaceAll("key", ""),
                ),
              ],
            ),
            onTap: _setTranslationHotKeyFunc,
          ),
          // ListTile(
          //   leading: const Icon(Icons.crop_free_outlined),
          //   title: const Text("文字识别"),
          //   subtitle: const Text("设置文字识别的热键"),
          //   trailing: Wrap(
          //     spacing: 8,
          //     children: [
          //       for (String keyModifierStr in _ocrHotKeyList[0].split("-"))
          //         VirtualKeyView(
          //           keyLabel: keyModifierStr.substring(0, 1).toUpperCase() +
          //               keyModifierStr.substring(1),
          //         ),
          //       VirtualKeyView(
          //         keyLabel: _ocrHotKeyList[1].replaceAll("key", ""),
          //       ),
          //     ],
          //   ),
          //   onTap: _setOcrHotKeyFunc,
          // ),
        ],
      ),
    );
  }

  /// 设置划词翻译快捷键
  Future<void> _setTranslationHotKeyFunc() async {
    List<String> translationHotKeyListTemp = _translationHotKeyList;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          icon: const Icon(Icons.keyboard_outlined),
          title: const Text("划词翻译"),
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
                      "keyCode": translationHotKeyListTemp[1],
                      "modifiers": translationHotKeyListTemp[0].split("-"),
                    },
                  ),
                  onHotKeyRecorded: (key) {
                    Map<String, dynamic> hotKeyMap = key.toJson();
                    translationHotKeyListTemp = [
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
                prefs.setStringList(
                    "translationHotKeyList", translationHotKeyListTemp);
                setState(() {
                  _translationHotKeyList = translationHotKeyListTemp;
                });
                Navigator.pop(context);
              },
              child: const Text("确定"),
            ),
          ],
        );
      },
    );
  }

  /// 设置文字识别快捷键
  // Future<void> _setOcrHotKeyFunc() async {
  //   List<String> ocrHotKeyListTemp = _ocrHotKeyList;
  //   await showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         scrollable: true,
  //         icon: const Icon(Icons.keyboard_outlined),
  //         title: const Text("文字识别"),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             const Text("按下键盘，设置文字识别的快捷键。重启应用后生效。"),
  //             const SizedBox(height: 8),
  //             Center(
  //               child: HotKeyRecorder(
  //                 initalHotKey: HotKey.fromJson(
  //                   {
  //                     "keyCode": ocrHotKeyListTemp[1],
  //                     "modifiers": ocrHotKeyListTemp[0].split("-"),
  //                   },
  //                 ),
  //                 onHotKeyRecorded: (key) {
  //                   Map<String, dynamic> hotKeyMap = key.toJson();
  //                   ocrHotKeyListTemp = [
  //                     hotKeyMap["modifiers"].join("-"),
  //                     hotKeyMap["keyCode"],
  //                   ];
  //                 },
  //               ),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           OutlinedButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text("取消"),
  //           ),
  //           FilledButton(
  //             onPressed: () async {
  //               prefs.setStringList("ocrHotKeyList", ocrHotKeyListTemp);
  //               setState(() {
  //                 _ocrHotKeyList = ocrHotKeyListTemp;
  //               });
  //               Navigator.pop(context);
  //             },
  //             child: const Text("确定"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
