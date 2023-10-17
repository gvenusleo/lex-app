import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:metranslate/utils/init_dio.dart';

/// Deepl Free 翻译
Future<String> translateByDeeplFree(String text, String from, String to) async {
  try {
    from = deeplFreeSupportLanguage()[from]!;
    to = deeplFreeSupportLanguage()[to]!;
  } catch (_) {
    return "error:不支持的语言";
  }
  const String url = "https://www2.deepl.com/jsonrpc";
  final int rand = getRandom();
  const Map<String, String> headers = {
    "Content-Type": "application/json",
  };
  final Map<String, dynamic> data = {
    "jsonrpc": "2.0",
    "method": "LMT_handle_texts",
    "params": {
      "splitting": "newlines",
      "lang": {"source_lang_user_selected": from, "target_lang": to},
      "texts": [
        {
          "text": text,
          "requestAlternatives": 0,
        }
      ],
      "timestamp": getTimeStamp(getICount(text)),
    },
    "id": rand,
  };
  String dataStr = jsonEncode(data);
  if ((rand + 5) % 29 == 0 || (rand + 3) % 13 == 0) {
    dataStr = dataStr.replaceAll('"method":"', '"method" : "');
  } else {
    dataStr = dataStr.replaceAll('"method":"', '"method": "');
  }

  final Dio dio = initDio();
  final Response response = await dio.post(
    url,
    data: dataStr,
    options: Options(headers: headers),
  );
  return response.data["result"]["texts"][0]["text"];
}

/// Deepl Free 受支持语言
Map<String, String> deeplFreeSupportLanguage() {
  return {
    "自动": "auto",
    "中文": "ZH",
    "英语": "EN",
    "日语": "JP",
    "韩语": "KO",
    "法语": "FR",
    "德语": "DE",
    "俄语": "RU",
    "葡萄牙语": "PT",
    "保加利亚语": "BG",
    "捷克语": "CS",
    "丹麦语": "DA",
    "希腊语": "EL",
    "西班牙语": "ES",
    "爱沙尼亚语": "ET",
    "芬兰语": "FI",
    "匈牙利语": "HU",
    "印度尼西亚语": "ID",
    "意大利语": "IT",
    "立陶宛语": "LT",
    "拉脱维亚语": "LV",
    "挪威语": "NB",
    "荷兰语": "NL",
    "波兰语": "PL",
    "罗马尼亚语": "RO",
    "斯洛伐克语": "SK",
    "斯洛文尼亚语": "SL",
    "瑞典语": "SV",
    "土耳其语": "TR",
    "乌克兰语": "UK",
  };
}

/// 获取翻译文本中 i 的数量
int getICount(String text) {
  return text.split("i").length - 1;
}

/// 生成请求随机数
int getRandom() {
  final int random = Random().nextInt(99999) + 100000;
  return random * 1000;
}

/// 根据 iCount 生成时间戳
int getTimeStamp(int iCount) {
  final int timeStamp = DateTime.now().millisecondsSinceEpoch;
  if (iCount != 0) {
    iCount += 1;
    return timeStamp - (timeStamp % iCount) + iCount;
  } else {
    return timeStamp;
  }
}
