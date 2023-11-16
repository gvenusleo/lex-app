import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:lex/global.dart";
import "package:lex/utils/init_dio.dart";
import "package:lex/utils/service_map.dart";
import "package:url_launcher/url_launcher_string.dart";

/// 彩云小译
class CaiyunTranslation {
  /// 彩云小译
  /// https://docs.caiyunapp.com/blog/2018/09/03/lingocloud-api/
  static Future<String> translate(String text, String from, String to) async {
    try {
      from = languages()[from]!;
      to = languages()[to]!;
    } catch (_) {
      return "error:不支持的语言";
    }
    final String token = (prefs.getString("caiyunToken") ?? "").trim();
    const String url = "http://api.interpreter.caiyunai.com/v1/translator";
    final String direction = "${from}2$to";
    final Map<String, String> query = {
      "source": text,
      "trans_type": direction,
      "request_id": "lex",
      "detect": "true",
    };
    final Map<String, dynamic> headers = {
      "content-type": "application/json",
      "x-authorization": "token $token",
    };

    final Dio dio = initDio();
    final Response response = await dio.post(
      url,
      data: query,
      options: Options(headers: headers),
    );
    return response.data["target"];
  }

  /// 彩云小译支持语言
  /// https://docs.caiyunapp.com/blog/2018/09/03/lingocloud-api/
  static Map<String, String> languages() {
    return {
      "自动": "auto",
      "中文": "zh",
      "英语": "en",
      "日语": "ja",
    };
  }

  /// 检查彩云小译 API 是否设置
  static bool checkApi() {
    if ((prefs.getString("caiyunToken") ?? "").isEmpty) {
      return false;
    }
    return true;
  }

  /// 设置彩云小译 Token
  static Future<void> setApi(BuildContext context) async {
    final tokenController = TextEditingController();
    tokenController.text = prefs.getString("caiyunToken") ?? "";
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: Image.asset(
            translationServiceLogoMap()["caiyun"]!,
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
                        "https://www.lex-app.cn/guide/caiyun.html",
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
}
