import 'package:flutter/material.dart';
import 'package:lex/global.dart';

class OcrSettingPage extends StatefulWidget {
  const OcrSettingPage({super.key});

  @override
  State<OcrSettingPage> createState() => _OcrSettingPageState();
}

class _OcrSettingPageState extends State<OcrSettingPage> {
  // 自动复制
  bool _autoCopyOcrResult = prefs.getBool("autoCopyOcrResult") ?? false;
  // 删除换行
  bool _deleteOcrLineBreak = prefs.getBool("deleteOcrLineBreak") ?? false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("文字识别"),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 18),
        children: [
          SwitchListTile(
            value: _autoCopyOcrResult,
            onChanged: (value) {
              prefs.setBool("autoCopyOcrResult", value);
              setState(() {
                _autoCopyOcrResult = value;
              });
            },
            secondary: const Icon(Icons.copy_outlined),
            title: const Text("自动复制"),
            subtitle: const Text("自动复制文字识别结果"),
          ),
          SwitchListTile(
            value: _deleteOcrLineBreak,
            onChanged: (value) {
              prefs.setBool("deleteOcrLineBreak", value);
              setState(() {
                _deleteOcrLineBreak = value;
              });
            },
            secondary: const Icon(Icons.keyboard_return_outlined),
            title: const Text("删除换行"),
            subtitle: const Text("删除文本换行符"),
          ),
        ],
      ),
    );
  }
}
