import "package:flutter/material.dart";
import "package:metranslate/global.dart";
import "package:url_launcher/url_launcher_string.dart";

/// 设置有道翻译 AppID 和 AppKey
Future<void> setYoudao(BuildContext context) async {
  final appIDController = TextEditingController();
  final appKeyController = TextEditingController();
  appIDController.text = prefs.getString("youdaoAppID") ?? "";
  appKeyController.text = prefs.getString("youdaoAppKey") ?? "";
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        icon: Image.asset(
          "assets/service/youdao.png",
          width: 40,
          height: 40,
        ),
        title: const Text("有道翻译"),
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
                      "https://www.metranslate.top/guide/youdao.html",
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
                const Spacer()
              ],
            ),
            const SizedBox(height: 18),
            TextField(
              controller: appIDController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "应用 ID",
                hintText: "输入有道翻译应用 ID",
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: appKeyController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "应用密钥",
                hintText: "输入有道翻译应用密钥",
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
              prefs.setString("youdaoAppID", appIDController.text);
              prefs.setString("youdaoAppKey", appKeyController.text);
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
