import "dart:convert";
import "dart:io";

import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:lex/global.dart";
import "package:lex/utils/init_dio.dart";
import "package:lex/utils/service_map.dart";
import "package:url_launcher/url_launcher_string.dart";

/// 百度 OCR
class BaiduOcr {
  /// 使用百度 OCR 识别图片中的文字
  /// https://cloud.baidu.com/doc/OCR/s/1k3h7y3db
  static Future<String> ocr(String imgPath, String language) async {
    const String url =
        "https://aip.baidubce.com/rest/2.0/ocr/v1/accurate_basic";
    const Map<String, String> headers = {
      "Content-Type": "application/x-www-form-urlencoded",
    };
    final Map<String, String> query = {
      "access_token": await _getAccessToken(),
    };
    final Map<String, String> data = {
      "image": const Base64Encoder().convert(File(imgPath).readAsBytesSync()),
      "language_type": language,
    };

    final Dio dio = initDio();
    final Response response = await dio.post(
      url,
      queryParameters: query,
      data: data,
      options: Options(headers: headers),
    );
    List words = response.data["words_result"];
    String result = "";
    for (var word in words) {
      result += "${word["words"]}\n";
    }
    return result;
  }

  /// 百度 OCR 支持的语言
  static Map<String, String> languages() {
    return {
      "自动检测": "auto_detect",
      "中英文混合": "CHN_ENG",
      "英文": "ENG",
      "日语": "JAP",
      "韩语": "KOR",
      "法语": "FRE",
      "西班牙语": "SPA",
      "葡萄牙语": "POR",
      "德语": "GER",
      "意大利语": "ITA",
      "俄语": "RUS",
      "丹麦语": "DAN",
      "荷兰语": "DUT",
      "马来语": "MAL",
      "瑞典语": "SWE",
      "印尼语": "IND",
      "波兰语": "POL",
      "罗马尼亚语": "ROM",
      "土耳其语": "TUR",
      "希腊语": "GRE",
      "匈牙利语": "HUN",
      "泰语": "THA",
      "越南语": "VIE",
      "阿拉伯语": "ARA",
      "印地语": "HIN",
    };
  }

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

  /// 获取 Access_token
  /// https://ai.baidu.com/ai-doc/REFERENCE/Ck3dwjhhu
  static Future<String> _getAccessToken() async {
    final apiKey = prefs.getString("baiduOcrApiKey") ?? "";
    final secretKey = prefs.getString("baiduOcrSecretKey") ?? "";
    const String url = "https://aip.baidubce.com/oauth/2.0/token";
    const Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json"
    };
    final Map<String, String> query = {
      "grant_type": "client_credentials",
      "client_id": apiKey,
      "client_secret": secretKey,
    };
    final Dio dio = initDio();
    final Response response = await dio.post(
      url,
      queryParameters: query,
      options: Options(headers: headers),
    );
    return response.data["access_token"];
  }
}
