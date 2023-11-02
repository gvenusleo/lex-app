import "package:flutter/material.dart";
import "package:lex/global.dart";
import "package:lex/widgets/list_tile_group_title.dart";

/// 翻译设置页面
class TranslationSettingPage extends StatefulWidget {
  const TranslationSettingPage({Key? key}) : super(key: key);

  @override
  State<TranslationSettingPage> createState() => _TranslationSettingPageState();
}

class _TranslationSettingPageState extends State<TranslationSettingPage> {
  final Map<String, String> _autoCopyTranslationsResultModes = {
    "close": "关闭",
    "source": "原文",
    "result": "译文",
    "both": "原文+译文",
  };

  // 原文语言
  String _fromLanguage = prefs.getString("fromLanguage") ?? "自动";
  // 目标语言
  String _toLanguage = prefs.getString("toLanguage") ?? "中文";
  // 已启用的语言
  final List<String> _enabledLanguages =
      prefs.getStringList("enabledLanguages") ??
          [
            "自动",
            "中文",
            "英语",
            "日语",
            "韩语",
            "法语",
            "德语",
            "俄语",
            "意大利语",
            "葡萄牙语",
            "繁体中文",
          ];
  // 记住目标语言
  bool _rememberToLanguage = prefs.getBool("rememberToLanguage") ?? true;
  // 自动复制
  String _autoCopyTranslationsResult =
      prefs.getString("autoCopyTranslationsResult") ?? "close";
  // 删除换行
  bool _deleteTranslationLineBreak =
      prefs.getBool("deleteTranslationLineBreak") ?? false;
  // 使用代理
  bool _useProxy = prefs.getBool("useProxy") ?? false;
  // 代理地址
  final String _proxyAddress = prefs.getString("proxyAddress") ?? "";

  final TextEditingController _proxyAddressController = TextEditingController();

  @override
  void initState() {
    _proxyAddressController.text = _proxyAddress;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("翻译设置"),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 18),
        children: [
          const ListTileGroupTitle(title: "语言设置"),
          ListTile(
            leading: const Icon(Icons.east_outlined),
            title: const Text("原文语言"),
            subtitle: const Text("翻译时默认的原文语言"),
            trailing: Text(
              _fromLanguage,
              style: const TextStyle(fontSize: 16),
            ),
            onTap: _setFromLanguage,
          ),
          ListTile(
            leading: const Icon(Icons.west_outlined),
            title: const Text("目标语言"),
            subtitle: const Text("翻译时默认的目标语言"),
            trailing: Text(
              _toLanguage,
              style: const TextStyle(fontSize: 16),
            ),
            onTap: _setToLanguage,
          ),
          SwitchListTile(
            value: _rememberToLanguage,
            onChanged: (value) async {
              prefs.setBool("rememberToLanguage", value);
              setState(() {
                _rememberToLanguage = value;
              });
            },
            secondary: const Icon(Icons.beenhere_outlined),
            title: const Text("记住目标语言"),
            subtitle: const Text("切换目标语言时自动记忆"),
          ),
          const ListTileGroupTitle(title: "功能设置"),
          ListTile(
            leading: const Icon(Icons.copy_outlined),
            title: const Text("自动复制"),
            subtitle: const Text("设置翻译后复制的内容"),
            trailing: Text(
              _autoCopyTranslationsResultModes[_autoCopyTranslationsResult] ??
                  "关闭",
              style: const TextStyle(fontSize: 16),
            ),
            onTap: _setautoCopyTranslationsResultFunc,
          ),
          SwitchListTile(
            value: _deleteTranslationLineBreak,
            onChanged: (value) {
              prefs.setBool("deleteTranslationLineBreak", value);
              setState(() {
                _deleteTranslationLineBreak = value;
              });
            },
            secondary: const Icon(Icons.keyboard_return_outlined),
            title: const Text("删除换行"),
            subtitle: const Text("删除文本换行符"),
          ),
          SwitchListTile(
            value: _useProxy,
            onChanged: (value) async {
              setState(() {
                _useProxy = value;
              });
              await prefs.setBool("useProxy", value);
            },
            secondary: const Icon(Icons.travel_explore_outlined),
            title: const Text("使用代理"),
            subtitle: const Text("使用代理服务器进行翻译"),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 54, right: 28),
            child: TextField(
              controller: _proxyAddressController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "代理地址",
                prefixText: "http://",
              ),
              onChanged: (value) {
                prefs.setString("proxyAddress", value);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 设置原文语言
  Future<void> _setFromLanguage() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.east_outlined),
          title: const Text("原文语言"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _enabledLanguages.map((e) {
              return RadioListTile(
                value: e,
                groupValue: _fromLanguage,
                onChanged: (value) async {
                  if (value != null) {
                    prefs.setString("fromLanguage", value);
                    setState(() {
                      _fromLanguage = value;
                    });
                  }
                  Navigator.pop(context);
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

  /// 设置目标语言
  Future<void> _setToLanguage() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.west_outlined),
          title: const Text("目标语言"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _enabledLanguages.sublist(1).map((e) {
              return RadioListTile(
                value: e,
                groupValue: _toLanguage,
                onChanged: (value) async {
                  if (value != null) {
                    prefs.setString("toLanguage", value);
                    setState(() {
                      _toLanguage = value;
                    });
                  }
                  Navigator.pop(context);
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

  /// 设置自动复制
  Future<void> _setautoCopyTranslationsResultFunc() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.copy_outlined),
          title: const Text("自动复制"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _autoCopyTranslationsResultModes
                .map(
                  (key, value) => MapEntry(
                    key,
                    RadioListTile(
                      value: key,
                      groupValue: _autoCopyTranslationsResult,
                      title: Text(value),
                      onChanged: (e) {
                        if (e != null) {
                          prefs.setString("autoCopyTranslationsResult", e);
                          setState(() {
                            _autoCopyTranslationsResult = e;
                          });
                        }
                        Navigator.pop(context);
                      },
                    ),
                  ),
                )
                .values
                .toList(),
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
