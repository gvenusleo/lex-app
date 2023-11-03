import "package:dio/dio.dart";
import "package:lex/utils/init_dio.dart";
import "package:uuid/uuid.dart";

/// Yandex 翻译
class YandexTranslation {
  /// Yandex 翻译
  static Future<String> translate(String text, String from, String to) async {
    try {
      from = languages()[from]!;
      to = languages()[to]!;
    } catch (_) {
      return "error:不支持的语言";
    }
    const String url = "https://translate.yandex.net/api/v1/tr.json/translate";
    const Map<String, String> headers = {
      "Content-Type": "application/x-www-form-urlencoded",
    };
    final Map<String, String> query = {
      "id": "${_getSid()}-0-0",
      "srv": "android",
    };
    final Map<String, String> data = {
      "source_lang": from,
      "target_lang": to,
      "text": text,
    };

    final Dio dio = initDio();
    final Response response = await dio.post(
      url,
      queryParameters: query,
      data: data,
      options: Options(headers: headers),
    );
    return response.data["text"].join();
  }

  /// Yandex 翻译受支持语言
  static Map<String, String> languages() {
    return {
      "自动": "",
      "中文": "zh",
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
    };
  }

  /// 获取随机的 sid
  static String _getSid() {
    final uuid = const Uuid().v4();
    return uuid.replaceAll("-", "");
  }
}
