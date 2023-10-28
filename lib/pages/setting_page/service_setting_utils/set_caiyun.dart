import "package:flutter/material.dart";
import "package:lex/global.dart";
import "package:url_launcher/url_launcher_string.dart";

/// 设置彩云小译 Token
Future<void> setCaiyun(BuildContext context) async {
  final tokenController = TextEditingController();
  tokenController.text = prefs.getString("caiyunToken") ?? "";
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        icon: Image.asset(
          "assets/service/caiyun.png",
          width: 40,
          height: 40,
        ),
        title: const Text("彩云小译"),
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
                      "https://www.metranslate.top/guide/caiyun.html",
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
                const Spacer()
              ],
            ),
            const SizedBox(height: 18),
            TextField(
              controller: tokenController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Token",
                hintText: "输入彩云小译 Token",
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
              prefs.setString("caiyunToken", tokenController.text);
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
