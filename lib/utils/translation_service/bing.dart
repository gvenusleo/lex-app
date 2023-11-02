import "package:dio/dio.dart";
import "package:lex/utils/init_dio.dart";

/// Bing 翻译
Future<String> translateByBing(String text, String from, String to) async {
  try {
    from = bingSupportLanguage()[from]!;
    to = bingSupportLanguage()[to]!;
  } catch (_) {
    return "error:不支持的语言";
  }
  const String tokenUrl = "https://edge.microsoft.com/translate/auth";
  const Map<String, String> tokenHeaders = {
    "User-Agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36 Edg/113.0.1774.42",
  };

  final Dio dio = initDio();

  final Response tokenResponse = await dio.get(
    tokenUrl,
    options: Options(
      headers: tokenHeaders,
      responseType: ResponseType.plain,
    ),
  );
  final String token = tokenResponse.data;

  const String url =
      "https://api-edge.cognitive.microsofttranslator.com/translate";
  final Map<String, String> headers = {
    "accept": "*/*",
    "accept-language":
        "zh-TW,zh;q=0.9,ja;q=0.8,zh-CN;q=0.7,en-US;q=0.6,en;q=0.5",
    "authorization": "Bearer $token",
    "cache-control": "no-cache",
    "content-type": "application/json",
    "pragma": "no-cache",
    "sec-ch-ua":
        "'Microsoft Edge';v='113', 'Chromium';v='113', 'Not-A.Brand';v='24'",
    "sec-ch-ua-mobile": "?0",
    "sec-ch-ua-platform": "'Windows'",
    "sec-fetch-dest": "empty",
    "sec-fetch-mode": "cors",
    "sec-fetch-site": "cross-site",
    "Referer": "https://github.com/",
    "Referrer-Policy": "strict-origin-when-cross-origin",
    "User-Agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36 Edg/113.0.1774.42",
  };
  final Map<String, String> query = {
    "from": from,
    "to": to,
    "api-version": "3.0",
    "includeSentenceLength": "true",
  };
  final List data = [
    {"Text": text}
  ];

  final Response response = await dio.post(
    url,
    queryParameters: query,
    data: data,
    options: Options(headers: headers),
  );
  return response.data[0]["translations"][0]["text"];
}

/// Bing 翻译支持语言
Map<String, String> bingSupportLanguage() {
  return {
    "自动": "",
    "中文": 'zh-Hans',
    "繁体中文": 'zh-Hant',
    "粤语": 'yue',
    "英语": 'en',
    "日语": 'ja',
    "韩语": 'ko',
    "法语": 'fr',
    "西班牙语": 'es',
    "俄语": 'ru',
    "德语": 'de',
    "意大利语": 'it',
    "土耳其语": 'tr',
    "葡萄牙语": 'pt',
    "越南语": 'vi',
    "印尼语": 'id',
    "泰语": 'th',
    "马来语": 'ms',
    "阿拉伯语": 'ar',
    "印地语": 'hi',
    "蒙古语(西里尔)": 'mn-Cyrl',
    "蒙古语": 'mn-Mong',
    "高棉语": 'km',
  };
}
