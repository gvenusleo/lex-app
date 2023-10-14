import "package:flutter/material.dart";
import "package:metranslate/global.dart";
import "package:url_launcher/url_launcher_string.dart";

/// 设置火山翻译 AccessKeyID 和 SecretAccessKey
Future<void> setVolcengine(BuildContext context) async {
  final accessKeyIDController = TextEditingController();
  final secretAccessKeyController = TextEditingController();
  accessKeyIDController.text = prefs.getString("volcengineAccessKeyID") ?? "";
  secretAccessKeyController.text =
      prefs.getString("volcengineSecretAccessKey") ?? "";
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        icon: Image.asset(
          "assets/service/volcengine.png",
          width: 40,
          height: 40,
        ),
        title: const Text("火山翻译"),
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
                      "https://www.metranslate.top/guide/volcengine.html",
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
                const Spacer()
              ],
            ),
            const SizedBox(height: 18),
            TextField(
              controller: accessKeyIDController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Access Key ID",
                hintText: "输入火山翻译 Access Key ID",
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: secretAccessKeyController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Secret Access Key",
                hintText: "输入火山翻译 Secret Access Key",
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
              prefs.setString(
                "volcengineAccessKeyID",
                accessKeyIDController.text,
              );
              prefs.setString(
                "volcengineSecretAccessKey",
                secretAccessKeyController.text,
              );
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
