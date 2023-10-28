import "dart:convert";

import "package:crypto/crypto.dart";
import "package:dio/dio.dart";
import "package:lex/global.dart";
import "package:lex/utils/init_dio.dart";

/// 有道翻译
/// https://ai.youdao.com/DOCSIRMA/html/trans/api/wbfy/index.html
Future<String> translateByYoudao(String text, String from, String to) async {
  try {
    from = youdaoSupportLanguage()[from]!;
    to = youdaoSupportLanguage()[to]!;
  } catch (_) {
    return "error:不支持的语言";
  }
  const String url = "https://openapi.youdao.com/api";
  final String appKey = (prefs.getString("youdaoAppKey") ?? "").trim();
  final String appID = (prefs.getString("youdaoAppID") ?? "").trim();
  final String salt = DateTime.now().millisecondsSinceEpoch.toString();
  final String curtime =
      (DateTime.now().millisecondsSinceEpoch / 1000).round().toString();
  final String sign = getSha256(appID, appKey, text, salt, curtime);
  final Map<String, String> query = {
    "q": text,
    "from": from,
    "to": to,
    "appKey": appID,
    "salt": salt,
    "sign": sign,
    "signType": "v3",
    "curtime": curtime,
  };
  final Dio dio = initDio();
  final Response response = await dio.post(url, queryParameters: query);
  return response.data["translation"].join();
}

/// 有道翻译支持语言
/// https://ai.youdao.com/DOCSIRMA/html/trans/api/wbfy/index.html
Map<String, String> youdaoSupportLanguage() {
  return {
    "自动": "auto",
    "阿拉伯语": "ar",
    "德语": "de",
    "英语": "en",
    "西班牙语": "es",
    "法语": "fr",
    "印地语": "hi",
    "印度尼西亚语": "id",
    "意大利语": "it",
    "日语": "ja",
    "韩语": "ko",
    "荷兰语": "nl",
    "葡萄牙语": "pt",
    "俄语": "ru",
    "泰语": "th",
    "越南语": "vi",
    "中文": "zh-CHS",
    "繁体中文": "zh-CHT",
    "南非荷兰语": "af",
    "阿姆哈拉语": "am",
    "阿塞拜疆语": "az",
    "白俄罗斯语": "be",
    "保加利亚语": "bg",
    "孟加拉语": "bn",
    "波斯尼亚语": "bs",
    "加泰隆语": "ca",
    "宿务语": "ceb",
    "科西嘉语": "co",
    "捷克语": "cs",
    "威尔士语": "cy",
    "丹麦语": "da",
    "希腊语": "el",
    "世界语": "eo",
    "爱沙尼亚语": "et",
    "巴斯克语": "eu",
    "波斯语": "fa",
    "芬兰语": "fi",
    "斐济语": "fj",
    "弗里西语": "fy",
    "爱尔兰语": "ga",
    "苏格兰盖尔语": "gd",
    "加利西亚语": "gl",
    "古吉拉特语": "gu",
    "豪萨语": "ha",
    "夏威夷语": "haw",
    "希伯来语": "he",
    "克罗地亚语": "hr",
    "海地克里奥尔语": "ht",
    "匈牙利语": "hu",
    "亚美尼亚语": "hy",
    "伊博语": "ig",
    "冰岛语": "is",
    "爪哇语": "jw",
    "格鲁吉亚语": "ka",
    "哈萨克语": "kk",
    "高棉语": "km",
    "卡纳达语": "kn",
    "库尔德语": "ku",
    "柯尔克孜语": "ky",
    "拉丁语": "la",
    "卢森堡语": "lb",
    "老挝语": "lo",
    "立陶宛语": "lt",
    "拉脱维亚语": "lv",
    "马尔加什语": "mg",
    "毛利语": "mi",
    "马其顿语": "mk",
    "马拉雅拉姆语": "ml",
    "蒙古语": "mn",
    "马拉地语": "mr",
    "马来语": "ms",
    "马耳他语": "mt",
    "白苗语": "mww",
    "缅甸语": "my",
    "尼泊尔语": "ne",
    "挪威语": "no",
    "齐切瓦语": "ny",
    "克雷塔罗奥托米语": "otq",
    "旁遮普语": "pa",
    "波兰语": "pl",
    "普什图语": "ps",
    "罗马尼亚语": "ro",
    "信德语": "sd",
    "僧伽罗语": "si",
    "斯洛伐克语": "sk",
    "斯洛文尼亚语": "sl",
    "萨摩亚语": "sm",
    "修纳语": "sn",
    "索马里语": "so",
    "阿尔巴尼亚语": "sq",
    "塞尔维亚语(西里尔文)": "sr-Cyrl",
    "塞尔维亚语(拉丁文)": "sr-Latn",
    "塞索托语": "st",
    "巽他语": "su",
    "瑞典语": "sv",
    "斯瓦希里语": "sw",
    "泰米尔语": "ta",
    "泰卢固语": "te",
    "塔吉克语": "tg",
    "菲律宾语": "tl",
    "克林贡语": "tlh",
    "汤加语": "to",
    "土耳其语": "tr",
    "塔希提语": "ty",
    "乌克兰语": "uk",
    "乌尔都语": "ur",
    "乌兹别克语": "uz",
    "南非科萨语": "xh",
    "意第绪语": "yi",
    "约鲁巴语": "yo",
    "尤卡坦玛雅语": "yua",
    "粤语": "yue",
    "南非祖鲁语": "zu",
  };
}

/// sha256 加密
String getSha256(
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
