import "package:dio/dio.dart";
import "package:lex/utils/init_dio.dart";
import "package:lex/services/translation/volcengine.dart";

/// 火山翻译 Free
class VolcengineFreeTranslation {
  /// 火山翻译 Free
  /// https://github.com/TechDecryptor/pot-app-translate-plugin-volcengine
  static Future<String> translate(
    String text,
    String from,
    String to,
  ) async {
    try {
      from = languages()[from]!;
      to = languages()[to]!;
    } catch (_) {
      return "error:不支持的语言";
    }
    const String url = "https://translate.volcengine.com/crx/translate/v1/";
    const Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    final Map<String, String> data = {
      "source_language": from,
      "target_language": to,
      "text": text
    };

    final Dio dio = initDio();
    final Response response = await dio.post(
      url,
      data: data,
      options: Options(headers: headers),
    );
    return response.data["translation"];
  }

  /// 火山翻译 Free 受支持语言
  /// 应该和火山翻译是一直的
  static Map<String, String> languages() {
    return VolcengineTranslation.languages();
  }
}
