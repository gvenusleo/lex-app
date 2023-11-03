import "package:dio/dio.dart";
import "package:lex/utils/init_dio.dart";

/// Google 翻译
class GoogleTranslation {
  /// Google 翻译
  static Future<String> translate(String text, String from, String to) async {
    try {
      from = languages()[from]!;
      to = languages()[to]!;
    } catch (_) {
      return "error:不支持的语言";
    }
    const String url =
        "https://translate.google.com/translate_a/single?dt=at&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t";
    final Map<String, String> header = {
      "content-type": "application/json",
    };
    final Map<String, String> query = {
      "client": "gtx",
      "sl": from,
      "tl": to,
      "hl": to,
      "ie": "UTF-8",
      "oe": "UTF-8",
      "otf": "1",
      "ssel": "0",
      "tsel": "0",
      "kc": "7",
      "q": text,
    };

    final Dio dio = initDio();
    final Response response = await dio.get(
      url,
      queryParameters: query,
      options: Options(headers: header),
    );
    return response.data[0][0][0];
  }

  /// Google 翻译受支持语言
  static Map<String, String> languages() {
    return {
      "自动": "auto",
      "中文": "zh-CN",
      "繁体中文": "zh-TW",
      "英语": "en",
      "日语": "ja",
      "韩语": "ko",
      "法语": "fr",
      "西班牙语": "es",
      "俄语": "ru",
      "德语": "de",
      "意大利语": "it",
      "土耳其语": "tr",
      "葡萄牙语": "pt",
      "越南语": "vi",
      "印度尼西亚语": "id",
      "泰语": "th",
      "马来语": "ms",
      "阿拉伯语": "ar",
      "印地语": "hi",
      "蒙古语": "mn",
      "高棉语": "km",
    };
  }
}
