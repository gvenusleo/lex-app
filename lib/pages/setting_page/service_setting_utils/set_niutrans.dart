import "package:flutter/material.dart";
import "package:lex/global.dart";
import "package:url_launcher/url_launcher_string.dart";

/// 设置小牛翻译 ApiKey
Future<void> setNiutrans(BuildContext context) async {
  final apiKeyController = TextEditingController();
  apiKeyController.text = prefs.getString("niutransApiKey") ?? "";
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        icon: Image.asset(
          "assets/service/niutrans.png",
          width: 40,
          height: 40,
        ),
        title: const Text("小牛翻译"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                InkWell(
                  child: Text(
                    "查看配置指南 >>",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  onTap: () {
                    launchUrlString(
                      "https://www.metranslate.top/guide/niutrans.html",
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
                const Spacer()
              ],
            ),
            const SizedBox(height: 18),
            TextField(
              controller: apiKeyController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "API Key",
                hintText: "输入小牛翻译 API Key",
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("取消"),
          ),
          FilledButton(
            onPressed: () {
              prefs.setString("niutransApiKey", apiKeyController.text);
              Navigator.pop(context);
            },
            child: const Text("保存"),
          ),
        ],
        scrollable: true,
      );
    },
  );
}
