import "package:flutter/material.dart";
import "package:metranslate/global.dart";
import "package:url_launcher/url_launcher_string.dart";

/// 设置百度翻译 AppID 和 AppKey
Future<void> setBaidu(BuildContext context) async {
  final appIDController = TextEditingController();
  final appKeyController = TextEditingController();
  appIDController.text = prefs.getString("baiduAppID") ?? "";
  appKeyController.text = prefs.getString("baiduAppKey") ?? "";
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        icon: Image.asset(
          "assets/service/baidu.png",
          width: 40,
          height: 40,
        ),
        title: const Text("百度翻译"),
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
                      "https://www.metranslate.top/guide/baidu.html",
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
                labelText: "APP ID",
                hintText: "输入百度翻译 APP ID",
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: appKeyController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "密钥",
                hintText: "输入百度翻译密钥",
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
              prefs.setString("baiduAppID", appIDController.text);
              prefs.setString("baiduAppKey", appKeyController.text);
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
