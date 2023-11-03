import 'package:flutter/material.dart';
import 'package:lex/global.dart';
import 'package:lex/utils/service_map.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// 百度 OCR
class BaiduOcr {
  /// 判断是否设置了百度 OCR App Key 和 Secret Key
  static bool checkApi() {
    if ((prefs.getString("baiduOcrApiKey") ?? "").isEmpty ||
        (prefs.getString("baiduOcrSecretKey") ?? "").isEmpty) {
      return false;
    }
    return true;
  }

  /// 设置百度 OCR App Key 和 Secret Key
  static Future<void> setApi(BuildContext context) async {
    final apikeyController = TextEditingController();
    final secretKeyController = TextEditingController();
    apikeyController.text = prefs.getString("baiduOcrApiKey") ?? "";
    secretKeyController.text = prefs.getString("baiduOcrSecretKey") ?? "";
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: Image.asset(
            ocrServiceLogoMap()["baidu"]!,
            width: 40,
            height: 40,
          ),
          title: const Text("百度文字识别"),
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
                controller: apikeyController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "API Key",
                  hintText: "输入百度文字识别 API Key",
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: secretKeyController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Secret Key",
                  hintText: "输入百度文字识别 Secret Key",
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
                prefs.setString("baiduOcrApiKey", apikeyController.text);
                prefs.setString("baiduOcrSecretKey", secretKeyController.text);
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
}
