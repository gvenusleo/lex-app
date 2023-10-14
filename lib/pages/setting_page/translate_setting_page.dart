import "package:flutter/material.dart";
import "package:metranslate/global.dart";

/// 翻译设置页面
class TranslateSettingPage extends StatefulWidget {
  const TranslateSettingPage({Key? key}) : super(key: key);

  @override
  State<TranslateSettingPage> createState() => _TranslateSettingPageState();
}

class _TranslateSettingPageState extends State<TranslateSettingPage> {
  final Map<String, String> _autoCopyModes = {
    "close": "关闭",
    "source": "原文",
    "result": "译文",
    "both": "原文+译文",
  };

  // 自动复制
  String _autoCopy = prefs.getString("autoCopy") ?? "close";
  // 删除换行
  bool _deleteLineBreak = prefs.getBool("deleteLineBreak") ?? false;
  // 使用代理
  late bool _useProxy;
  // 代理地址
  late String _proxyAddress;

  final TextEditingController _proxyAddressController = TextEditingController();

  @override
  void initState() {
    _useProxy = prefs.getBool("useProxy") ?? false;
    _proxyAddress = prefs.getString("proxyAddress") ?? "";
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
          ListTile(
            leading: const Icon(Icons.copy_outlined),
            title: const Text("自动复制"),
            subtitle: const Text("设置翻译后复制的内容"),
            trailing: Text(
              _autoCopyModes[_autoCopy] ?? "关闭",
              style: const TextStyle(fontSize: 16),
            ),
            onTap: _setAutoCopyFunc,
          ),
          SwitchListTile(
            value: _deleteLineBreak,
            onChanged: (value) {
              prefs.setBool("deleteLineBreak", value);
              setState(() {
                _deleteLineBreak = value;
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

  /// 设置自动复制
  Future<void> _setAutoCopyFunc() async {
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
            children: _autoCopyModes
                .map(
                  (key, value) => MapEntry(
                    key,
                    RadioListTile(
                      value: key,
                      groupValue: _autoCopy,
                      title: Text(value),
                      onChanged: (e) {
                        if (e != null) {
                          prefs.setString("autoCopy", e);
                          setState(() {
                            _autoCopy = e;
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
