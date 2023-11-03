import "dart:convert";

import "package:crypto/crypto.dart";
import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:lex/global.dart";
import "package:lex/utils/init_dio.dart";
import "package:lex/utils/service_map.dart";
import "package:url_launcher/url_launcher_string.dart";

/// 火山翻译
class VolcengineTranslation {
  /// 火山翻译
  /// https://www.volcengine.com/docs/4640/65067
  static Future<String> translate(String text, String from, String to) async {
    try {
      from = languages()[from]!;
      to = languages()[to]!;
    } catch (_) {
      return "error:不支持的语言";
    }
    final Map<String, dynamic> data = {
      "SourceLanguage": from,
      "TargetLanguage": to,
      "TextList": [text],
    };
    final dataHash = sha256.convert(utf8.encode(jsonEncode(data))).toString();
    final String xDate = _getXDate();
    final Map<String, String> headers = {
      "Authorization": _getAuthorization(text, from, to, dataHash, xDate),
      "Content-Type": "application/json; charset=utf-8",
      "Host": "translate.volcengineapi.com",
      "X-Content-Sha256": dataHash,
      "X-Date": xDate,
    };

    final Dio dio = initDio();
    final Response response = await dio.post(
      "https://translate.volcengineapi.com/?Action=TranslateText&Version=2020-06-01",
      data: data,
      options: Options(headers: headers),
    );
    final List resultList = response.data["TranslationList"];
    final String resultStr =
        resultList.map((e) => e["Translation"].toString()).join();
    return resultStr;
  }

  /// 火山翻译受支持语言
  /// 已排除部分仅支持单向翻译的语言
  /// https://www.volcengine.com/docs/4640/35107
  static Map<String, String> languages() {
    return {
      "自动": "",
      "中文": "zh",
      "文言文": "lzh",
      "繁体中文": "zh-Hant",
      "中文(香港繁体)": "zh-Hant-hk",
      "中文(台湾繁体)": "zh-Hant-tw",
      "札那语": "tn",
      "越南语": "vi",
      "伊努克提图特语": "iu",
      "意大利语": "it",
      "印尼语": "id",
      "印地语": "hi",
      "英语": "en",
      "希里莫图语": "ho",
      "希伯来语": "he",
      "西班牙语": "es",
      "现代希腊语": "el",
      "乌克兰语": "uk",
      "乌尔都语": "ur",
      "土库曼语": "tk",
      "土耳其语": "tr",
      "提格里尼亚语": "ti",
      "塔希提语": "ty",
      "他加禄语": "tl",
      "汤加语": "to",
      "泰语": "th",
      "泰米尔语": "ta",
      "泰卢固语": "te",
      "斯洛文尼亚语": "sl",
      "史瓦帝语": "ss",
      "世界语": "eo",
      "萨摩亚语": "sm",
      "桑戈语": "sg",
      "塞索托语": "st",
      "瑞典语": "sv",
      "日语": "ja",
      "契维语": "tw",
      "奇楚瓦语": "qu",
      "葡萄牙语": "pt",
      "旁遮普语": "pa",
      "挪威语": "no",
      "挪威布克莫尔语": "nb",
      "南恩德贝勒语": "nr",
      "缅甸语": "my",
      "孟加拉语": "bn",
      "蒙古语": "mn",
      "马绍尔语": "mh",
      "马其顿语": "mk",
      "马拉亚拉姆语": "ml",
      "马拉提语": "mr",
      "马来语": "ms",
      "卢巴卡丹加语": "lu",
      "罗马尼亚语": "ro",
      "立陶宛语": "lt",
      "拉脱维亚语": "lv",
      "老挝语": "lo",
      "宽亚玛语": "kj",
      "克罗地亚语": "hr",
      "坎纳达语": "kn",
      "基库尤语": "ki",
      "捷克语": "cs",
      "加泰隆语": "ca",
      "荷兰语": "nl",
      "韩语": "ko",
      "海地克里奥尔语": "ht",
      "古吉拉特语": "gu",
      "格鲁吉亚语": "ka",
      "格陵兰语": "kl",
      "高棉语": "km",
      "干达语": "lg",
      "刚果语": "kg",
      "芬兰语": "fi",
      "斐济语": "fj",
      "法语": "fr",
      "俄语": "ru",
      "恩敦加语": "ng",
      "德语": "de",
      "鞑靼语": "tt",
      "丹麦语": "da",
      "聪加语": "ts",
      "楚瓦什语": "cv",
      "波斯语": "fa",
      "波斯尼亚语": "bs",
      "波兰语": "pl",
      "比斯拉玛语": "bi",
      "北恩德贝勒语": "nd",
      "巴什基尔语": "ba",
      "保加利亚语": "bg",
      "阿塞拜疆语": "az",
      "阿拉伯语": "ar",
      "阿非利堪斯语": "af",
      "阿尔巴尼亚语": "sq",
      "阿布哈兹语": "ab",
      "奥塞梯语": "os",
      "埃维语": "ee",
      "爱沙尼亚语": "et",
      "艾马拉语": "ay",
      "阿姆哈拉语": "am",
      "中库尔德语": "ckb",
      "威尔士语": "cy",
      "加利西亚语": "gl",
      "豪萨语": "ha",
      "亚美尼亚语": "hy",
      "伊博语": "ig",
      "北库尔德语": "kmr",
      "林加拉语": "ln",
      "北索托语": "nso",
      "齐切瓦语": "ny",
      "奥洛莫语": "om",
      "绍纳语": "sn",
      "索马里语": "so",
      "塞尔维亚语": "sr",
      "斯瓦希里语": "sw",
      "科萨语": "xh",
      "约鲁巴语": "yo",
      "祖鲁语": "zu",
      "尼日利亚富拉语": "fuv",
      "匈牙利语": "hu",
      "坎巴语": "kam",
      "肯尼亚语": "luo",
      "基尼阿万达语": "rw",
      "卢欧语": "umb",
      "沃洛夫语": "wo",
    };
  }

  /// 设置火山翻译 AccessKeyID 和 SecretAccessKey
  static Future<void> setApi(BuildContext context) async {
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
            translationServiceLogoMap()["volcengine"]!,
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

  /// 获取标准时间格式
  static String _getXDate() {
    final String date = DateTime.now().toUtc().toIso8601String();
    return date
            .replaceAll("-", "")
            .replaceAll(":", "")
            .replaceAll(".", "")
            .substring(0, 15) +
        date.substring(date.length - 1);
  }

  /// 获取 headers 中的 Authorization 字段
  static String _getAuthorization(
    String text,
    String from,
    String to,
    String dataHash,
    String xDate,
  ) {
    final String accessKeyID =
        (prefs.getString("volcengineAccessKeyID") ?? "").trim();
    final String secretAccessKey =
        (prefs.getString("volcengineSecretAccessKey") ?? "").trim();

    const String host = "translate.volcengineapi.com";
    const String path = "/";
    const String queryString = "Action=TranslateText&Version=2020-06-01";
    const String region = "cn-north-1";
    const String service = "translate";

    final String xDataShort = xDate.substring(0, 8);
    Map<String, String> canonicalHeadersMap = {
      "content-type": "application/json; charset=utf-8",
      "host": host,
      "x-content-sha256": dataHash,
      "x-date": xDate,
    };
    String signedHeaders = "";
    String canonicalHeaders = "";
    canonicalHeadersMap.forEach((key, value) {
      canonicalHeaders += "$key:$value\n";
      if (key == canonicalHeadersMap.keys.last) {
        signedHeaders += key;
      } else {
        signedHeaders += "$key;";
      }
    });

    String canonicalRequest =
        "POST\n$path\n$queryString\n$canonicalHeaders\n$signedHeaders\n$dataHash";
    String credentialScope = "$xDataShort/$region/$service/request";
    String stringToSign =
        "HMAC-SHA256\n$xDate\n$credentialScope\n${sha256.convert(utf8.encode(canonicalRequest)).toString()}";

    var hmac = Hmac(sha256, utf8.encode(secretAccessKey));
    var digest = hmac.convert(utf8.encode(xDataShort));
    hmac = Hmac(sha256, digest.bytes);
    digest = hmac.convert(utf8.encode(region));
    hmac = Hmac(sha256, digest.bytes);
    digest = hmac.convert(utf8.encode(service));
    hmac = Hmac(sha256, digest.bytes);
    digest = hmac.convert(utf8.encode("request"));

    hmac = Hmac(sha256, digest.bytes);
    digest = hmac.convert(utf8.encode(stringToSign));
    String signature = digest.toString();
    return "HMAC-SHA256 Credential=$accessKeyID/$xDataShort/$region/$service/request, SignedHeaders=$signedHeaders, Signature=$signature";
  }
}
