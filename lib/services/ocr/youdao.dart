import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lex/global.dart';
import 'package:lex/utils/init_dio.dart';
import 'package:lex/utils/service_map.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// 有道 OCR
class YoudaoOcr {
  /// 使用有道 OCR 识别图片中的文字
  /// https://ai.youdao.com/DOCSIRMA/html/ocr/api/tyocr/index.html
  static Future<String> ocr(String imgPath, String language) async {
    const String url = "https://openapi.youdao.com/ocrapi";
    final String appKey = (prefs.getString("youdaoAppKey") ?? "").trim();
    final String appID = (prefs.getString("youdaoAppID") ?? "").trim();
    final String salt = DateTime.now().millisecondsSinceEpoch.toString();
    final String curtime =
        (DateTime.now().millisecondsSinceEpoch / 1000).round().toString();
    final String imageText =
        const Base64Encoder().convert(File(imgPath).readAsBytesSync());
    final String sign = _getSha256(appID, appKey, imageText, salt, curtime);
    final Map<String, String> query = {
      "img": imageText,
      "langType": language,
      "detectType": "10012",
      "imageType": "1",
      "appKey": appID,
      "salt": salt,
      "sign": sign,
      "docType": "json",
      "signType": "v3",
      "curtime": curtime,
    };
    final Dio dio = initDio();
    final Response response = await dio.post(
      url,
      queryParameters: query,
      options: Options(
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
      ),
    );
    List resultList = response.data["Result"]["regions"];
    String result = "";
    for (final item in resultList) {
      result += item["lines"].map((e) => e["text"]).join("\n") + "\n\n";
    }
    return result;
  }

  /// 有道 OCR 支持的语言
  /// https://ai.youdao.com/DOCSIRMA/html/ocr/api/tyocr/index.html
  static Map<String, String> languages() {
    return {
      "自动": "auto",
      "中文": "zh-CHS",
      "英语": "en",
      "繁体中文": "zh-CHT",
      "阿尔巴尼亚语": "sq",
      "阿塞拜疆语": "az",
      "巴斯克语": "eu",
      "白俄罗斯语": "be",
      "波斯尼亚文(拉丁文)": "bs",
      "保加利亚文": "bg",
      "加泰罗尼亚文(加泰隆语)": "ca",
      "宿务语": "ceb",
      "齐切瓦语": "ny",
      "科西嘉语": "co",
      "克罗地亚文": "hr",
      "捷克文": "cs",
      "丹麦文": "da",
      "荷兰文": "nl",
      "世界语": "eo",
      "爱沙尼亚文": "et",
      "芬兰文": "fi",
      "法文": "fr",
      "苏格兰盖尔语": "gd",
      "加利西亚语": "gl",
      "德文": "de",
      "海地文": "ht",
      "豪萨语": "ha",
      "夏威夷语": "haw",
      "印地文": "hi",
      "匈牙利文": "hu",
      "冰岛语": "is",
      "伊博语": "ig",
      "印度尼西亚文": "id",
      "爱尔兰语": "ga",
      "意大利文": "it",
      "日文": "ja",
      "印尼爪哇语": "jw",
      "韩文": "ko",
      "库尔德语": "ku",
      "拉丁语": "la",
      "拉脱维亚文": "lv",
      "立陶宛文": "lt",
      "卢森堡语": "lb",
      "马其顿语": "mk",
      "马尔加什语": "mg",
      "马来文": "ms",
      "马耳他文": "mt",
      "毛利语": "mi",
      "马拉地语": "mr",
      "蒙古语": "mn",
      "尼泊尔语": "ne",
      "挪威文": "no",
      "波兰文": "pl",
      "葡萄牙文": "pt",
      "罗马尼亚文": "ro",
      "俄文": "ru",
      "萨摩亚语": "sm",
      "塞尔维亚文(拉丁文)": "sr-Latn",
      "修纳语": "sn",
      "斯洛伐克文": "sk",
      "斯洛文尼亚文": "sl",
      "索马里语": "so",
      "塞索托语": "st",
      "西班牙文": "es",
      "印尼巽他语": "su",
      "斯瓦希里文": "sw",
      "瑞典文": "sv",
      "菲律宾语": "tl",
      "塔吉克语": "tg",
      "土耳其文": "tr",
      "乌克兰文": "uk",
      "乌兹别克语": "uz",
      "越南文": "vi",
      "威尔士文": "cy",
      "弗里斯兰语": "fy",
      "约鲁巴语": "yo",
      "南非祖鲁语": "zu",
      "苗族语": "hmn",
      "班图": "xh",
      "南非荷兰": "af",
      "阿拉伯文": "ar",
      "保加利亚语": "bg",
      "孟加拉语": "bn",
      "波斯尼亚语": "bs",
      "希腊": "el",
      "古吉拉特": "gu",
      "希伯来": "he",
      "海地克里奥尔": "ht",
      "格鲁吉亚": "ka",
      "高棉": "km",
      "卡纳达": "kn",
      "柯尔克孜语(吉尔吉斯语)": "ky",
      "马拉雅拉姆语": "ml",
      "白苗语": "mww",
      "缅甸": "my",
      "克雷塔罗奥托米语": "otq",
      "旁遮普语": "pa",
      "达里语": "prs",
      "普什图语": "ps",
      "卢旺达语": "rw",
      "塞尔维亚语(西里尔文)": "sr-Cyrl",
      "泰卢固语": "te",
      "泰语": "th",
      "土库曼语": "tk",
      "汤加语": "to",
      "乌尔都语": "ur",
      "意第绪语": "yi",
      "尤卡坦玛雅语": "yua",
    };
  }

  /// 检查有道O C R API 是否设置
  static bool checkApi() {
    if ((prefs.getString("youdaoAppID") ?? "").isEmpty ||
        (prefs.getString("youdaoAppKey") ?? "").isEmpty) {
      return false;
    }
    return true;
  }

  /// 设置有道 OCR AppID 和 AppKey
  static Future<void> setApi(BuildContext context) async {
    final appIDController = TextEditingController();
    final appKeyController = TextEditingController();
    appIDController.text = prefs.getString("youdaoAppID") ?? "";
    appKeyController.text = prefs.getString("youdaoAppKey") ?? "";
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: Image.asset(
            ocrServiceLogoMap()["youdao"]!,
            width: 40,
            height: 40,
          ),
          title: const Text("有道 OCR"),
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
                  hintText: "输入有道 OCR应用 ID",
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: appKeyController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "应用密钥",
                  hintText: "输入有道 OCR应用密钥",
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

  /// sha256 加密
  static String _getSha256(
    String appID,
    String appKey,
    String input,
    String salt,
    String curtime,
  ) {
    input = input.length > 20
        ? input.substring(0, 10) +
            input.length.toString() +
            input.substring(input.length - 10)
        : input;
    final String text = "$appID$input$salt$curtime$appKey";
    return sha256.convert(utf8.encode(text)).toString();
  }
}
