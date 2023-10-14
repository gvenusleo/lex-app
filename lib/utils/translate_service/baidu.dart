import "dart:convert";

import "package:crypto/crypto.dart";
import "package:dio/dio.dart";
import "package:metranslate/global.dart";
import "package:metranslate/utils/init_dio.dart";

/// 百度翻译
/// https://fanyi-api.baidu.com/product/113
Future<String> translateByBaidu(String text, String from, String to) async {
  try {
    from = baiduSupportLanguage()[from]!;
    to = baiduSupportLanguage()[to]!;
  } catch (_) {
    return "不支持的语言";
  }
  const String url = "https://fanyi-api.baidu.com/api/trans/vip/translate";
  final String appID = prefs.getString("baiduAppID") ?? "";
  final String appKey = prefs.getString("baiduAppKey") ?? "";
  final String salt = DateTime.now().millisecondsSinceEpoch.toString();
  final String sign = getMd5(appID + text + salt.toString() + appKey);
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
Map<String, String> baiduSupportLanguage() {
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

/// md5 加密
String getMd5(String input) {
  return md5.convert(utf8.encode(input)).toString();
}
