import "dart:convert";

import "package:crypto/crypto.dart";
import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:lex/global.dart";
import "package:lex/utils/init_dio.dart";
import "package:lex/utils/service_map.dart";
import "package:url_launcher/url_launcher_string.dart";

/// 百度翻译
class BaiduTranslation {
  /// 百度翻译
  /// https://fanyi-api.baidu.com/product/113
  static Future<String> translate(String text, String from, String to) async {
    try {
      from = languages()[from]!;
      to = languages()[to]!;
    } catch (_) {
      return "error:不支持的语言";
    }
    const String url = "https://fanyi-api.baidu.com/api/trans/vip/translate";
    final String appID = (prefs.getString("baiduAppID") ?? "").trim();
    final String appKey = (prefs.getString("baiduAppKey") ?? "").trim();
    final String salt = DateTime.now().millisecondsSinceEpoch.toString();
    final String sign = _getMd5(appID + text + salt.toString() + appKey);
    final Map<String, String> query = {
      "q": text,
      "from": from,
      "to": to,
      "appid": appID,
      "salt": salt,
      "sign": sign,
    };

    final Dio dio = initDio();
    final Response response = await dio.get(
      url,
      queryParameters: query,
    );
    List resultList = response.data["trans_result"];
    List<String> results = resultList.map((e) => e["dst"].toString()).toList();
    String resultStr = results.join();
    return resultStr;
  }

  /// 百度翻译支持语言
  /// https://fanyi-api.baidu.com/product/113
  static Map<String, String> languages() {
    return {
      "自动": "auto",
      "中文": "zh",
      "英语": "en",
      "粤语": "yue",
      "文言文": "wyw",
      "日语": "jp",
      "韩语": "kor",
      "法语": "fra",
      "西班牙语": "spa",
      "泰语": "th",
      "阿拉伯语": "ara",
      "俄语": "ru",
      "葡萄牙语": "pt",
      "德语": "de",
      "意大利语": "it",
      "希腊语": "el",
      "荷兰语": "nl",
      "波兰语": "pl",
      "保加利亚语": "bul",
      "爱沙尼亚语": "est",
      "丹麦语": "dan",
      "芬兰语": "fin",
      "捷克语": "cs",
      "罗马尼亚语": "rom",
      "斯洛文尼亚语": "slo",
      "瑞典语": "swe",
      "匈牙利语": "hu",
      "繁体中文": "cht",
      "越南语": "vie",
    };
  }

  /// 检查百度翻译 API 是否设置
  static bool checkApi() {
    if ((prefs.getString("baiduAppID") ?? "").isEmpty ||
        (prefs.getString("baiduAppKey") ?? "").isEmpty) {
      return false;
    }
    return true;
  }

  /// 设置百度翻译 AppID 和 AppKey
  static Future<void> setApi(BuildContext context) async {
    final appIDController = TextEditingController();
    final appKeyController = TextEditingController();
    appIDController.text = prefs.getString("baiduAppID") ?? "";
    appKeyController.text = prefs.getString("baiduAppKey") ?? "";
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: Image.asset(
            translationServiceLogoMap()["baidu"]!,
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
                  labelText: "App ID",
                  hintText: "输入百度翻译 App ID",
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

  /// md5 加密
  static String _getMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }
}
